class ApiEndpoints {
  // Yerd local development URL for Chrome / Web / macOS
  static const String baseUrl = 'http://airamod.test/api/v1';

  // Auth
  static const String login = '$baseUrl/auth/login';
  static const String logout = '$baseUrl/auth/logout';
  static const String me = '$baseUrl/auth/me';

  // Profile Endpoints
  static const String profile = '$baseUrl/profile';
  static const String updateContact = '$baseUrl/profile/contact';
  static const String updatePassword = '$baseUrl/profile/password';

  // Device Tokens (FCM)
  static const String deviceToken = '$baseUrl/devices/token';

  // Student Endpoints
  static const String studentDashboard = '$baseUrl/student/dashboard';
  static const String studentReports = '$baseUrl/student/reports';
  static String studentReportUpdate(int id) => '$baseUrl/student/reports/$id';
  static const String studentSafeguarding = '$baseUrl/student/safeguarding/reports';
  static const String studentMyIncidents = '$baseUrl/student/safeguarding/my-reports';

  // Parent Endpoints
  static const String parentDashboard = '$baseUrl/parent/dashboard';
  static const String parentReports = '$baseUrl/parent/reports';
  static String parentAppreciate(int reportId) => '$baseUrl/parent/reports/$reportId/appreciations';

  // Safeguarding Public Tracking
  static String trackSafeguarding(String code) => '$baseUrl/safeguarding/track/$code';
}
