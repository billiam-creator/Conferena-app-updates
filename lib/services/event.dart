import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:ticketkona/config.dart';

class EventService {

  Future fetchEvents(String token, {String? sessionCookie}) async {

    print("=== FETCH EVENTS ===");

    final headers = sessionCookie != null && sessionCookie.isNotEmpty
        ? {'Cookie': 'ci_session=$sessionCookie', 'Accept': 'application/json'}
        : {'Authorization': 'Bearer $token',      'Accept': 'application/json'};

    //Fetch events list
    List<dynamic> events = [];

    try {
      final eventsUrl = sessionCookie != null && sessionCookie.isNotEmpty
          ? AppConfig.eventsApi
          : AppConfig.eventsGet;

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

    //  Fetch dashboard meta for booking counts
    Map<int, int> ticketsByEventId = {};

    try {
      print("FETCHING DASHBOARD META");
      final metaRes = await http.get(
        Uri.parse(AppConfig.dashMeta),
        headers: headers,
      );
      print("META STATUS: ${metaRes.statusCode}");

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

    // Merge booking counts into each event
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