// Import necessary Flutter material design library
import 'package:flutter/material.dart';
// Import the UserInfo model from a separate file
import '../models/user_info.dart';

// ProfileHeader widget definition
class ProfileHeader extends StatefulWidget {
  // Properties to hold user info and update callback
  final UserInfo userInfo;
  final VoidCallback onUpdate;

  // Constructor
  const ProfileHeader({super.key, required this.userInfo, required this.onUpdate});

  // Create the mutable state for this widget
  @override
  State<ProfileHeader> createState() => ProfileHeaderState();
}

// ProfileHeaderState class to manage the state of ProfileHeader
class ProfileHeaderState extends State<ProfileHeader> {
  // State variables
  bool _isEditing = false;
  late TextEditingController _nameController;
  late TextEditingController _positionController;
  late TextEditingController _companyController;

  // Initialize the state
  @override
  void initState() {
    super.initState();
    // Initialize text controllers with user info
    _nameController = TextEditingController(text: widget.userInfo.name);
    _positionController = TextEditingController(text: widget.userInfo.position);
    _companyController = TextEditingController(text: widget.userInfo.company);
  }

  // Build the widget
  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Header row with title and edit/save button
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Profile', style: Theme.of(context).textTheme.titleLarge),
                IconButton(
                  icon: Icon(_isEditing ? Icons.save : Icons.edit),
                  onPressed: () {
                    setState(() {
                      if (_isEditing) {
                        // Save the edited information
                        widget.userInfo.name = _nameController.text;
                        widget.userInfo.position = _positionController.text;
                        widget.userInfo.company = _companyController.text;
                        widget.onUpdate();
                      }
                      // Toggle editing mode
                      _isEditing = !_isEditing;
                    });
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Profile information row
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Profile picture
                const CircleAvatar(
                  radius: 50,
                  backgroundImage: AssetImage('assets/images/profile-picture.jpg'),
                ),
                const SizedBox(width: 16),
                // Editable user information fields
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildEditableField(_nameController),
                      _buildEditableField(_positionController),
                      _buildEditableField(_companyController),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Helper method to build editable fields
  Widget _buildEditableField(TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: _isEditing
          ? TextField(
              controller: controller,
            )
          : Text(controller.text),
    );
  }
}