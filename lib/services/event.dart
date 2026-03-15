import 'dart:convert';
import 'package:http/http.dart' as http;

class EventService {

  final String baseUrl = 'https://bemmas.brainversetechnologies.co.ke/api';

  // Fetch events for logged in user
  Future fetchEvents(String token) async {

    final response = await http.get(
      Uri.parse('$baseUrl/events/get_events'),
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
    );

    print("EVENTS RESPONSE: ${response.body}");

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load events');
    }
  }


  // Validate scanned ticket
  Future validateTicket(String eventToken, String code) async {

    Map body = {
      'event_token': eventToken,
      'booking_code': code
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