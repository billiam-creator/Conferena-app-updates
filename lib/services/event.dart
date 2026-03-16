import 'dart:convert';
import 'package:http/http.dart' as http;

class EventService {

  final String webBaseUrl = 'https://bemmas.brainversetechnologies.co.ke';
  final String baseUrl = 'https://bemmas.brainversetechnologies.co.ke/api';

  // Fetch events using ci_session cookie (same as website dashboard)
  Future fetchEvents(String token, {String? sessionCookie}) async {

    print("=== FETCH EVENTS ===");

    // If we have a session cookie, use the web endpoint (same as website)
    if (sessionCookie != null && sessionCookie.isNotEmpty) {
      print("Using session cookie with /events/api_list");
      try {
        final response = await http.get(
          Uri.parse('$webBaseUrl/events/api_list'),
          headers: {
            'Cookie': 'ci_session=$sessionCookie',
            'Accept': 'application/json',
          },
        );
        print("STATUS: ${response.statusCode}");
        print("BODY: ${response.body}");

        if (response.statusCode == 200 && response.body.isNotEmpty) {
          final decoded = jsonDecode(response.body);
          return decoded;
        }
      } catch (e) {
        print("Session cookie approach failed: $e");
      }
    }

    // Fallback: Bearer token with API endpoint
    print("Falling back to Bearer token with /api/events/get_events");
    final response = await http.get(
      Uri.parse('$baseUrl/events/get_events'),
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
    );
    print("STATUS: ${response.statusCode}");
    print("BODY: ${response.body}");

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load events: ${response.statusCode}');
    }
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