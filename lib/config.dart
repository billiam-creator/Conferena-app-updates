class AppConfig {
  // ── Live production server -
  static const String baseUrl = 'https://go.conferena.com';

  // Derived URLs 
  static const String apiUrl      = '$baseUrl/api';
  static const String apiLogin    = '$apiUrl/login';
  static const String webLogin    = '$baseUrl/auth/login';
  static const String eventsApi   = '$baseUrl/events/api_list';
  static const String eventsGet   = '$apiUrl/events/get_events';
  static const String dashMeta    = '$baseUrl/users/auth/dashboard_meta';
  static const String verifyTicket = '$apiUrl/bookings/verify';
}