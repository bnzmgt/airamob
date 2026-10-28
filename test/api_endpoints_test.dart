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

    test('resolveImageUrl correctly resolves absolute, relative and data urls', () {
      ApiEndpoints.setBaseUrl('https://ainara.dstr.biz.id/api/v1');

      // Empty or null
      expect(ApiEndpoints.resolveImageUrl(null), '');
      expect(ApiEndpoints.resolveImageUrl(''), '');

      // Already absolute
      expect(
        ApiEndpoints.resolveImageUrl('https://ainara.dstr.biz.id/storage/avatars/1.jpg'),
        'https://ainara.dstr.biz.id/storage/avatars/1.jpg',
      );
      expect(
        ApiEndpoints.resolveImageUrl('http://other.com/pic.png'),
        'http://other.com/pic.png',
      );

      // Relative paths
      expect(
        ApiEndpoints.resolveImageUrl('/storage/reports/note.jpg'),
        'https://ainara.dstr.biz.id/storage/reports/note.jpg',
      );
      expect(
        ApiEndpoints.resolveImageUrl('storage/reports/note.jpg'),
        'https://ainara.dstr.biz.id/storage/reports/note.jpg',
      );

      // Data URIs
      expect(
        ApiEndpoints.resolveImageUrl('data:image/svg+xml;base64,xxxx'),
        'data:image/svg+xml;base64,xxxx',
      );
    });
  });
}
