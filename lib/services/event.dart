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

    // ── 1. Fetch events ──────────────────────────────────────────────
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

    // ── 2. Fetch booking counts ──────────────────────────────────────
    Map<int, int> ticketsByEventId = {};

    try {
      final metaRes = await http.get(Uri.parse(AppConfig.dashMeta), headers: headers);
      print("META STATUS: ${metaRes.statusCode}");

      if (metaRes.statusCode == 200 && metaRes.body.isNotEmpty) {
        final meta = jsonDecode(metaRes.body);
        final sales = meta['ticket_sales_by_event'];
        if (sales is List) {
          for (final item in sales) {
            final id = item['event_id'];
            final tickets = item['tickets_sold'] ?? 0;
            if (id != null) {
              ticketsByEventId[id is int ? id : int.tryParse(id.toString()) ?? 0] =
                  tickets is int ? tickets : int.tryParse(tickets.toString()) ?? 0;
            }
          }
          print("BOOKING COUNTS: $ticketsByEventId");
        }
      }
    } catch (e) {
      print("META ERROR: $e");
    }

    // ── 3. Merge booking counts into events ──────────────────────────
    if (ticketsByEventId.isNotEmpty) {
      events = events.map((event) {
        final rawId = event['event_id'] ?? event['id'];
        final id = rawId is int ? rawId : int.tryParse(rawId?.toString() ?? '') ?? 0;
        final count = ticketsByEventId[id];
        if (count != null) {
          return {...Map<String, dynamic>.from(event), 'bookings_count': count};
        }
        return event;
      }).toList();
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