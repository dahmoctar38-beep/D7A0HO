import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nutriscan_ai/app/app.dart';

void main() {
  testWidgets('App renders home screen', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(child: NutriScanApp()),
    );
    await tester.pumpAndSettle();
    expect(find.text('NutriScan AI'), findsOneWidget);
  });
}
