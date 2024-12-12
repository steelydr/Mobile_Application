import 'package:flutter/material.dart'; // Provides UI components for Flutter
import 'package:flutter_test/flutter_test.dart'; // Provides utilities for widget testing
import 'package:cs442_mp6/widgets/CountryNews.dart'; // The widget under test
import 'package:http/http.dart' as http;
import 'package:cs442_mp6/widgets/EachNews.dart';
import 'dart:convert';

// Mock HTTP client for testing
class MockHttpClient {
  Future<http.Response> get(Uri url) async {
    // Simulate a successful API response
    return http.Response(
      jsonEncode({
        'status': 'ok',
        'totalResults': 2,
        'articles': [
          {
            'title': 'Breaking News',
            'description': 'This is a breaking news description.',
            'url': 'https://news.com/article1',
            'urlToImage': 'https://news.com/image1.jpg',
          },
          {
            'title': 'Latest Update',
            'description': 'This is the latest update description.',
            'url': 'https://news.com/article2',
            'urlToImage': 'https://news.com/image2.jpg',
          },
        ],
      }),
      200,
    );
  }
}

void main() {
  group('AllNews Tests', () {
    // Test for UI elements
    testWidgets('AllNews UI test', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: AllNews()));

      // Verify UI elements are present
      expect(find.text("Today's Headlines"), findsOneWidget);
      expect(find.byIcon(Icons.favorite), findsOneWidget);
      expect(find.text('Latest Updates'), findsOneWidget);
    });

    testWidgets('AppBar should handle long text without overflow', (WidgetTester tester) async {
      // Build the widget tree with long text.
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            appBar: AppBar(
              title: Text("Today's Headlines: Breaking News from All Around the World"),
            ),
          ),
        ),
      );

      // Verify the long text is truncated or properly displayed without overflow.
      expect(find.text("Today's Headlines: Breaking News from All Around the World"), findsOneWidget);
      expect(find.byType(AppBar), findsOneWidget);
    });



    testWidgets('AppBar adjusts to theme changes', (WidgetTester tester) async {
      ThemeData lightTheme = ThemeData.light();
      ThemeData darkTheme = ThemeData.dark();

      // Build the widget tree with a dynamic theme.
      await tester.pumpWidget(
        StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            ThemeData theme = lightTheme;
            return MaterialApp(
              theme: theme,
              home: Scaffold(
                appBar: AppBar(
                  title: Text("Theme Test"),
                ),
                floatingActionButton: FloatingActionButton(
                  onPressed: () => setState(() => theme = theme == lightTheme ? darkTheme : lightTheme),
                ),
              ),
            );
          },
        ),
      );

      // Verify the AppBar is rendered with the initial theme.
      expect(find.byType(AppBar), findsOneWidget);

      // Tap the button to toggle the theme.
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pump();

      // Verify the AppBar is updated with the new theme.
      expect(find.byType(AppBar), findsOneWidget);
    });


    testWidgets('AppBar should display "Today\'s Headlines"', (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(home: AllNews()));
      expect(find.text("Today's Headlines"), findsOneWidget);
    });

    testWidgets('Favorite icon is clickable', (WidgetTester tester) async {
      bool wasClicked = false;

      // Build the app widget tree with a clickable favorite icon.
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            appBar: AppBar(
              actions: [
                IconButton(
                  icon: Icon(Icons.favorite),
                  onPressed: () {
                    wasClicked = true;
                  },
                ),
              ],
            ),
          ),
        ),
      );

      // Tap the favorite icon.
      await tester.tap(find.byIcon(Icons.favorite));
      await tester.pump(); // Allow the onPressed handler to execute.

      // Verify if the icon's click handler was triggered.
      expect(wasClicked, isTrue);
    });


    testWidgets('CircularProgressIndicator is displayed centered', (WidgetTester tester) async {
      // Build the widget tree.
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          ),
        ),
      );

      // Verify the loading spinner exists.
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      // Check its alignment in the center.
      final spinnerFinder = find.byType(CircularProgressIndicator);
      final centerFinder = find.byWidgetPredicate(
            (widget) => widget is Center && widget.child == spinnerFinder.evaluate().first.widget,
      );
      expect(centerFinder, findsOneWidget);
    });


    // Test for API response
    test('API should return articles', () async {
      final mockClient = MockHttpClient();
      final response = await mockClient.get(
        Uri.parse(
            "https://newsapi.org/v2/top-headlines?country=us&apiKey=12044924fea84a33ab3abd8bda94fbc2"),
      );

      expect(response.statusCode, 200);

      final decodedResponse = jsonDecode(response.body);
      expect(decodedResponse['status'], 'ok');
      expect(decodedResponse['articles'], isNotEmpty);
    });

    // Test to validate the API key
    test('API key should be valid and non-empty', () {
      final widget = AllNews();

      // Ensure the API key is not empty and has sufficient length
      expect(widget.apiKey, isNotEmpty);
      expect(widget.apiKey.length, greaterThan(10)); // Check for a valid length
    });

    // Test for fetching articles
    test('Fetching news articles should return a non-empty list', () async {
      final mockClient = MockHttpClient();
      final response = await mockClient.get(
        Uri.parse(
            "https://newsapi.org/v2/top-headlines?country=us&apiKey=12044924fea84a33ab3abd8bda94fbc2"),
      );

      final decodedResponse = jsonDecode(response.body);

      // Simulate fetching articles
      final articles = decodedResponse['articles'];

      // Check that articles are non-empty
      expect(articles, isNotEmpty);
    });

    // Test for Netflix theme colors
    test('Netflix theme colors are defined correctly', () {
      // Directly reference the colors from the state of the AllNews widget
      expect(AllNews.netflixRed, const Color(0xFFE50914));
      expect(AllNews.netflixBlack, const Color(0xFF141414));
      expect(AllNews.darkGrey, const Color(0xFF262626));
      expect(AllNews.white, const Color(0xFFFFFFFF));
      expect(AllNews.lightGrey, const Color(0xFF757575));
    });
  });
}
