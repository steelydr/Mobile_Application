// Import necessary packages and models
import 'package:flutter/material.dart'; // Provides Flutter UI components
import '/models/favourites.dart'; // Model for handling favorites
import '/services/db_helper.dart'; // Database helper for managing favorites in SQLite
import '/widgets/FavouritesUpdate.dart'; // State management for favorites
import '/widgets/ViewNews.dart'; // Widget to display detailed news content
import 'package:provider/provider.dart'; // Enables state management using Provider

// Define EachNews widget as a StatefulWidget
class EachNews extends StatefulWidget {
  // Properties for the news data and visibility of favorite icon
  dynamic news;
  bool show;

  // Constructor to initialize properties
  EachNews({super.key, required this.news, this.show = true});

  @override
  State<EachNews> createState() => _EachNewsState();
}

// State class for EachNews
class _EachNewsState extends State<EachNews> {
  Color iconColor = Colors.grey; // Initial color for the favorite icon
  DBHelper? dbHelper; // Database helper instance
  late Favourites favs; // Instance of the Favourites model

  // Netflix theme colors
  static const Color primaryRed = Color(0xFFE50914); // Red color for highlights
  static const Color starColor = Color(0xFFFFB800); // Yellow color for the star icon

  @override
  void initState() {
    super.initState();
    // Check if the news is already a favorite and set the icon color
    List ids = Provider.of<FavouritesStore>(context, listen: false).Ids;
    iconColor = ids.contains(widget.news['publishedAt']) ? starColor : Colors.grey.shade600;
    dbHelper = DBHelper(); // Initialize the database helper
  }

  // Method to add the news to favorites
  void _addFav() {
    favs = Favourites(
      id: widget.news['publishedAt'], // Unique ID for the news
      urlToImage: widget.news['urlToImage'], // URL of the news image
      url: widget.news['url'], // URL of the news article
      title: widget.news['title'], // Title of the news
      descr: widget.news['description'], // Description of the news
      content: widget.news['content'], // Content of the news
    );
    favs.saveDb(); // Save the news to the database
    Provider.of<FavouritesStore>(context, listen: false).retriveDB(); // Update the favorites list
  }

  // Method to remove the news from favorites
  void _removeFav() {
    favs = Favourites(
      id: widget.news['publishedAt'],
      urlToImage: widget.news['urlToImage'],
      url: widget.news['url'],
      title: widget.news['title'],
      descr: widget.news['description'],
      content: widget.news['content'],
    );
    favs.deleteFavourites(); // Delete the news from the database
    Provider.of<FavouritesStore>(context, listen: false).retriveDB(); // Update the favorites list
  }

  @override
  Widget build(BuildContext context) {
    // Check if the news content is valid before rendering
    if (widget.news['content'] != null && widget.news['content'] != '[Removed]') {
      return Container(
        margin: const EdgeInsets.symmetric(vertical: 4), // Add vertical margin
        child: Material(
          color: Colors.transparent, // Transparent background
          child: InkWell(
            borderRadius: BorderRadius.circular(12), // Rounded corners
            onTap: () {
              // Navigate to the detailed news view
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => ViewNews(
                    urlToImage: widget.news['urlToImage'],
                    url: widget.news['url'],
                    title: widget.news['title'],
                    descr: widget.news['description'],
                    content: widget.news['content'],
                  ),
                ),
              );
            },
            child: Padding(
              padding: const EdgeInsets.all(16.0), // Add padding around the content
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start, // Align content at the top
                children: [
                  if (widget.news['urlToImage'] != null) // Display image if available
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8), // Rounded image corners
                      child: Image.network(
                        widget.news['urlToImage'], // Fetch image from the URL
                        width: 100, // Set image width
                        height: 75, // Set image height
                        fit: BoxFit.cover, // Cover the area without distortion
                        errorBuilder: (context, error, stackTrace) {
                          // Display fallback UI if the image fails to load
                          return Container(
                            width: 100,
                            height: 75,
                            color: Colors.grey.shade800,
                            child: const Icon(Icons.image_not_supported, color: Colors.white54),
                          );
                        },
                      ),
                    ),
                  const SizedBox(width: 16), // Add horizontal spacing
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start, // Align text to the left
                      children: [
                        // Display the news title
                        Text(
                          "${widget.news['title']}",
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            height: 1.3,
                          ),
                          maxLines: 2, // Limit title to two lines
                          overflow: TextOverflow.ellipsis, // Add ellipsis if text overflows
                        ),
                        const SizedBox(height: 8), // Add vertical spacing
                        // Display the news description
                        Text(
                          "${widget.news['description']}",
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 14,
                            height: 1.4,
                          ),
                          maxLines: 2, // Limit description to two lines
                          overflow: TextOverflow.ellipsis, // Add ellipsis if text overflows
                        ),
                      ],
                    ),
                  ),
                  // Show favorite icon only if `show` is true
                  if (widget.show) ...[
                    const SizedBox(width: 12), // Add spacing before the icon
                    IconButton(
                      icon: Icon(
                        iconColor == starColor ? Icons.star : Icons.star_border, // Change icon based on favorite state
                        size: 22, // Icon size
                      ),
                      onPressed: () {
                        // Toggle favorite state with a delay for smooth UX
                        Future.delayed(const Duration(milliseconds: 200), () {
                          setState(() {
                            iconColor == starColor ? _removeFav() : _addFav(); // Add or remove from favorites
                          });
                          iconColor = iconColor == starColor ? Colors.grey.shade600 : starColor; // Update icon color
                        });
                      },
                      color: iconColor, // Set icon color
                      splashRadius: 24, // Set the splash radius
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      );
    } else {
      return const SizedBox(); // Return an empty widget if content is invalid
    }
  }
}
