// Import necessary packages
import 'package:flutter/material.dart'; // Provides Flutter UI components
import 'package:url_launcher/url_launcher.dart'; // Enables launching URLs in a browser or app

// Define the ViewNews widget as a StatefulWidget with proper type definitions
class ViewNews extends StatefulWidget {
  final String? urlToImage; // URL of the article's image, nullable for safety
  final String url; // URL of the full article
  final String title; // Title of the article
  final String? descr; // Description of the article, nullable
  final String? content; // Full content of the article, nullable

  // Constructor to initialize the widget's properties with type safety
  const ViewNews({
    super.key,
    this.urlToImage, // Made optional since it might be null
    required this.url, // Required since it's needed for functionality
    required this.title, // Required since it's always displayed
    this.descr, // Optional description
    this.content, // Optional content
  });

  @override
  State<ViewNews> createState() => _ViewNewsState();
}

// State class for ViewNews with error handling
class _ViewNewsState extends State<ViewNews> {
  // Netflix-themed colors defined as static constants
  static const Color backgroundBlack = Color(0xFF141414); // Background color
  static const Color primaryRed = Color(0xFFE50914); // Primary button color
  static const Color cardBlack = Color(0xFF1F1F1F); // Card background color

  // Method to launch the URL with enhanced error handling
  Future<void> _launchUrl() async {
    try {
      // Validate URL before attempting to launch
      if (widget.url.isEmpty) {
        throw Exception("URL is empty"); // Handle empty URL case
      }

      final Uri url = Uri.parse(widget.url); // Parse the article URL

      // Validate if the URL is valid
      if (!url.hasScheme || (!url.isScheme('http') && !url.isScheme('https'))) {
        throw Exception("Invalid URL scheme"); // Handle invalid URL scheme
      }

      // Attempt to launch the URL with timeout
      final canLaunch = await canLaunchUrl(url).timeout(
        const Duration(seconds: 5),
        onTimeout: () => throw Exception("URL validation timed out"),
      );

      if (!canLaunch) {
        throw Exception("Cannot launch URL"); // Handle URL that cannot be launched
      }

      final launched = await launchUrl(url).timeout(
        const Duration(seconds: 10),
        onTimeout: () => throw Exception("URL launch timed out"),
      );

      if (!launched) {
        throw Exception("Failed to launch URL"); // Handle launch failure
      }
    } catch (e) {
      // Show error dialog to user
      if (mounted) { // Check if widget is still mounted
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Error'),
            content: Text('Failed to open article: ${e.toString()}'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Validate required properties early
    if (widget.title.isEmpty) {
      return const Scaffold(
        body: Center(
          child: Text('Invalid article data'),
        ),
      );
    }

    return Scaffold(
      backgroundColor: backgroundBlack, // Set the background color
      extendBodyBehindAppBar: true, // Allow the body to extend behind the AppBar
      appBar: AppBar(
        elevation: 0, // Remove shadow under the AppBar
        backgroundColor: Colors.transparent, // Make the AppBar transparent
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8), // Add padding inside the container
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.5), // Semi-transparent black background
              shape: BoxShape.circle, // Circular shape for the button
            ),
            child: const Icon(Icons.arrow_back, color: Colors.white), // Back arrow icon
          ),
          onPressed: () {
            // Safe navigation with mounted check
            if (mounted) {
              Navigator.pop(context); // Navigate back to the previous screen
            }
          },
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16), // Add margin on the right
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.5), // Semi-transparent black background
              shape: BoxShape.circle, // Circular shape for the button
            ),
            child: IconButton(
              icon: const Icon(Icons.share_outlined), // Share icon
              color: Colors.white, // Icon color
              onPressed: _launchUrl, // Launch the URL when the share button is pressed
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.zero, // Remove padding around the list
          children: [
            // Display the article's image with error handling
            Hero(
              tag: widget.url, // Tag for Hero animation
              child: Stack(
                children: [
                  ShaderMask(
                    shaderCallback: (rect) {
                      return LinearGradient(
                        begin: Alignment.topCenter, // Gradient starts from the top
                        end: Alignment.bottomCenter, // Gradient ends at the bottom
                        colors: [
                          Colors.black.withOpacity(0.3), // Light black at the top
                          Colors.black.withOpacity(0.8), // Dark black at the bottom
                        ],
                      ).createShader(rect); // Create the gradient shader
                    },
                    blendMode: BlendMode.darken, // Darken the image with the gradient
                    child: widget.urlToImage != null
                        ? Image.network(
                      widget.urlToImage!, // Fetch the image from the provided URL
                      height: 300, // Set the image height
                      width: double.infinity, // Make the image fill the width
                      fit: BoxFit.cover, // Cover the entire area without distortion
                      errorBuilder: (context, error, stackTrace) {
                        // Log error for debugging
                        debugPrint('Error loading image: $error');
                        // Return fallback UI
                        return _buildImageErrorWidget();
                      },
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        // Show loading indicator while image loads
                        return _buildImageLoadingWidget();
                      },
                    )
                        : _buildImageErrorWidget(), // Show error widget if URL is null
                  ),
                  // Display the article title over the image
                  Positioned(
                    bottom: 20, // Position near the bottom of the image
                    left: 20, // Align to the left
                    right: 20, // Align to the right
                    child: Text(
                      widget.title, // Article title
                      style: const TextStyle(
                        color: Colors.white, // Text color
                        fontSize: 24, // Font size
                        fontWeight: FontWeight.bold, // Bold font weight
                        height: 1.3, // Line height
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Article details section with error handling
            Padding(
              padding: const EdgeInsets.all(20.0), // Add padding around the content
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start, // Align content to the left
                children: [
                  // Button to read the full article
                  ElevatedButton.icon(
                    onPressed: _launchUrl, // Launch the URL when pressed
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryRed, // Button color
                      foregroundColor: Colors.white, // Text/icon color
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24, // Horizontal padding
                        vertical: 12, // Vertical padding
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8), // Rounded corners
                      ),
                    ),
                    icon: const Icon(Icons.launch, size: 18), // Launch icon
                    label: const Text(
                      "Read Full Article", // Button text
                      style: TextStyle(
                        fontSize: 16, // Font size
                        fontWeight: FontWeight.w600, // Semi-bold font weight
                      ),
                    ),
                  ),
                  const SizedBox(height: 24), // Vertical spacing
                  // Description section with null safety
                  _buildTextSection(
                    title: "Description",
                    content: widget.descr,
                    fallback: "No description available",
                  ),
                  const SizedBox(height: 24), // Vertical spacing
                  // Content section with null safety
                  _buildTextSection(
                    title: "Content",
                    content: widget.content,
                    fallback: "No content available",
                  ),
                  const SizedBox(height: 40), // Add spacing at the bottom
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper method to build image error widget
  Widget _buildImageErrorWidget() {
    return Container(
      height: 300,
      color: cardBlack,
      child: const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.image_not_supported,
            size: 50,
            color: Colors.white30,
          ),
          SizedBox(height: 8),
          Text(
            'Image not available',
            style: TextStyle(
              color: Colors.white30,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  // Helper method to build image loading widget
  Widget _buildImageLoadingWidget() {
    return Container(
      height: 300,
      color: cardBlack,
      child: const Center(
        child: CircularProgressIndicator(
          color: primaryRed,
        ),
      ),
    );
  }

  // Helper method to build text sections with proper error handling
  Widget _buildTextSection({
    required String title,
    String? content,
    required String fallback,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            color: Colors.grey[400],
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          content?.isNotEmpty == true ? content! : fallback,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            height: 1.6,
          ),
        ),
      ],
    );
  }
}