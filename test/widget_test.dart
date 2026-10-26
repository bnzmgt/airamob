import 'package:flutter_test/flutter_test.dart';
import 'package:ainara_mobile/main.dart';

void main() {
  testWidgets('AinaraApp loads successfully', (WidgetTester tester) async {
    await tester.pumpWidget(const AinaraApp());
    expect(find.byType(AinaraApp), findsOneWidget);
  });
}
