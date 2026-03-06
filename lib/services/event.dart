import 'dart:convert';
import 'package:http/http.dart' as http;

class EventService {
  final String baseUrl = 'https://go.conferena.com/api';

  // Existing method: fetch event using token
  Future fetchEvent(String token) async {
    Map body = {'event_token': token};

    final response = await http.post(
      Uri.parse('$baseUrl/events/get_by_token'),
      body: body,
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else if (response.statusCode == 400) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Something went wrong. Please try again');
    }
  }

  // NEW: fetch events for logged-in user
  Future fetchEvents(String token) async {
    Map body = {'event_token': token};

    final response = await http.post(
      Uri.parse('$baseUrl/events/get_by_token'),
      body: body,
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else if (response.statusCode == 400) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to fetch events');
    }
  }

  // Existing: validate scanned ticket
  Future validateTicket(String token, String code) async {
    Map body = {'event_token': token, 'booking_code': code};

    final response = await http.post(
      Uri.parse('$baseUrl/bookings/verify'),
      body: body,
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else if (response.statusCode == 400) {
      return jsonDecode(response.body);
    } else {
      throw Exception();
    }
  }
}