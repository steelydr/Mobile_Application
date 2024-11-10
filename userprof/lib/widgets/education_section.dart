import 'package:flutter/material.dart';
import '../models/user_info.dart';

// EducationSection widget definition
class EducationSection extends StatefulWidget {
  // List of Education objects to display
  final List<Education> education;
  // Callback function to notify parent widget of updates
  final VoidCallback onUpdate;

  // Constructor
  const EducationSection({super.key, required this.education, required this.onUpdate});

  @override
  State<EducationSection> createState() => EducationSectionState();
}

// EducationSectionState class to manage the state of EducationSection
class EducationSectionState extends State<EducationSection> {
  // Flag to toggle between view and edit modes
  bool _isEditing = false;

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
                Text('Education', style: Theme.of(context).textTheme.titleLarge),
                IconButton(
                  icon: Icon(_isEditing ? Icons.save : Icons.edit),
                  onPressed: () {
                    setState(() {
                      _isEditing = !_isEditing;
                      if (!_isEditing) {
                        // Notify parent widget of updates when saving
                        widget.onUpdate();
                      }
                    });
                  },
                ),
              ],
            ),
            const SizedBox(height: 8),
            // Map each Education object to a tile widget
            ...widget.education.map(_buildEducationTile),
            // Show 'Add Education' button when in edit mode
            if (_isEditing)
              ElevatedButton.icon(
                onPressed: _addEducation,
                icon: const Icon(Icons.add),
                label: const Text('Add Education'),
              ),
          ],
        ),
      ),
    );
  }

  // Helper method to build a tile for each Education object
  Widget _buildEducationTile(Education edu) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // School logo
            Image.asset(edu.logo, width: 40, height: 40),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // School name (editable when in edit mode)
                  _isEditing
                      ? TextField(
                          controller: TextEditingController(text: edu.name),
                          onChanged: (value) => edu.name = value,
                          decoration: const InputDecoration(labelText: 'School Name'),
                        )
                      : Text(edu.name, style: Theme.of(context).textTheme.titleMedium),
                  // Degree (editable when in edit mode)
                  _isEditing
                      ? TextField(
                          controller: TextEditingController(text: edu.degree),
                          onChanged: (value) => edu.degree = value,
                          decoration: const InputDecoration(labelText: 'Degree'),
                        )
                      : Text(edu.degree, style: Theme.of(context).textTheme.bodyMedium),
                ],
              ),
            ),
            const SizedBox(width: 16),
            // GPA section
            SizedBox(
              width: 60,
              child: _isEditing
                  ? TextField(
                      controller: TextEditingController(text: edu.gpa.toString()),
                      onChanged: (value) => edu.gpa = double.tryParse(value) ?? edu.gpa,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'GPA'),
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          edu.gpa.toStringAsFixed(2),
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        Text(
                          'GPA',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
            ),
            // Delete button (visible only in edit mode)
            if (_isEditing)
              IconButton(
                icon: const Icon(Icons.delete),
                onPressed: () => _deleteEducation(edu),
              ),
          ],
        ),
      ),
    );
  }

  // Method to add a new Education object
  void _addEducation() {
    setState(() {
      widget.education.add(Education(
        logo: 'assets/images/default-school-logo.png',
        name: 'New School',
        gpa: 0.0,
        degree: 'New Degree'
      ));
    });
  }

  // Method to delete an Education object
  void _deleteEducation(Education edu) {
    setState(() {
      widget.education.remove(edu);
    });
  }
}