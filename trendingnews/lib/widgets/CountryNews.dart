// Import necessary Flutter and Dart packages
import 'dart:convert'; // Used for JSON decoding
import 'package:flutter/material.dart'; // Provides Flutter UI components
import 'package:http/http.dart' as http; // Enables HTTP requests
import '/services/db_helper.dart'; // Handles database operations
import '/widgets/EachNews.dart'; // Widget for displaying individual news articles
import '/widgets/FavouriteNews.dart'; // Widget for displaying favorite news
import '/widgets/FavouritesUpdate.dart'; // State management for favorites
import 'package:path/path.dart'; // Provides utilities for working with file paths
import 'package:provider/provider.dart'; // Enables state management using Provider

// Define a StatefulWidget to manage the news display
class AllNews extends StatefulWidget {
  const AllNews({super.key});

  // Declare Netflix theme colors as static constants
  static const Color netflixRed = Color(0xFFE50914);
  static const Color netflixBlack = Color(0xFF141414);
  static const Color darkGrey = Color(0xFF262626);
  static const Color white = Color(0xFFFFFFFF);
  static const Color lightGrey = Color(0xFF757575);

  // API key for accessing the news API
  final apiKey = '12044924fea84a33ab3abd8bda94fbc2';

  @override
  State<AllNews> createState() => _AllNewsState();
}

// State class for the AllNews widget
class _AllNewsState extends State<AllNews> {
  Future<List<dynamic>>? articles; // Future for storing news articles
  late int articleLength; // Stores the total number of articles
  DBHelper? dbHelper; // Instance of DBHelper for database operations
  final ScrollController _scrollController = ScrollController(); // Controls scrolling

  // Define Netflix theme colors
  static const Color netflixRed = Color(0xFFE50914); // Netflix red
  static const Color netflixBlack = Color(0xFF141414); // Netflix black
  static const Color darkGrey = Color(0xFF262626); // Dark grey
  static const Color white = Color(0xFFFFFFFF); // White
  static const Color lightGrey = Color(0xFF757575); // Light grey

  @override
  void initState() {
    super.initState();
    dbHelper = DBHelper(); // Initialize the database helper
    articles = _loadNews(); // Load news articles when the widget is initialized
  }

  // Function to fetch news from the API
  Future<List<dynamic>> _loadNews() async {
    // Make an HTTP GET request to fetch top headlines
    final response = await http.get(
      Uri.parse(
          "https://newsapi.org/v2/top-headlines?country=us&apiKey=${widget.apiKey}"),
    );

    // Decode the JSON response
    final posts = json.decode(response.body);

    // Check for errors in the response
    if (posts['status'] != 'ok') {
      throw Exception("Failed to load posts: ${posts['message']}");
    }

    // Update the total number of articles and return the articles list
    articleLength = posts['totalResults'];
    return posts['articles'];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: netflixBlack, // Set the background color
      appBar: AppBar(
        elevation: 0, // Remove shadow under the AppBar
        backgroundColor: netflixBlack, // Set AppBar background color
        title: const Text(
          "Today's Headlines", // Title for the AppBar
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            letterSpacing: -0.5,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () async {
              Future.delayed(const Duration(seconds: 2)); // Add a small delay
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => FavouriteNews(
                    results: Provider.of<FavouritesStore>(context, listen: false)
                        .results, // Pass favorite news to FavouriteNews widget
                  ),
                ),
              );
            },
            icon: const Icon(Icons.favorite), // Favorite icon
            color: netflixRed, // Icon color
            iconSize: 28, // Icon size
          ),
          const SizedBox(width: 16), // Add spacing
        ],
      ),
      body: RefreshIndicator(
        color: netflixRed, // Refresh indicator color
        backgroundColor: darkGrey, // Background color during refresh
        onRefresh: () async {
          setState(() {
            articles = _loadNews(); // Reload articles on refresh
          });
        },
        child: CustomScrollView(
          controller: _scrollController, // Attach the scroll controller
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
                child: Text(
                  'Latest Updates', // Section title
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[300],
                  ),
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0), // Add padding
              sliver: FutureBuilder<List<dynamic>>(
                future: articles, // Use the articles future
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    // If data is loaded, display the articles
                    return SliverList(
                      delegate: SliverChildBuilderDelegate(
                            (context, index) {
                          final article = snapshot.data![index];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 16.0),
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.grey[400],
                                borderRadius: BorderRadius.circular(8),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.3),
                                    spreadRadius: 0,
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: EachNews(news: article), // Display each article
                            ),
                          );
                        },
                        childCount: snapshot.data!.length, // Number of articles
                      ),
                    );
                  } else if (snapshot.hasError) {
                    // If there's an error, show an error message
                    return SliverFillRemaining(
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.error_outline, // Error icon
                              size: 60,
                              color: lightGrey,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Something went wrong\n${snapshot.error}', // Error message
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: lightGrey,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 24),
                            ElevatedButton(
                              onPressed: () {
                                setState(() {
                                  articles = _loadNews(); // Retry loading articles
                                });
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: netflixRed,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 32,
                                  vertical: 16,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                              child: const Text(
                                'Try Again', // Retry button
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  } else {
                    // If still loading, show a loading spinner
                    return const SliverFillRemaining(
                      child: Center(
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(netflixRed),
                        ),
                      ),
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
