// Import Flutter's material design package for UI components
import 'package:flutter/material.dart';
// Import provider package for state management
import 'package:provider/provider.dart';
// Import custom deck model
import '../models/deck.dart';
// Import database service for flashcard operations
import '../services/deckdatabase.dart';
// Import math library for random number generation
import 'dart:math';

// StatelessWidget that represents the quiz interface
class QuizPage extends StatelessWidget {
  // Store the deck object that contains the flashcards
  final Deck deck;

  // Constructor requiring a deck instance
  const QuizPage({Key? key, required this.deck}) : super(key: key);

  // Method to fetch flashcards from database and shuffle them
  Future<List<Flashcard>> loadAndShuffleCards(int deckId) async {
    // Fetch cards from the database using the deck ID
    final cards = await DeckDatabase.instance.getFlashcards(deckId);
    // Create a Random instance for shuffling
    final random = Random();
    // Implement Fisher-Yates shuffle algorithm
    for (var i = cards.length - 1; i > 0; i--) {
      // Generate random index
      final j = random.nextInt(i + 1);
      // Swap cards at indices i and j
      final temp = cards[i];
      cards[i] = cards[j];
      cards[j] = temp;
    }
    // Return the shuffled cards
    return cards;
  }

  // Helper method to calculate card dimensions based on screen orientation and size
  Map<String, double> _getCardDimensions(BuildContext context) {
    // Get current screen dimensions
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    // Get current device orientation
    final orientation = MediaQuery.of(context).orientation;

    // Return different dimensions for portrait mode
    if (orientation == Orientation.portrait) {
      return {
        'width': screenWidth * 0.85,        // Card takes 85% of screen width
        'height': screenHeight * 0.6,       // Card takes 60% of screen height
        'padding': 20.0,                    // Standard padding for portrait
        'fontSize': screenWidth < 360 ? 16.0 : 18.0,  // Smaller font for narrow screens
      };
    } else {
      // Return different dimensions for landscape mode
      return {
        'width': screenWidth * 0.7,         // Card takes 70% of screen width
        'height': screenHeight * 0.8,       // Card takes 80% of screen height
        'padding': 16.0,                    // Slightly smaller padding for landscape
        'fontSize': screenHeight < 400 ? 14.0 : 16.0,  // Smaller font for short screens
      };
    }
  }

  @override
  Widget build(BuildContext context) {
    // Wrap the quiz page in a FutureProvider to handle async card loading
    return FutureProvider<List<Flashcard>>(
      // Create function that loads and shuffles the cards
      create: (_) => loadAndShuffleCards(deck.id!),
      // Empty list as initial data while loading
      initialData: [],
      // Main scaffold widget that provides the basic app structure
      child: Scaffold(
        // App bar configuration
        appBar: AppBar(
          // Title section with responsive font size
          title: LayoutBuilder(
            builder: (context, constraints) {
              // Adjust font size based on orientation
              final orientation = MediaQuery.of(context).orientation;
              double fontSize = orientation == Orientation.portrait ? 18 : 16;
              return Text(
                'Quiz Mode: ${deck.title}',
                style: TextStyle(color: Colors.black, fontSize: fontSize),
              );
            },
          ),
          // Close button in app bar
          leading: IconButton(
            icon: Icon(Icons.close, color: Colors.black),
            onPressed: () => Navigator.pop(context),  // Return to previous screen
          ),
          backgroundColor: Colors.white,
        ),
        // Main body of the quiz page
        body: Consumer<List<Flashcard>>(
          builder: (context, flashcards, child) {
            // Show loading indicator while cards are being fetched
            if (flashcards.isEmpty) {
              return Center(child: CircularProgressIndicator());
            }

            // Provide quiz state management
            return ChangeNotifierProvider(
              create: (_) => QuizPageProvider(flashcards),
              // Consumer to rebuild UI when quiz state changes
              child: Consumer<QuizPageProvider>(
                builder: (context, provider, child) {
                  // Get current orientation for responsive layout
                  final orientation = MediaQuery.of(context).orientation;
                  return Padding(
                    // Adjust padding based on orientation
                    padding: EdgeInsets.all(orientation == Orientation.portrait ? 16.0 : 8.0),
                    child: Column(
                      children: [
                        // Progress tracking row
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // Display current card number
                            Text(
                              'Card ${provider.n + 1} of ${provider.flashcards.length}',
                              style: TextStyle(
                                fontSize: orientation == Orientation.portrait ? 16 : 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.cyan,
                              ),
                            ),
                            // Display number of viewed answers
                            Text(
                              'Peeked at ${provider.viewedAnswers.length} of ${provider.n + 1} answers',
                              style: TextStyle(
                                fontSize: orientation == Orientation.portrait ? 16 : 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.cyan,
                              ),
                            ),
                          ],
                        ),
                        // Spacing that adjusts with orientation
                        SizedBox(height: orientation == Orientation.portrait ? 20 : 10),
                        // Main flashcard area
                        Expanded(
                          child: GestureDetector(
                            onTap: provider.toggleAnswer,  // Toggle answer visibility on tap
                            // Animated card flip effect
                            child: AnimatedSwitcher(
                              duration: Duration(milliseconds: 500),
                              transitionBuilder: (child, animation) {
                                // Create rotation animation
                                final rotate = Tween(begin: pi, end: 0.0).animate(animation);
                                return AnimatedBuilder(
                                  animation: rotate,
                                  builder: (context, child) {
                                    // Determine which side of card to show
                                    final isFront = rotate.value < pi / 2;
                                    return Transform(
                                      // Apply 3D rotation transform
                                      transform: Matrix4.rotationY(isFront ? rotate.value : rotate.value + pi),
                                      alignment: Alignment.center,
                                      child: child,
                                    );
                                  },
                                  child: child,
                                );
                              },
                              // Show either front or back of card based on state
                              child: provider.showAnswer
                                  ? _buildCardBack(context, provider)
                                  : _buildCardFront(context, provider),
                            ),
                          ),
                        ),
                        // Navigation buttons row
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            // Previous card button
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.cyan,
                                shape: CircleBorder(),
                                padding: EdgeInsets.all(orientation == Orientation.portrait ? 12 : 8),
                                elevation: 5,
                              ),
                              onPressed: provider.previousCard,
                              child: Icon(Icons.arrow_back,
                                color: Colors.white,
                                size: orientation == Orientation.portrait ? 24 : 20,
                              ),
                            ),
                            // Next card button
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.cyan,
                                shape: CircleBorder(),
                                padding: EdgeInsets.all(orientation == Orientation.portrait ? 12 : 8),
                                elevation: 5,
                              ),
                              onPressed: provider.nextCard,
                              child: Icon(Icons.arrow_forward,
                                color: Colors.white,
                                size: orientation == Orientation.portrait ? 24 : 20,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }

  // Build the front side of the flashcard (question side)
  Widget _buildCardFront(BuildContext context, QuizPageProvider provider) {
    // Get dimensions based on current orientation and screen size
    final dimensions = _getCardDimensions(context);

    return Card(
      key: ValueKey(false),  // Key for animation system
      margin: EdgeInsets.all(dimensions['padding']!),
      elevation: 8,  // Card shadow depth
      color: Colors.black,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Container(
        padding: EdgeInsets.all(dimensions['padding']!),
        width: dimensions['width'],
        height: dimensions['height'],
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // "Question" label
            Text('Question:',
                style: TextStyle(
                    fontSize: dimensions['fontSize']! + 2,  // Slightly larger than base font
                    fontWeight: FontWeight.bold,
                    color: Colors.cyan
                )
            ),
            SizedBox(height: 2),
            // Question text
            Text(
              provider.shuffledCards[provider.currentIndex].question,
              style: TextStyle(
                  fontSize: dimensions['fontSize']! + 4,  // Larger than base font
                  color: Colors.white
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20),
            // Instruction text
            Text('Tap to show answer',
                style: TextStyle(
                    fontSize: dimensions['fontSize']! - 2,  // Smaller than base font
                    color: Colors.grey[600]
                )
            ),
          ],
        ),
      ),
    );
  }

  // Build the back side of the flashcard (answer side)
  Widget _buildCardBack(BuildContext context, QuizPageProvider provider) {
    // Get dimensions and orientation
    final dimensions = _getCardDimensions(context);
    final orientation = MediaQuery.of(context).orientation;

    return Card(
      key: ValueKey(true),  // Key for animation system
      margin: EdgeInsets.all(dimensions['padding']!),
      elevation: 8,
      color: Colors.black,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Container(
        padding: EdgeInsets.all(dimensions['padding']!),
        width: dimensions['width'],
        height: dimensions['height'],
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Question section
            Text(
              'Question:',
              style: TextStyle(
                  fontSize: dimensions['fontSize']!,
                  fontWeight: FontWeight.bold,
                  color: Colors.cyan
              ),
            ),
            SizedBox(height: orientation == Orientation.portrait ? 2 : 1),
            Text(
              provider.shuffledCards[provider.currentIndex].question,
              style: TextStyle(
                  fontSize: dimensions['fontSize']! + 1,
                  color: Colors.white
              ),
              textAlign: TextAlign.center,
            ),
            // Divider between question and answer
            Divider(
                height: orientation == Orientation.portrait ? 25 : 15,
                thickness: 1,
                color: Colors.cyan
            ),
            // Answer section
            Text(
              'Answer:',
              style: TextStyle(
                  fontSize: dimensions['fontSize']!,
                  fontWeight: FontWeight.bold,
                  color: Colors.cyan
              ),
            ),
            SizedBox(height: orientation == Orientation.portrait ? 2 : 1),
            Text(
              provider.shuffledCards[provider.currentIndex].answer,
              style: TextStyle(
                  fontSize: dimensions['fontSize']! + 2,
                  color: Colors.white
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

// State management class for the quiz page
class QuizPageProvider with ChangeNotifier {
  // List of all flashcards
  final List<Flashcard> flashcards;
  // Shuffled version of the flashcards
  List<Flashcard> shuffledCards = [];
  // Current card index
  int currentIndex = 0;
  // Whether to show the answer
  bool showAnswer = false;
  // Set of indices where answers have been viewed
  Set<int> viewedAnswers = {};
  // Highest index reached
  int n = 0;

  // Constructor initializes shuffled cards
  QuizPageProvider(this.flashcards) {
    shuffledCards = flashcards;
  }

  // Move to next card if available
  void nextCard() {
    if (currentIndex < shuffledCards.length - 1) {
      currentIndex++;
      showAnswer = false;  // Reset answer visibility
      if (currentIndex > n) {
        n = currentIndex;  // Update highest index reached
      }
      notifyListeners();  // Notify listeners to rebuild UI
    }
  }

  // Move to previous card if available
  void previousCard() {
    if (currentIndex > 0) {
      currentIndex--;
      showAnswer = false;  // Reset answer visibility
      notifyListeners();  // Notify listeners to rebuild UI
    }
  }

  // Toggle answer visibility and track viewed answers
  void toggleAnswer() {
    showAnswer = !showAnswer;
    if (showAnswer) {
      viewedAnswers.add(currentIndex);  // Mark current answer as viewed
    }
    notifyListeners();  // Notify listeners to rebuild UI
  }
}