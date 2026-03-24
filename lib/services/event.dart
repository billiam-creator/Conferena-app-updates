import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:ticketkona/config.dart';

class EventService {

  Future fetchEvents(String token, {String? sessionCookie}) async {

    print("=== FETCH EVENTS ===");

    // Server requires BOTH Bearer token AND session cookie together
    final headers = {
      'Authorization': 'Bearer $token',
      'Accept': 'application/json',
      if (sessionCookie != null && sessionCookie.isNotEmpty)
        'Cookie': 'ci_session=$sessionCookie',
    };

    // ── 1. Fetch events list ─────────────────────────────────────────
    List<dynamic> events = [];

    try {
      print("FETCHING EVENTS: ${AppConfig.eventsGet}");
      final res = await http.get(Uri.parse(AppConfig.eventsGet), headers: headers);
      print("STATUS: ${res.statusCode}");
      print("BODY: ${res.body}");

      if (res.statusCode == 200 && res.body.isNotEmpty) {
        final decoded = jsonDecode(res.body);
        final raw = decoded['data'];
        if (raw is List) events = raw;
        print("EVENTS FETCHED: ${events.length}");
      }
    } catch (e) {
      print("EVENTS ERROR: $e");
    }

    // ── 2. Fetch booking counts for each event via HTML parsing ──────
    if (sessionCookie != null && sessionCookie.isNotEmpty && events.isNotEmpty) {
      final cookieHeaders = {
        'Cookie': 'ci_session=$sessionCookie',
        'Accept': 'text/html',
      };

      events = await Future.wait(events.map((event) async {
        try {
          final rawId = event['event_id'] ?? event['id'];
          final eventId = rawId?.toString() ?? '';
          if (eventId.isEmpty) return event;

          print("FETCHING BOOKING COUNTS FOR EVENT: $eventId");
          final res = await http.get(
            Uri.parse('${AppConfig.baseUrl}/events/get_booking/$eventId'),
            headers: cookieHeaders,
          );

          print("BOOKING PAGE STATUS: ${res.statusCode}");

          if (res.statusCode == 200 && res.body.isNotEmpty) {
            final html = res.body;

            // Parse "Total Tickets Booked" from HTML
            final totalMatch = RegExp(
              r'Total Tickets Booked[\s\S]*?<span>\s*(\d+)\s*<\/span>',
            ).firstMatch(html);

            final total = totalMatch != null
                ? int.tryParse(totalMatch.group(1)?.trim() ?? '0') ?? 0
                : 0;

            print("PARSED BOOKING COUNT FOR $eventId: $total");

            if (total > 0) {
              return {
                ...Map<String, dynamic>.from(event),
                'bookings_count': total,
              };
            }
          }
        } catch (e) {
          print("BOOKING COUNT ERROR: $e");
        }
        return event;
      }));
    }

    return {'status': 200, 'message': 'Data retrieved successfully', 'data': events};
  }


  Future validateTicket(String eventToken, String code) async {

    final response = await http.post(
      Uri.parse(AppConfig.verifyTicket),
      body: {
        'event_token': eventToken,
        'booking_code': code,
      },
    );

    print("VERIFY RESPONSE: ${response.body}");

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else if (response.statusCode == 400) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Ticket validation failed');
    }
  }

}