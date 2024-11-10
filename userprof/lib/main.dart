// Import the necessary Flutter material design library
import 'package:flutter/material.dart';

// Import the UserInfoPage from a separate file
import 'screens/user_info_page.dart';

// The main function, entry point of the Flutter app
void main() {
  // Run the app by calling runApp with an instance of MyApp
  runApp(const MyApp());
}

// MyApp class, the root widget of the application
class MyApp extends StatelessWidget {
  // Constructor with a key parameter
  const MyApp({super.key});

  // Build method to describe the part of the UI represented by this widget
  @override
  Widget build(BuildContext context) {
    // Return a MaterialApp widget, which provides many basic app features
    return MaterialApp(
      // Set the title of the app, used by the device to identify the app
      title: 'User Profile',
      
      // Define the app's theme
      theme: ThemeData(
        // Set the primary color swatch to blue
        primarySwatch: Colors.blue,
        
        // Define the input decoration theme for form fields
        inputDecorationTheme: const InputDecorationTheme(
          // Set the border to an outline
          border: OutlineInputBorder(),
          // Enable filling of the input field
          filled: true,
          // Set the fill color to a light grey
          fillColor: Color(0xFFE0E0E0),  // This is equivalent to Colors.grey[200]
        ),
      ),
      
      // Set the home page of the app to UserInfoPage
      // The userInfo is set to null, presumably to be filled later
      home: const UserInfoPage(userInfo: null),
    );
  }
}