import 'package:flutter_test/flutter_test.dart';
import 'package:recylpay/main.dart';

void main() {
  testWidgets('App launches successfully', (WidgetTester tester) async {
    await tester.pumpWidget(const RecycPayApp());
    expect(find.text('RecycPay'), findsOneWidget);
  });
}
