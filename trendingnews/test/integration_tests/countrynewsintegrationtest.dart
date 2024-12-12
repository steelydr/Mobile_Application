import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cs442_mp6/widgets/FavouritesUpdate.dart';
import 'package:cs442_mp6/widgets/CountryNews.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('News app basic functionality test', (WidgetTester tester) async {
    // Build the app
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => FavouritesStore(),
        child: const MaterialApp(
          debugShowCheckedModeBanner: false,
          home: AllNews(),
        ),
      ),
    );

    // Initial frame
    await tester.pump();

    // Verify AppBar elements
    expect(find.text("Today's Headlines"), findsOneWidget);
    expect(find.byIcon(Icons.favorite), findsOneWidget);

    // Verify that Scaffold is present
    expect(find.byType(Scaffold), findsOneWidget);

    // Verify that CustomScrollView is present
    expect(find.byType(CustomScrollView), findsOneWidget);

    // Test favorite button presence
    final favoriteButton = find.byIcon(Icons.favorite);
    expect(favoriteButton, findsOneWidget);
  });
}