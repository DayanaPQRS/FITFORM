import 'package:flutter_test/flutter_test.dart';
import 'package:fitform_mobile/main.dart';

void main() {
  testWidgets('FitFormApp smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const FitFormApp());
  });
}
