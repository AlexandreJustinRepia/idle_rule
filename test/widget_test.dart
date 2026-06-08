import 'package:flutter_test/flutter_test.dart';
import 'package:idle_rule/main.dart';

void main() {
  testWidgets('shows the idle combat screen', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    expect(find.text('CURRENT STATS'), findsOneWidget);
    expect(find.text('Strength'), findsOneWidget);
    expect(find.text('PLAYER'), findsOneWidget);
    expect(find.textContaining('HP:'), findsAtLeastNWidgets(1));
  });
}
