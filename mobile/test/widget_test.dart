import 'package:flutter_test/flutter_test.dart';
import 'package:pmd_kurnia5/main.dart';

void main() {
  testWidgets('aplikasi tampil', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());
    expect(find.text('PMD Kurnia 5'), findsOneWidget);
  });
}