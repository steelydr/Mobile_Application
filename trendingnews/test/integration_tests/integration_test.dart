import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cs442_mp6/widgets/FavouritesUpdate.dart';
import 'package:cs442_mp6/widgets/CountryNews.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Basic app test - Launch and verify basic structure', (WidgetTester tester) async {
    // Build our app and trigger a frame
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => FavouritesStore(),
        child: const MaterialApp(
          debugShowCheckedModeBanner: false,
          home: AllNews(),
        ),
      ),
    );

    // Wait for initial frame
    await tester.pump();

    // Verify that the AllNews widget is present
    expect(find.byType(AllNews), findsOneWidget);

    // Verify that the Scaffold is present
    expect(find.byType(Scaffold), findsOneWidget);

    // Optional: Print widget tree for debugging
    // This will help us understand what widgets are actually present
    debugPrint(tester.renderObject(find.byType(MaterialApp)).toStringDeep());
  });
}