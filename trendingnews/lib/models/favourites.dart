// Import the necessary package for advanced collection operations
import 'package:collection/collection.dart'; // Provides utilities for working with collections
import 'package:flutter/foundation.dart'; // For debugPrint and other foundation utilities

// Import the necessary file for database helper functionalities
import '/services/db_helper.dart'; // Provides database operations through the DBHelper class

/// Custom exception for Favourites-related errors
class FavouritesException implements Exception {
  final String message;
  FavouritesException(this.message);

  @override
  String toString() => 'FavouritesException: $message';
}

/// Define the Favourites class to represent a favourite news article
class Favourites {
  late int tempId; // Temporary ID to store the database-generated ID
  final String id; // Unique identifier for the favourite (required)
  final String? urlToImage; // URL of the image associated with the favourite (nullable)
  final String url; // URL of the news article (required)
  final String title; // Title of the news article (required)
  final String? descr; // Description or summary of the news article (nullable)
  final String? content; // Full content of the news article (optional)

  // Constructor to initialize the Favourites object with required and optional fields
  Favourites({
    required this.id, // Initialize `id`
    this.urlToImage, // Initialize `urlToImage` (nullable)
    required this.url, // Initialize `url`
    required this.title, // Initialize `title`
    this.descr, // Initialize `descr` (nullable)
    this.content, // Initialize `content` (optional)
  }) {
    // Validate required fields
    if (id.isEmpty) {
      throw FavouritesException('ID cannot be empty');
    }
    if (url.isEmpty) {
      throw FavouritesException('URL cannot be empty');
    }
    if (title.isEmpty) {
      throw FavouritesException('Title cannot be empty');
    }

    // Validate URL format
    try {
      final uri = Uri.parse(url);
      if (!uri.isScheme('http') && !uri.isScheme('https')) {
        throw FavouritesException('Invalid URL scheme: ${uri.scheme}');
      }
    } catch (e) {
      throw FavouritesException('Invalid URL format: $url');
    }

    // Validate image URL format if provided
    if (urlToImage != null && urlToImage!.isNotEmpty) {
      try {
        final uri = Uri.parse(urlToImage!);
        if (!uri.isScheme('http') && !uri.isScheme('https')) {
          throw FavouritesException('Invalid image URL scheme: ${uri.scheme}');
        }
      } catch (e) {
        throw FavouritesException('Invalid image URL format: $urlToImage');
      }
    }
  }

  /// Method to create a Favourites object from a map
  static Favourites fromMap(Map<String, dynamic> map) {
    try {
      return Favourites(
        id: map['id'] as String,
        urlToImage: map['urlToImage'] as String?,
        url: map['url'] as String,
        title: map['title'] as String,
        descr: map['descr'] as String?,
        content: map['content'] as String?,
      );
    } catch (e) {
      throw FavouritesException('Failed to create Favourites from map: $e');
    }
  }

  /// Convert Favourites object to a map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'urlToImage': urlToImage,
      'url': url,
      'title': title,
      'descr': descr,
      'content': content,
    };
  }

  /// Method to save the favourite to the database with error handling
  Future<void> saveDb() async {
    try {
      debugPrint("Saving favourite: $title"); // Debug log for tracking

      // Create map of data to insert
      final dataToInsert = toMap();

      // Validate data before insertion
      if (const DeepCollectionEquality().equals(dataToInsert, {})) {
        throw FavouritesException('Cannot save empty favourite data');
      }

      // Attempt to insert data into database
      tempId = await DBHelper().insertFavourites(
        'favourites', // Table name
        dataToInsert, // Map of favourite's data
      );

      debugPrint("Saved favourite with tempId: $tempId"); // Debug log for confirmation
    } catch (e) {
      // Log error and rethrow with more context
      debugPrint("Error saving favourite: $e");
      throw FavouritesException('Failed to save favourite: $e');
    }
  }

  /// Method to delete the favourite from the database with error handling
  Future<void> deleteFavourites() async {
    try {
      debugPrint("Deleting favourite with id: $id"); // Debug log for tracking

      // Validate ID before deletion
      if (id.isEmpty) {
        throw FavouritesException('Cannot delete favourite with empty ID');
      }

      // Attempt to delete from database
      await DBHelper().deleteFavourites(id);

      debugPrint("Successfully deleted favourite with id: $id"); // Debug log for confirmation
    } catch (e) {
      // Log error and rethrow with more context
      debugPrint("Error deleting favourite: $e");
      throw FavouritesException('Failed to delete favourite: $e');
    }
  }

  /// Override toString for better debugging
  @override
  String toString() {
    return 'Favourites{id: $id, title: $title, url: $url}';
  }

  /// Override equality operator
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Favourites &&
        other.id == id &&
        other.url == url &&
        other.title == title;
  }

  /// Override hashCode for proper equality comparison
  @override
  int get hashCode => Object.hash(id, url, title);
}