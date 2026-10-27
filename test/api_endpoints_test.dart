import 'package:flutter_test/flutter_test.dart';
import 'package:ainara_mobile/core/api/api_endpoints.dart';

void main() {
  group('ApiEndpoints Dynamic URL Tests', () {
    test('Default baseUrl is valid and has api/v1 suffix', () {
      expect(ApiEndpoints.baseUrl, isNotEmpty);
      expect(ApiEndpoints.baseUrl.endsWith('/api/v1'), isTrue);
    });

    test('sanitizeBaseUrl normalizes various URL formats', () {
      expect(
        ApiEndpoints.sanitizeBaseUrl('http://192.168.1.100:8000/api/v1/'),
        'http://192.168.1.100:8000/api/v1',
      );
      expect(
        ApiEndpoints.sanitizeBaseUrl('http://192.168.1.100:8000/api/v1'),
        'http://192.168.1.100:8000/api/v1',
      );
      expect(
        ApiEndpoints.sanitizeBaseUrl('http://10.0.2.2:8000/'),
        'http://10.0.2.2:8000/api/v1',
      );
      expect(
        ApiEndpoints.sanitizeBaseUrl('https://api.ainara.id'),
        'https://api.ainara.id/api/v1',
      );
    });

    test('setBaseUrl updates all endpoints dynamically', () {
      const customUrl = 'http://192.168.1.50:8000/api/v1';
      ApiEndpoints.setBaseUrl(customUrl);

      expect(ApiEndpoints.baseUrl, customUrl);
      expect(ApiEndpoints.login, '$customUrl/auth/login');
      expect(ApiEndpoints.studentReports, '$customUrl/student/reports');
      expect(ApiEndpoints.studentReportUpdate(99), '$customUrl/student/reports/99');
      expect(ApiEndpoints.parentDashboard, '$customUrl/parent/dashboard');
      expect(ApiEndpoints.parentAppreciate(42), '$customUrl/parent/reports/42/appreciations');
      expect(ApiEndpoints.trackSafeguarding('SA-1234'), '$customUrl/safeguarding/track/SA-1234');
      expect(ApiEndpoints.pingCheck, '$customUrl/safeguarding/track/PING-CHECK');

      // Reset back to default
      ApiEndpoints.setBaseUrl(ApiEndpoints.defaultBaseUrl);
      expect(ApiEndpoints.baseUrl, ApiEndpoints.defaultBaseUrl);
    });
  });
}
