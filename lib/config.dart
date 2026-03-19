class AppConfig {
  // ── Update this one URL when switching environments ──────────────
  // Current: staging/testing server
  // Replace with the live URL 
  static const String baseUrl = 'https://bemmas.brainversetechnologies.co.ke';

  // Derived URLs — no need to change these
  static const String apiUrl     = '$baseUrl/api';
  static const String apiLogin   = '$apiUrl/login';
  static const String webLogin   = '$baseUrl/auth/login';
  static const String eventsApi  = '$baseUrl/events/api_list';
  static const String eventsGet  = '$apiUrl/events/get_events';
  static const String dashMeta   = '$baseUrl/users/auth/dashboard_meta';
  static const String verifyTicket = '$apiUrl/bookings/verify';
}