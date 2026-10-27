import '../storage/secure_storage.dart';

class ApiEndpoints {
  // Compile-time default URL with fallback to local development
  // Can be overridden during build: flutter build apk --dart-define=API_BASE_URL=https://your-domain.com/api/v1
  static const String defaultBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://ainara.dstr.biz.id/api/v1',
  );

  static String _baseUrl = defaultBaseUrl;

  static String get baseUrl => _baseUrl;

  /// Sanitizes URL to ensure valid format and proper '/api/v1' suffix
  static String sanitizeBaseUrl(String url) {
    var clean = url.trim();
    while (clean.endsWith('/')) {
      clean = clean.substring(0, clean.length - 1);
    }
    if (!clean.endsWith('/api/v1')) {
      clean = '$clean/api/v1';
    }
    return clean;
  }

  /// Initializes base URL from secure storage if previously configured by user
  static Future<void> init() async {
    final stored = await SecureStorage.getBaseUrl();
    if (stored != null && stored.trim().isNotEmpty) {
      _baseUrl = sanitizeBaseUrl(stored.trim());
    } else {
      _baseUrl = defaultBaseUrl;
    }
  }

  /// Sets base URL at runtime (e.g. from Server Settings Dialog)
  static void setBaseUrl(String url) {
    _baseUrl = sanitizeBaseUrl(url);
  }

  // Auth
  static String get login => '$baseUrl/auth/login';
  static String get logout => '$baseUrl/auth/logout';
  static String get me => '$baseUrl/auth/me';

  // Profile Endpoints
  static String get profile => '$baseUrl/profile';
  static String get updateContact => '$baseUrl/profile/contact';
  static String get updatePassword => '$baseUrl/profile/password';

  // Device Tokens (FCM)
  static String get deviceToken => '$baseUrl/devices/token';

  // Student Endpoints
  static String get studentDashboard => '$baseUrl/student/dashboard';
  static String get studentReports => '$baseUrl/student/reports';
  static String studentReportUpdate(int id) => '$baseUrl/student/reports/$id';
  static String get studentSafeguarding => '$baseUrl/student/safeguarding/reports';
  static String get studentMyIncidents => '$baseUrl/student/safeguarding/my-reports';

  // Parent Endpoints
  static String get parentDashboard => '$baseUrl/parent/dashboard';
  static String get parentReports => '$baseUrl/parent/reports';
  static String parentAppreciate(int reportId) => '$baseUrl/parent/reports/$reportId/appreciations';

  // Parent Child Dedicated Reports & Exports
  static String parentChildReports(int studentId) => '$baseUrl/parent/students/$studentId/reports';
  static String get parentReportsExportCsv => '$baseUrl/parent/reports/export/csv';
  static String get parentReportsExportPdf => '$baseUrl/parent/reports/export/pdf';
  static String parentChildExportCsv(int studentId) => '$baseUrl/parent/students/$studentId/export/csv';
  static String parentChildExportPdf(int studentId) => '$baseUrl/parent/students/$studentId/export/pdf';

  // Safeguarding Public Tracking
  static String trackSafeguarding(String code) => '$baseUrl/safeguarding/track/$code';

  // Connectivity Ping Endpoint (Public Tokenless Test)
  static String get pingCheck => '$baseUrl/safeguarding/track/PING-CHECK';
}
