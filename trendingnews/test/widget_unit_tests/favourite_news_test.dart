// Import necessary Flutter and testing packages
import 'package:flutter/material.dart'; // Provides Flutter UI components
import 'package:flutter_test/flutter_test.dart'; // Provides utilities for widget testing
import 'package:provider/provider.dart'; // Enables state management using Provider
import 'package:cs442_mp6/widgets/FavouriteNews.dart'; // The widget under test
import 'package:cs442_mp6/widgets/FavouritesUpdate.dart'; // Provides the FavouritesStore class

void main() {
  // Define a group of widget tests
  testWidgets('FavouriteNews shows correct number of articles', (WidgetTester tester) async {
    // Create test data for articles
    final testArticles = [
      {
        'urlToImage': 'https://example.com/image1.jpg', // Image URL for the article
        'url': 'https://example.com/article1', // Link to the full article
        'title': 'Test Article 1', // Article title
        'descr': 'Test Description 1', // Article description
        'content': 'Test Content 1', // Article content
        'id': '2024-01-01', // Article ID
      },
      {
        'urlToImage': 'https://example.com/image2.jpg', // Image URL for the second article
        'url': 'https://example.com/article2', // Link to the second article
        'title': 'Test Article 2', // Title of the second article
        'descr': 'Test Description 2', // Description of the second article
        'content': 'Test Content 2', // Content of the second article
        'id': '2024-01-02', // ID for the second article
      }
    ];

    // Create a mock FavouritesStore instance
    final favouritesStore = FavouritesStore();

    // Build the widget tree and wrap it with a ChangeNotifierProvider for state management
    await tester.pumpWidget(
      MaterialApp(
        home: ChangeNotifierProvider<FavouritesStore>(
          create: (context) => favouritesStore, // Provide the FavouritesStore instance
          child: FavouriteNews(results: testArticles), // Pass the test data to the FavouriteNews widget
        ),
      ),
    );

    // Wait for any animations or updates to complete
    await tester.pumpAndSettle();

    // Verify the number of saved articles is displayed correctly
    expect(find.text('2 Saved'), findsOneWidget);

    // Verify that the "Recent" filter is displayed
    expect(find.text('Recent'), findsOneWidget);

    // Verify that the empty state message is not displayed
    expect(find.text('No saved articles yet'), findsNothing);

    // Optional: Simulate scrolling if there are many articles
    await tester.drag(find.byType(CustomScrollView), const Offset(0, -300)); // Drag to scroll up
    await tester.pumpAndSettle(); // Wait for the scrolling to finish
  });

  // Test for empty state when no articles are provided
  testWidgets('FavouriteNews shows empty state when no articles', (WidgetTester tester) async {
    // Create a mock FavouritesStore instance
    final favouritesStore = FavouritesStore();

    // Build the widget tree with an empty list of articles
    await tester.pumpWidget(
      MaterialApp(
        home: ChangeNotifierProvider<FavouritesStore>(
          create: (context) => favouritesStore, // Provide the FavouritesStore instance
          child: FavouriteNews(results: []), // Pass an empty list to the FavouriteNews widget
        ),
      ),
    );

    // Wait for any animations or updates to complete
    await tester.pumpAndSettle();

    // Verify that the empty state message is displayed
    expect(find.text('No saved articles yet'), findsOneWidget);

    // Verify that the placeholder text for empty state is displayed
    expect(find.text('Articles you save will appear here'), findsOneWidget);
  });
}
