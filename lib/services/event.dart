import 'dart:convert';
import 'package:http/http.dart' as http;

class EventService {

  final String webBaseUrl = 'https://bemmas.brainversetechnologies.co.ke';
  final String baseUrl    = 'https://bemmas.brainversetechnologies.co.ke/api';

  // Fetch events and merge real booking counts from dashboard_meta
  Future fetchEvents(String token, {String? sessionCookie}) async {

    print("=== FETCH EVENTS ===");

    final headers = sessionCookie != null && sessionCookie.isNotEmpty
        ? {'Cookie': 'ci_session=$sessionCookie', 'Accept': 'application/json'}
        : {'Authorization': 'Bearer $token',      'Accept': 'application/json'};

    // ── 1. Fetch events list ─────────────────────────────────────────
    List<dynamic> events = [];

    try {
      final eventsUrl = sessionCookie != null && sessionCookie.isNotEmpty
          ? '$webBaseUrl/events/api_list'
          : '$baseUrl/events/get_events';

      print("FETCHING EVENTS: $eventsUrl");
      final res = await http.get(Uri.parse(eventsUrl), headers: headers);
      print("EVENTS STATUS: ${res.statusCode}");

      if (res.statusCode == 200 && res.body.isNotEmpty) {
        final decoded = jsonDecode(res.body);
        final raw = decoded['data'];
        if (raw is List) {
          events = raw;
        } else if (raw is Map) {
          events = raw['data'] ?? raw['events'] ?? [];
        }
        print("EVENTS FETCHED: ${events.length}");
      }
    } catch (e) {
      print("EVENTS FETCH ERROR: $e");
    }

    // ── 2. Fetch dashboard meta for real booking counts ──────────────
    Map<int, int> ticketsByEventId = {};

    try {
      print("FETCHING DASHBOARD META");
      final metaRes = await http.get(
        Uri.parse('$webBaseUrl/users/auth/dashboard_meta'),
        headers: headers,
      );
      print("META STATUS: ${metaRes.statusCode}");
      print("META BODY: ${metaRes.body}");

      if (metaRes.statusCode == 200 && metaRes.body.isNotEmpty) {
        final meta = jsonDecode(metaRes.body);
        final sales = meta['ticket_sales_by_event'];
        if (sales is List) {
          for (final item in sales) {
            final id      = item['event_id'];
            final tickets = item['tickets_sold'] ?? 0;
            if (id != null) {
              ticketsByEventId[id is int ? id : int.tryParse(id.toString()) ?? 0] =
                  tickets is int ? tickets : int.tryParse(tickets.toString()) ?? 0;
            }
          }
          print("BOOKING COUNTS LOADED: $ticketsByEventId");
        }
      }
    } catch (e) {
      print("META FETCH ERROR: $e");
    }

    // ── 3. Merge booking counts into each event ──────────────────────
    if (ticketsByEventId.isNotEmpty) {
      events = events.map((event) {
        final id = event['id'] is int
            ? event['id']
            : int.tryParse(event['id']?.toString() ?? '') ?? 0;
        final count = ticketsByEventId[id];
        if (count != null) {
          return {...Map<String, dynamic>.from(event), 'bookings_count': count};
        }
        return event;
      }).toList();
    }

    return {'status': 200, 'message': 'Data retrieved successfully', 'data': events};
  }


  // Validate scanned ticket
  Future validateTicket(String eventToken, String code) async {

    Map body = {
      'event_token': eventToken,
      'booking_code': code,
    };

    final response = await http.post(
      Uri.parse('$baseUrl/bookings/verify'),
      body: body,
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