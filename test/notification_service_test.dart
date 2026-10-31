import 'package:flutter_test/flutter_test.dart';
import 'package:ainara_mobile/services/notification_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('NotificationService Safe Fallback Tests', () {
    test('getToken returns null safely when native Firebase is not initialized', () async {
      final token = await NotificationService.getToken();
      expect(token, isNull);
    });

    test('syncTokenWithBackend handles unauthenticated state gracefully without crashing', () async {
      final result = await NotificationService.syncTokenWithBackend();
      expect(result, isFalse);
    });

    test('unregisterToken completes gracefully without throwing exception', () async {
      expect(NotificationService.unregisterToken(), completes);
    });
  });
}
