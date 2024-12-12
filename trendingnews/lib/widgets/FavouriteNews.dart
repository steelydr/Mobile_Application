// Import necessary packages and utilities
import 'package:flutter/material.dart'; // Provides Flutter UI components
import '/services/db_helper.dart'; // Database helper for managing saved articles
import 'EachNews.dart'; // Widget for displaying individual news articles

// Define FavouriteNews widget as a StatefulWidget
class FavouriteNews extends StatefulWidget {
  List<Map<String, dynamic>> results; // List of saved articles passed to this widget
  FavouriteNews({super.key, required this.results}); // Constructor to initialize `results`

  @override
  State<FavouriteNews> createState() => _FavouriteNewsState();
}

// State class for FavouriteNews
class _FavouriteNewsState extends State<FavouriteNews> {
  List<dynamic>? articles; // List to store articles
  DBHelper? dbHelper; // Instance of the database helper

  // Netflix theme colors for the UI
  static const Color backgroundBlack = Color(0xFF141414); // Background color
  static const Color cardBlack = Color(0xFF1F1F1F); // Card background color
  static const Color borderColor = Color(0xFF2A2A2A); // Border color

  @override
  void initState() {
    super.initState();
    dbHelper = DBHelper(); // Initialize the database helper
    _loadNews(); // Load saved articles
  }

  // Function to convert saved results into article format
  Future<void> _loadNews() async {
    articles = List.generate(widget.results.length, (index) => {
      'urlToImage': widget.results[index]['urlToImage'], // Image URL
      'url': widget.results[index]['url'], // Article URL
      'title': widget.results[index]['title'], // Title
      'description': widget.results[index]['descr'], // Description
      'content': widget.results[index]['content'], // Content
      'publishedAt': widget.results[index]['id'], // Published date (unique ID)
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundBlack, // Set background color
      appBar: AppBar(
        elevation: 0, // Remove shadow
        backgroundColor: backgroundBlack, // AppBar background color
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white), // Back button
          onPressed: () => Navigator.pop(context), // Navigate back
        ),
        title: const Text(
          "My List", // Title of the screen
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w600,
            color: Colors.white,
            letterSpacing: 0.2,
          ),
        ),
        centerTitle: true, // Center the title
      ),
      // Display content based on whether there are saved articles
      body: articles == null || articles!.isEmpty
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center, // Center content
          children: [
            Icon(
              Icons.bookmark_outline, // Bookmark icon for empty state
              size: 64,
              color: Colors.grey[700], // Icon color
            ),
            const SizedBox(height: 16), // Vertical spacing
            Text(
              "No saved articles yet", // Empty state message
              style: TextStyle(
                color: Colors.grey[400], // Text color
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8), // Vertical spacing
            Text(
              "Articles you save will appear here", // Sub-message
              style: TextStyle(
                color: Colors.grey[600], // Sub-message text color
                fontSize: 14,
              ),
            ),
          ],
        ),
      )
          : CustomScrollView(
        slivers: [
          // Header displaying the number of saved articles and sorting filter
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 0), // Padding for the header
            sliver: SliverToBoxAdapter(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween, // Space between elements
                children: [
                  Text(
                    "${articles!.length} Saved", // Display number of saved articles
                    style: const TextStyle(
                      color: Colors.white, // Text color
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  // Sorting filter (e.g., "Recent")
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12, // Horizontal padding
                      vertical: 6, // Vertical padding
                    ),
                    decoration: BoxDecoration(
                      color: cardBlack, // Card background color
                      borderRadius: BorderRadius.circular(20), // Rounded corners
                      border: Border.all(color: borderColor), // Border
                    ),
                    child: Row(
                      children: const [
                        Icon(
                          Icons.access_time, // Clock icon
                          size: 16,
                          color: Colors.white, // Icon color
                        ),
                        SizedBox(width: 4), // Spacing between icon and text
                        Text(
                          'Recent', // Sorting text
                          style: TextStyle(
                            color: Colors.white, // Text color
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          // List of saved articles
          SliverPadding(
            padding: const EdgeInsets.all(20), // Padding around the list
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                    (context, index) {
                  final article = articles![index]; // Get the article data
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16), // Padding between cards
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[400], // Card background color
                        borderRadius: BorderRadius.circular(12), // Rounded corners
                        border: Border.all(color: borderColor), // Border
                      ),
                      child: EachNews(news: article, show: false), // Display individual article
                    ),
                  );
                },
                childCount: articles!.length, // Number of articles to display
              ),
            ),
          ),
        ],
      ),
    );
  }
}
