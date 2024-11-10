import 'package:flutter/material.dart';
import '../models/user_info.dart';

// ProjectsSection widget definition
class ProjectsSection extends StatefulWidget {
  // List of ProjectInfo objects to display
  final List<ProjectInfo> projects;
  // Callback function to notify parent widget of updates
  final VoidCallback onUpdate;

  // Constructor
  const ProjectsSection({super.key, required this.projects, required this.onUpdate});

  @override
  State<ProjectsSection> createState() => ProjectsSectionState();
}

// ProjectsSectionState class to manage the state of ProjectsSection
class ProjectsSectionState extends State<ProjectsSection> {
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
                Text('Projects', style: Theme.of(context).textTheme.titleLarge),
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
            const SizedBox(height: 16),
            // Grid view of project cards
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
                childAspectRatio: 0.75, // Adjust this value to change the card height
              ),
              itemCount: widget.projects.length + (_isEditing ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == widget.projects.length && _isEditing) {
                  return _buildAddProjectCard();
                }
                return _buildProjectCard(widget.projects[index]);
              },
            ),
          ],
        ),
      ),
    );
  }

  // Helper method to build a card for each ProjectInfo object
  Widget _buildProjectCard(ProjectInfo project) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Project name (editable when in edit mode)
            _isEditing
                ? TextField(
                    controller: TextEditingController(text: project.name),
                    onChanged: (value) => project.name = value,
                    decoration: const InputDecoration(labelText: 'Name'),
                    style: const TextStyle(fontSize: 12),
                  )
                : Text(
                    project.name,
                    style: Theme.of(context).textTheme.titleSmall,
                    overflow: TextOverflow.ellipsis,
                  ),
            const SizedBox(height: 4),
            // Project description (editable when in edit mode)
            Expanded(
              child: _isEditing
                  ? TextField(
                      controller: TextEditingController(text: project.description),
                      onChanged: (value) => project.description = value,
                      maxLines: null,
                      decoration: const InputDecoration(labelText: 'Description'),
                      style: const TextStyle(fontSize: 10),
                    )
                  : Text(
                      project.description,
                      style: const TextStyle(fontSize: 10),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 3,
                    ),
            ),
            // Delete button (visible only in edit mode)
            if (_isEditing)
              Align(
                alignment: Alignment.centerRight,
                child: IconButton(
                  icon: const Icon(Icons.delete, size: 16),
                  onPressed: () => _deleteProject(project),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // Helper method to build the 'Add Project' card
  Widget _buildAddProjectCard() {
    return Card(
      child: InkWell(
        onTap: _addProject,
        child: const Center(
          child: Icon(Icons.add, size: 24),
        ),
      ),
    );
  }

  // Method to add a new ProjectInfo object
  void _addProject() {
    setState(() {
      widget.projects.add(ProjectInfo(
        name: 'New Project',
        description: 'Project Description',
      ));
    });
  }

  // Method to delete a ProjectInfo object
  void _deleteProject(ProjectInfo project) {
    setState(() {
      widget.projects.remove(project);
    });
  }
}