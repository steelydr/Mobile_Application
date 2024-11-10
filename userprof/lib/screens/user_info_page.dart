// Import necessary Flutter material design library
import 'package:flutter/material.dart';
// Import the UserInfo model
import '../models/user_info.dart';
// Import custom widgets for different sections of the page
import '../widgets/profile_header.dart';
import '../widgets/contact_info.dart';
import '../widgets/education_section.dart';
import '../widgets/projects_section.dart';

// UserInfoPage widget definition
class UserInfoPage extends StatefulWidget {
  // Property to hold user info, which can be null
  final UserInfo? userInfo;

  // Constructor
  const UserInfoPage({super.key, required this.userInfo});

  // Create the mutable state for this widget
  @override
  State<UserInfoPage> createState() => UserInfoPageState();
}

// UserInfoPageState class to manage the state of UserInfoPage
class UserInfoPageState extends State<UserInfoPage> {
  // Late initialized UserInfo object
  late UserInfo userInfo;

  // Initialize the state
  @override
  void initState() {
    super.initState();
    // If userInfo is provided, use it; otherwise, create a dummy user
    userInfo = widget.userInfo ?? UserInfo.createDummy();
  }

  // Method to update the user info and trigger a rebuild
  void _updateUserInfo() {
    setState(() {});
  }

  // Build the widget
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // App bar with the user's name as the title
      appBar: AppBar(title: Text(userInfo.name)),
      // Body of the page is a ListView containing various sections
      body: ListView(
        children: [
          // Profile header section
          ProfileHeader(userInfo: userInfo, onUpdate: _updateUserInfo),
          // Contact information section
          ContactInfo(userInfo: userInfo, onUpdate: _updateUserInfo),
          // Education section
          EducationSection(education: userInfo.education, onUpdate: _updateUserInfo),
          // Projects section
          ProjectsSection(projects: userInfo.projects, onUpdate: _updateUserInfo),
        ],
      ),
    );
  }
}