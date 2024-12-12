// Import necessary Flutter and testing packages
import 'package:flutter/material.dart'; // Provides UI components for Flutter
import 'package:flutter_test/flutter_test.dart'; // Provides utilities for widget testing
import 'package:provider/provider.dart'; // Enables state management using Provider
import 'package:cs442_mp6/widgets/EachNews.dart'; // The widget under test
import 'package:cs442_mp6/widgets/FavouritesUpdate.dart'; // Provides the FavouritesStore class

void main() {
  // Define a group of tests for the EachNews widget
  testWidgets('EachNews widget displays basic elements', (WidgetTester tester) async {
    // Mock data for a news article
    final mockNews = {
      'publishedAt': '2024-01-01', // Publication date of the news
      'urlToImage': 'https://example.com/image.jpg', // Image URL for the news
      'url': 'https://example.com', // Link to the full news article
      'title': 'Test News Title', // Title of the news
      'description': 'Test Description', // Short description of the news
      'content': 'Test Content' // Full content of the news
    };

    // Build the widget tree with the EachNews widget
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => FavouritesStore(), // Provide a FavouritesStore instance for state management
        child: MaterialApp(
          home: EachNews(news: mockNews), // Pass the mock data to the EachNews widget
        ),
      ),
    );

    // Basic UI tests to verify elements are displayed
    expect(find.text('Test News Title'), findsOneWidget); // Verify the title is displayed
    expect(find.text('Test Description'), findsOneWidget); // Verify the description is displayed
    expect(find.byIcon(Icons.star_border), findsOneWidget); // Verify the favorite icon is displayed
  });

  // Test case to verify EachNews handles null images gracefully
  testWidgets('EachNews handles null image gracefully', (WidgetTester tester) async {
    // Mock data with a null image URL
    final mockNews = {
      'publishedAt': '2024-01-01', // Publication date of the news
      'urlToImage': null, // Image URL is null
      'url': 'https://example.com', // Link to the full news article
      'title': 'Test Title', // Title of the news
      'description': 'Test Description', // Short description of the news
      'content': 'Test Content' // Full content of the news
    };

    // Build the widget tree with the EachNews widget
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => FavouritesStore(), // Provide a FavouritesStore instance for state management
        child: MaterialApp(
          home: EachNews(news: mockNews), // Pass the mock data with a null image to EachNews
        ),
      ),
    );

    // Verify the widget still renders without crashing
    expect(find.text('Test Title'), findsOneWidget); // Verify the title is displayed even with a null image
  });
}
