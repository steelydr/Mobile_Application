// Import Flutter material library for UI components.
import 'package:flutter/material.dart';
// Import custom Deck model and database services for accessing deck and flashcard data.
import '../models/deck.dart';
import '../services/deckdatabase.dart';
// Import CardEditor and QuizPage screens.
import './cardeditor.dart';
import './quizpage.dart';

// Stateful widget to display the list of flashcards in a deck.
class CardList extends StatefulWidget {
  // Deck instance passed to CardList to display flashcards from this deck.
  final Deck deck;

  // Constructor to initialize CardList with a deck.
  const CardList({Key? key, required this.deck}) : super(key: key);

  @override
  _CardListState createState() => _CardListState();
}

// State class for CardList to manage UI state and interactions.
class _CardListState extends State<CardList> {
  // Future for fetching flashcards, updated based on sort order.
  late Future<List<Flashcard>> _flashcardsFuture;
  // Boolean to toggle between alphabetical and date-based sorting.
  bool _isAlphabetical = true;
  // Loading state for indicating data fetch process.
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchAndSortFlashcards(); // Fetch flashcards initially.
  }

  // Method to fetch flashcards and sort them based on _isAlphabetical flag.
  Future<void> _fetchAndSortFlashcards() async {
    setState(() {
      _isLoading = true; // Set loading to true to show progress indicator.
    });

    try {
      // Fetch flashcards from database and apply sorting.
      _flashcardsFuture = DeckDatabase.instance.getFlashcards(widget.deck.id!).then((flashcards) {
        // Sort flashcards alphabetically or by creation date.
        if (_isAlphabetical) {
          flashcards.sort((a, b) => a.question.compareTo(b.question));
        } else {
          flashcards.sort((a, b) => a.createdAt.compareTo(b.createdAt));
        }
        return flashcards;
      });

      await _flashcardsFuture; // Await the result of fetching.
    } catch (e) {
      // Display error message if there was an issue loading flashcards.
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading flashcards: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      // Set loading to false after fetching completes.
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // Toggle sorting order between alphabetical and date-based.
  Future<void> _toggleSortOrder() async {
    setState(() {
      _isAlphabetical = !_isAlphabetical; // Reverse sort order flag.
    });
    await _fetchAndSortFlashcards(); // Re-fetch and sort flashcards.
  }

  // Delete a specific flashcard and refresh the flashcard list.
  Future<void> _deleteCard(Flashcard flashcard) async {
    try {
      await DeckDatabase.instance.deleteFlashcard(flashcard.id!); // Delete flashcard by ID.
      await _fetchAndSortFlashcards(); // Refresh flashcards list after deletion.
      return Future.value(); // Return success.
    } catch (e) {
      return Future.error(e); // Propagate error if deletion fails.
    }
  }

  @override
  Widget build(BuildContext context) {
    // Determine grid layout based on screen width.
    final screenWidth = MediaQuery.of(context).size.width;
    int columns = screenWidth < 600 ? 2 : 3; // 2 columns on small screens, 3 on larger.
    double textSize = screenWidth < 600 ? 16 : 28; // Adjust text size for small vs. large screens.

    return Scaffold(
      appBar: AppBar(
        // Display deck title in AppBar with scaling text.
        title: Center(
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              '${widget.deck.title} Deck',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        actions: [
          // Button to toggle sorting order.
          IconButton(
            icon: Icon(
              _isAlphabetical ? Icons.sort_by_alpha : Icons.access_time,
            ),
            onPressed: _isLoading ? null : _toggleSortOrder, // Disable if loading.
            tooltip: _isAlphabetical ? 'Sort by date' : 'Sort alphabetically',
          ),
          // Button to start the quiz for this deck.
          IconButton(
            icon: Icon(Icons.play_arrow),
            onPressed: _isLoading
                ? null
                : () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => QuizPage(deck: widget.deck),
                ),
              );
            },
            tooltip: 'Start quiz',
          ),
        ],
      ),
      body: FutureBuilder<List<Flashcard>>(
        future: _flashcardsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting || _isLoading) {
            // Show loading indicator while fetching data.
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Loading flashcards...'),
                ],
              ),
            );
          } else if (snapshot.hasError) {
            // Show error message if there was an issue loading data.
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 48, color: Colors.red),
                  SizedBox(height: 16),
                  Text('Error: ${snapshot.error}'),
                  ElevatedButton(
                    onPressed: _fetchAndSortFlashcards,
                    child: Text('Retry'), // Retry button for reloading data.
                  ),
                ],
              ),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            // Show message if no flashcards are available in the deck.
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.note_add, size: 48),
                  SizedBox(height: 16),
                  Text('No flashcards found for this deck.'),
                  SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () async {
                      // Navigate to CardEditor to add a new flashcard.
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CardEditor(
                            deckId: widget.deck.id!,
                          ),
                        ),
                      );
                      if (result == true) {
                        _fetchAndSortFlashcards(); // Refresh after adding a card.
                      }
                    },
                    child: Text('Add Your First Card'),
                  ),
                ],
              ),
            );
          }

          final flashcards = snapshot.data!; // Get the list of flashcards.
          return RefreshIndicator(
            onRefresh: _fetchAndSortFlashcards, // Pull to refresh functionality.
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: columns, // Set number of columns in the grid.
                  crossAxisSpacing: 10, // Spacing between columns.
                  mainAxisSpacing: 10, // Spacing between rows.
                  childAspectRatio: 1, // Aspect ratio for each grid item.
                ),
                itemCount: flashcards.length, // Number of items in the grid.
                itemBuilder: (context, index) {
                  final flashcard = flashcards[index]; // Get individual flashcard.
                  return GestureDetector(
                    onTap: _isLoading
                        ? null
                        : () async {
                      // Navigate to CardEditor to edit the flashcard on tap.
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CardEditor(
                            flashcard: flashcard,
                            deckId: widget.deck.id!,
                          ),
                        ),
                      );
                      if (result == true) {
                        _fetchAndSortFlashcards(); // Refresh after editing.
                      }
                    },
                    onLongPress: _isLoading
                        ? null
                        : () async {
                      // Directly delete the flashcard on long press.
                      await _deleteCard(flashcard);
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Row(
                              children: [
                                Icon(Icons.check_circle, color: Colors.white),
                                SizedBox(width: 8),
                                Text('Card deleted successfully'),
                              ],
                            ),
                            backgroundColor: Colors.green,
                            duration: Duration(seconds: 2),
                          ),
                        );
                      }
                    },
                    child: Card(
                      color: Colors.cyan, // Card background color.
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8), // Rounded corners.
                      ),
                      elevation: 2, // Elevation for shadow effect.
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0), // Inner padding.
                          child: Text(
                            flashcard.question, // Display question text.
                            textAlign: TextAlign.center, // Center-align text.
                            style: TextStyle(
                              fontSize: textSize, // Adjust text size based on screen width.
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        // Floating button to add a new flashcard.
        onPressed: _isLoading
            ? null
            : () async {
          // Navigate to CardEditor to create a new flashcard.
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CardEditor(
                deckId: widget.deck.id!,
              ),
            ),
          );
          if (result == true) {
            _fetchAndSortFlashcards(); // Refresh after adding.
          }
        },
        child: Icon(Icons.add), // Icon for the floating button.
        tooltip: 'Add new card', // Tooltip for accessibility.
      ),
    );
  }
}
