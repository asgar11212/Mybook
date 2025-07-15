import 'package:flutter_test/flutter_test.dart';
import 'package:notscrd/main.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  testWidgets('App loads and shows MyBooks title', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp(initialDarkMode: false));
    await tester.pumpAndSettle();

    expect(find.text('MyBooks'), findsOneWidget);
  });
}
