import 'package:flutter/material.dart'; // Import Flutter material package for UI components
import '../models/deck.dart'; // Import the Deck model

// Define a StatefulWidget named DeckEditor, which takes an optional Deck, a save function, and an optional delete function
class DeckEditor extends StatefulWidget {
  final Deck? deck; // Optional Deck object for editing
  final Function(Deck) onSave; // Callback function for saving the deck
  final Function(int)? onDelete; // Optional callback function for deleting the deck

  // Constructor for DeckEditor with optional and required parameters
  const DeckEditor({
    this.deck,
    required this.onSave,
    this.onDelete,
  });

  // Create the state for this widget
  @override
  _DeckEditorState createState() => _DeckEditorState(); // Return a new instance of the state
}

// Define the state class for DeckEditor
class _DeckEditorState extends State<DeckEditor> {
  late TextEditingController _titleController; // Controller for the deck title input

  // Helper method to get dimensions and styles based on orientation and screen size
  Map<String, dynamic> _getResponsiveDesign(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width; // Get the screen width
    final screenHeight = MediaQuery.of(context).size.height; // Get the screen height
    final orientation = MediaQuery.of(context).orientation; // Get the screen orientation
    final isSmallScreen = screenWidth < 360; // Check if the screen width is small

    // Responsive design settings for portrait orientation
    if (orientation == Orientation.portrait) {
      return {
        'padding': EdgeInsets.symmetric( // Padding for the container
          horizontal: screenWidth * 0.08,
          vertical: screenHeight * 0.03,
        ),
        'titleFontSize': isSmallScreen ? 18.0 : 20.0, // Font size for title based on screen size
        'inputWidth': screenWidth * 0.85, // Width for input fields
        'inputHeight': 56.0, // Height for input fields
        'buttonWidth': screenWidth * 0.5, // Width for buttons
        'buttonHeight': 48.0, // Height for buttons
        'buttonFontSize': isSmallScreen ? 16.0 : 18.0, // Font size for button text based on screen size
        'spacing': screenHeight * 0.02, // Spacing between elements
        'inputFontSize': isSmallScreen ? 16.0 : 18.0, // Font size for input fields
        'labelFontSize': isSmallScreen ? 14.0 : 16.0, // Font size for labels
      };
    } else {
      // Responsive design settings for landscape orientation
      return {
        'padding': EdgeInsets.symmetric( // Padding for the container
          horizontal: screenWidth * 0.15,
          vertical: screenHeight * 0.05,
        ),
        'titleFontSize': 18.0, // Font size for title
        'inputWidth': screenWidth * 0.7, // Width for input fields
        'inputHeight': 48.0, // Height for input fields
        'buttonWidth': screenWidth * 0.3, // Width for buttons
        'buttonHeight': 40.0, // Height for buttons
        'buttonFontSize': 16.0, // Font size for button text
        'spacing': screenHeight * 0.03, // Spacing between elements
        'inputFontSize': 16.0, // Font size for input fields
        'labelFontSize': 14.0, // Font size for labels
      };
    }
  }

  @override
  void initState() {
    super.initState(); // Call the superclass method
    _titleController = TextEditingController(text: widget.deck?.title ?? ''); // Initialize text controller with existing deck title or empty string
  }

  @override
  void dispose() {
    _titleController.dispose(); // Dispose of the title controller
    super.dispose(); // Call the superclass method
  }

  @override
  Widget build(BuildContext context) {
    final design = _getResponsiveDesign(context); // Get responsive design settings
    final orientation = MediaQuery.of(context).orientation; // Get screen orientation

    // Build the main scaffold for the DeckEditor
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.deck == null ? 'New Deck' : 'Edit Deck', // Title based on whether a deck is being edited or created
          style: TextStyle(
            fontSize: design['titleFontSize'], // Title font size
            fontWeight: FontWeight.bold, // Bold font weight for title
          ),
        ),
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back, // Back icon
            size: orientation == Orientation.portrait ? 24 : 22, // Icon size based on orientation
          ),
          onPressed: () => Navigator.of(context).pop(), // Go back on button press
        ),
        actions: [
          // Delete button (only if editing an existing deck)
          if (widget.deck != null && widget.onDelete != null)
            IconButton(
              icon: Icon(
                Icons.delete, // Delete icon
                size: orientation == Orientation.portrait ? 24 : 22, // Icon size based on orientation
              ),
              onPressed: () async {
                // Show confirmation dialog for deletion
                final bool? confirm = await showDialog<bool>(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: Text(
                        'Delete Deck', // Title of the dialog
                        style: TextStyle(fontSize: design['titleFontSize']), // Title font size
                      ),
                      content: Text(
                        'Are you sure you want to delete this deck?', // Content message
                        style: TextStyle(fontSize: design['labelFontSize']), // Content font size
                      ),
                      actions: [
                        // Cancel button
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(false), // Close dialog without action
                          child: Text(
                            'Cancel', // Cancel button text
                            style: TextStyle(fontSize: design['labelFontSize']), // Button font size
                          ),
                        ),
                        // Delete button
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(true), // Close dialog with delete confirmation
                          child: Text(
                            'Delete', // Delete button text
                            style: TextStyle(
                              fontSize: design['labelFontSize'], // Button font size
                              color: Colors.red, // Button text color
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                );

                // If confirmed, delete the deck
                if (confirm == true) {
                  await widget.onDelete!(widget.deck!.id!); // Call the delete function with the deck ID
                  Navigator.of(context).pop(); // Go back to the previous screen
                }
              },
            ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: design['padding'], // Padding for the main content
            child: Center(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center, // Center alignment for child elements
                children: [
                  // TextField for deck title input
                  Container(
                    width: design['inputWidth'], // Input field width
                    height: design['inputHeight'], // Input field height
                    child: TextField(
                      controller: _titleController, // Controller for title input
                      style: TextStyle(fontSize: design['inputFontSize']), // Input text style
                      decoration: InputDecoration(
                        labelText: 'Deck Title', // Label for the input field
                        labelStyle: TextStyle(fontSize: design['labelFontSize']), // Label font size
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8), // Rounded corners for border
                        ),
                        contentPadding: EdgeInsets.symmetric( // Padding inside the input field
                          horizontal: 16,
                          vertical: orientation == Orientation.portrait ? 16 : 12,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: design['spacing']), // Spacing below the input field
                  // Save button
                  Container(
                    width: design['buttonWidth'], // Button width
                    height: design['buttonHeight'], // Button height
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8), // Rounded corners for button
                        ),
                        elevation: 2, // Shadow elevation for button
                      ),
                      onPressed: () {
                        // Check if the title is empty
                        if (_titleController.text.trim().isEmpty) {
                          // Show a Snackbar if the title is empty
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Please enter a deck title', // Snackbar message
                                style: TextStyle(fontSize: design['labelFontSize']), // Message font size
                              ),
                              behavior: SnackBarBehavior.floating, // Floating Snackbar
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8), // Rounded corners
                              ),
                            ),
                          );
                          return; // Exit if title is empty
                        }

                        // Create a new Deck object with the title
                        final deck = Deck(
                          id: widget.deck?.id, // Set the ID if editing
                          title: _titleController.text.trim(), // Get trimmed title text
                        );
                        widget.onSave(deck); // Call the onSave function with the deck
                        Navigator.of(context).pop(); // Go back to the previous screen
                      },
                      child: Text(
                        'Save', // Button text
                        style: TextStyle(
                          fontSize: design['buttonFontSize'], // Button font size
                          fontWeight: FontWeight.bold, // Bold font weight for button text
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
