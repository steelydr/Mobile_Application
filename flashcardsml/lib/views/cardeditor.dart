import 'package:flutter/material.dart'; // Import Flutter material package for UI components
import '../models/deck.dart'; // Import the Flashcard model
import '../services/deckdatabase.dart'; // Import the DeckDatabase service for database operations

// Define a StatefulWidget named CardEditor, which takes an optional Flashcard and a required deckId
class CardEditor extends StatefulWidget {
  final Flashcard? flashcard; // Optional Flashcard object for editing
  final int deckId; // Required deck ID for associating the flashcard

  // Constructor for CardEditor with optional and required parameters
  const CardEditor({
    Key? key,
    this.flashcard,
    required this.deckId,
  }) : super(key: key); // Call the superclass constructor

  // Create the state for this widget
  @override
  _CardEditorState createState() => _CardEditorState(); // Return a new instance of the state
}

// Define the state class for CardEditor
class _CardEditorState extends State<CardEditor> {
  late TextEditingController _questionController; // Controller for the question input
  late TextEditingController _answerController; // Controller for the answer input
  bool _isEditing = false; // Flag to determine if the widget is in editing mode

  // Helper method to get responsive dimensions and styles based on screen size
  Map<String, dynamic> _getResponsiveDesign(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width; // Get the screen width
    final screenHeight = MediaQuery.of(context).size.height; // Get the screen height
    final orientation = MediaQuery.of(context).orientation; // Get the screen orientation
    final isSmallScreen = screenWidth < 360; // Check if the screen width is small

    // Responsive design settings for portrait orientation
    if (orientation == Orientation.portrait) {
      return {
        'containerPadding': EdgeInsets.symmetric( // Padding for the container
          horizontal: screenWidth * 0.08,
          vertical: screenHeight * 0.03,
        ),
        'inputWidth': screenWidth * 0.85, // Width for input fields
        'inputHeight': 56.0, // Height for input fields
        'inputSpacing': screenHeight * 0.025, // Spacing between input fields
        'buttonSpacing': screenHeight * 0.03, // Spacing between buttons
        'buttonWidth': screenWidth * 0.35, // Width for buttons
        'buttonHeight': 48.0, // Height for buttons
        'titleFontSize': isSmallScreen ? 18.0 : 20.0, // Font size for title based on screen size
        'inputFontSize': isSmallScreen ? 16.0 : 18.0, // Font size for input fields
        'labelFontSize': isSmallScreen ? 14.0 : 16.0, // Font size for labels
        'buttonFontSize': isSmallScreen ? 16.0 : 18.0, // Font size for button text
        'buttonPadding': EdgeInsets.symmetric( // Padding for buttons
          horizontal: 24,
          vertical: 12,
        ),
      };
    } else {
      // Responsive design settings for landscape orientation
      return {
        'containerPadding': EdgeInsets.symmetric( // Padding for the container
          horizontal: screenWidth * 0.15,
          vertical: screenHeight * 0.05,
        ),
        'inputWidth': screenWidth * 0.7, // Width for input fields
        'inputHeight': 48.0, // Height for input fields
        'inputSpacing': screenHeight * 0.03, // Spacing between input fields
        'buttonSpacing': screenHeight * 0.04, // Spacing between buttons
        'buttonWidth': screenWidth * 0.25, // Width for buttons
        'buttonHeight': 40.0, // Height for buttons
        'titleFontSize': 18.0, // Font size for title
        'inputFontSize': 16.0, // Font size for input fields
        'labelFontSize': 14.0, // Font size for labels
        'buttonFontSize': 16.0, // Font size for button text
        'buttonPadding': EdgeInsets.symmetric( // Padding for buttons
          horizontal: 20,
          vertical: 10,
        ),
      };
    }
  }

  @override
  void initState() {
    super.initState(); // Call the superclass method
    _isEditing = widget.flashcard != null; // Check if we are editing an existing card
    // Initialize text controllers with existing flashcard data or empty strings
    _questionController = TextEditingController(text: widget.flashcard?.question ?? '');
    _answerController = TextEditingController(text: widget.flashcard?.answer ?? '');
  }

  @override
  void dispose() {
    _questionController.dispose(); // Dispose of the question controller
    _answerController.dispose(); // Dispose of the answer controller
    super.dispose(); // Call the superclass method
  }

  // Method to save the flashcard
  Future<void> _saveCard() async {
    // Check if inputs are empty and show a Snackbar if they are
    if (_questionController.text.trim().isEmpty || _answerController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please fill in both question and answer'), // Snackbar message
          behavior: SnackBarBehavior.floating, // Floating Snackbar
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)), // Rounded corners
        ),
      );
      return; // Exit if fields are empty
    }

    // Create a Flashcard object with the input values
    final flashcard = Flashcard(
      id: widget.flashcard?.id, // Set the ID if editing
      deckId: widget.deckId, // Set the deck ID
      question: _questionController.text.trim(), // Get trimmed question text
      answer: _answerController.text.trim(), // Get trimmed answer text
      createdAt: widget.flashcard?.createdAt ?? DateTime.now(), // Set creation date
    );

    // Try to save the flashcard to the database
    try {
      if (_isEditing) {
        await DeckDatabase.instance.updateFlashcard(flashcard); // Update if editing
      } else {
        await DeckDatabase.instance.insertFlashcard(flashcard); // Insert if creating
      }
      Navigator.pop(context, true); // Go back to the previous screen with success
    } catch (e) {
      // Show error Snackbar if saving fails
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error saving card: $e'), // Snackbar message with error
          behavior: SnackBarBehavior.floating, // Floating Snackbar
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)), // Rounded corners
        ),
      );
    }
  }

  // Method to delete the flashcard
  Future<void> _deleteCard() async {
    // Show confirmation dialog for deletion
    final bool? confirmDelete = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        final design = _getResponsiveDesign(context); // Get responsive design settings
        return AlertDialog(
          title: Text(
            'Delete Card', // Title of the dialog
            style: TextStyle(fontSize: design['titleFontSize']), // Title font size
          ),
          content: Text(
            'Are you sure you want to delete this card?', // Content message
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

    // If confirmed, delete the flashcard
    if (confirmDelete == true && widget.flashcard != null) {
      try {
        await DeckDatabase.instance.deleteFlashcard(widget.flashcard!.id!); // Delete the card
        Navigator.pop(context, true); // Go back with success
      } catch (e) {
        // Show error Snackbar if deletion fails
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error deleting card: $e'), // Snackbar message with error
            behavior: SnackBarBehavior.floating, // Floating Snackbar
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)), // Rounded corners
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final design = _getResponsiveDesign(context); // Get responsive design settings
    final orientation = MediaQuery.of(context).orientation; // Get screen orientation

    // Build the main scaffold for the CardEditor
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _isEditing ? 'Edit Card' : 'Create Card', // Title based on editing state
          style: TextStyle(
            color: Colors.black, // Title text color
            fontSize: design['titleFontSize'], // Title font size
          ),
        ),
        backgroundColor: Colors.white, // AppBar background color
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back, // Back icon
            size: orientation == Orientation.portrait ? 24 : 22, // Icon size based on orientation
          ),
          onPressed: () => Navigator.of(context).pop(), // Go back on button press
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            color: Colors.white, // Background color of the body
            padding: design['containerPadding'], // Padding for the container
            child: Center(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center, // Center alignment for child elements
                children: [
                  // TextField for question input
                  Container(
                    width: design['inputWidth'], // Input field width
                    height: design['inputHeight'], // Input field height
                    child: TextField(
                      controller: _questionController, // Controller for question input
                      style: TextStyle(
                        color: Colors.black, // Input text color
                        fontSize: design['inputFontSize'], // Input font size
                      ),
                      decoration: InputDecoration(
                        labelText: 'Question', // Label for the input field
                        labelStyle: TextStyle(
                          color: Colors.blueAccent, // Label text color
                          fontSize: design['labelFontSize'], // Label font size
                        ),
                        filled: true, // Enable fill color
                        fillColor: Colors.white, // Fill color for input field
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.0), // Rounded corners for border
                          borderSide: BorderSide(color: Colors.blueAccent), // Border color
                        ),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 16, // Horizontal padding inside input
                          vertical: orientation == Orientation.portrait ? 16 : 12, // Vertical padding based on orientation
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: design['inputSpacing']), // Spacing between input fields
                  // TextField for answer input
                  Container(
                    width: design['inputWidth'], // Input field width
                    height: design['inputHeight'], // Input field height
                    child: TextField(
                      controller: _answerController, // Controller for answer input
                      style: TextStyle(
                        color: Colors.black, // Input text color
                        fontSize: design['inputFontSize'], // Input font size
                      ),
                      decoration: InputDecoration(
                        labelText: 'Answer', // Label for the input field
                        labelStyle: TextStyle(
                          color: Colors.blueAccent, // Label text color
                          fontSize: design['labelFontSize'], // Label font size
                        ),
                        filled: true, // Enable fill color
                        fillColor: Colors.white, // Fill color for input field
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.0), // Rounded corners for border
                          borderSide: BorderSide(color: Colors.blueAccent), // Border color
                        ),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 16, // Horizontal padding inside input
                          vertical: orientation == Orientation.portrait ? 16 : 12, // Vertical padding based on orientation
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: design['buttonSpacing']), // Spacing between buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center, // Center alignment for buttons
                    children: [
                      // Save button
                      Container(
                        width: design['buttonWidth'], // Button width
                        height: design['buttonHeight'], // Button height
                        child: ElevatedButton(
                          onPressed: _saveCard, // Action on button press
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blueAccent, // Button background color
                            foregroundColor: Colors.white, // Button text color
                            padding: design['buttonPadding'], // Button padding
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10), // Rounded corners for button
                            ),
                          ),
                          child: Text(
                            'Save', // Button text
                            style: TextStyle(fontSize: design['buttonFontSize']), // Button font size
                          ),
                        ),
                      ),
                      // Delete button (only if editing)
                      if (_isEditing) ...[
                        SizedBox(width: design['inputSpacing']), // Spacing before delete button
                        Container(
                          width: design['buttonWidth'], // Button width
                          height: design['buttonHeight'], // Button height
                          child: TextButton(
                            onPressed: _deleteCard, // Action on button press
                            style: TextButton.styleFrom(
                              backgroundColor: Colors.red, // Button background color
                              foregroundColor: Colors.white, // Button text color
                              padding: design['buttonPadding'], // Button padding
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10), // Rounded corners for button
                              ),
                            ),
                            child: Text(
                              'Delete', // Button text
                              style: TextStyle(fontSize: design['buttonFontSize']), // Button font size
                            ),
                          ),
                        ),
                      ],
                    ],
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
