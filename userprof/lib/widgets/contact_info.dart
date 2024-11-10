// Import necessary Flutter material design library
import 'package:flutter/material.dart';
// Import the UserInfo model from a separate file
import '../models/user_info.dart';

// ContactInfo widget definition
class ContactInfo extends StatefulWidget {
  // Properties to hold user info and update callback
  final UserInfo userInfo;
  final VoidCallback onUpdate;

  // Constructor
  const ContactInfo({super.key, required this.userInfo, required this.onUpdate});

  // Create the mutable state for this widget
  @override
  State<ContactInfo> createState() => ContactInfoState();
}

// ContactInfoState class to manage the state of ContactInfo
class ContactInfoState extends State<ContactInfo> {
  // State variables
  bool _isEditing = false;
  late TextEditingController _phoneController;
  late TextEditingController _emailController;
  late TextEditingController _address1Controller;
  late TextEditingController _address2Controller;

  // Initialize the state
  @override
  void initState() {
    super.initState();
    // Initialize text controllers with user info
    _phoneController = TextEditingController(text: widget.userInfo.phone);
    _emailController = TextEditingController(text: widget.userInfo.email);
    _address1Controller = TextEditingController(text: widget.userInfo.address1);
    _address2Controller = TextEditingController(text: widget.userInfo.address2);
  }

  // Build the widget
  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header row with title and edit/save button
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Contact Information', style: Theme.of(context).textTheme.titleLarge),
                IconButton(
                  icon: Icon(_isEditing ? Icons.save : Icons.edit),
                  onPressed: () {
                    setState(() {
                      if (_isEditing) {
                        // Save the edited information
                        widget.userInfo.phone = _phoneController.text;
                        widget.userInfo.email = _emailController.text;
                        widget.userInfo.address1 = _address1Controller.text;
                        widget.userInfo.address2 = _address2Controller.text;
                        widget.onUpdate();
                      }
                      // Toggle editing mode
                      _isEditing = !_isEditing;
                    });
                  },
                ),
              ],
            ),
            const SizedBox(height: 8),
            // Editable fields for contact information
            _buildEditableField(Icons.phone, _phoneController),
            _buildEditableField(Icons.email, _emailController),
            _buildEditableField(Icons.home, _address1Controller),
            _buildEditableField(null, _address2Controller),
          ],
        ),
      ),
    );
  }

  // Helper method to build editable fields with icons
  Widget _buildEditableField(IconData? icon, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          SizedBox(
            width: 24, // Width of an icon
            child: icon != null ? Icon(icon) : null,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _isEditing
                ? TextField(
                    controller: controller,
                    decoration: const InputDecoration(
                      border: UnderlineInputBorder(),
                    ),
                  )
                : Text(controller.text),
          ),
        ],
      ),
    );
  }
}