// Import Flutter material library for UI components.
import 'package:flutter/material.dart';
// Import Flutter's rootBundle to load assets, used here for loading JSON data.
import 'package:flutter/services.dart' show rootBundle;
import 'dart:convert'; // Import Dart's JSON decoding library.
// Import custom Deck model and database services.
import '../models/deck.dart';
import '../services/deckdatabase.dart';
// Import CardList and DeckEditor screens.
import 'cardlist.dart';
import 'deckeditor.dart';

// Stateful widget to display a list of decks.
class DeckList extends StatefulWidget {
  const DeckList({super.key});

  @override
  _DeckListState createState() => _DeckListState();
}

// State class for DeckList to manage UI state and interactions.
class _DeckListState extends State<DeckList> {
  // List to store deck data fetched from the database.
  List<Deck> _decks = [];

  @override
  void initState() {
    super.initState();
    _loadDecks(); // Load decks when the widget is first initialized.
  }

  // Method to load decks from the database and update the state.
  void _loadDecks() async {
    final decks = await DeckDatabase.instance.getDecks(); // Fetch decks from database.
    setState(() {
      _decks = decks; // Update the deck list in the state.
    });
  }

  // Method to navigate to DeckEditor for creating a new deck.
  void _addDeck() async {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => DeckEditor(onSave: (deck) async {
          await DeckDatabase.instance.insertDeck(deck); // Save new deck to database.
          _loadDecks(); // Reload the deck list after adding a new deck.
        }),
      ),
    );
  }

  // Method to import decks and flashcards from a JSON file in assets.
  void _importDecksFromJson() async {
    // Load JSON string from 'assets/flashcards.json'.
    final String jsonString = await rootBundle.loadString('assets/flashcards.json');
    final List<dynamic> jsonData = json.decode(jsonString); // Decode JSON data.

    // Iterate through each deck in the JSON data.
    for (var deckData in jsonData) {
      final deck = Deck(title: deckData['title']); // Create a Deck instance with title.
      final int deckId = await DeckDatabase.instance.insertDeck(deck); // Insert deck into the database.

      // If the deck contains flashcards, iterate through them and add to the database.
      if (deckData['flashcards'] != null) {
        for (var flashcardData in deckData['flashcards']) {
          final flashcard = Flashcard(
            deckId: deckId,
            question: flashcardData['question'],
            answer: flashcardData['answer'],
          );
          await DeckDatabase.instance.insertFlashcard(flashcard); // Insert flashcard into the database.
        }
      }
    }
    _loadDecks(); // Reload the deck list after importing.
  }

  // Method to navigate to DeckEditor for editing an existing deck.
  void _editDeck(Deck deck) async {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => DeckEditor(
          deck: deck,
          onSave: (updatedDeck) async {
            await DeckDatabase.instance.updateDeck(updatedDeck); // Update deck in database.
            _loadDecks(); // Reload the deck list after editing.
          },
          onDelete: (id) async {
            await DeckDatabase.instance.deleteDeck(id); // Delete deck from database.
            _loadDecks(); // Reload the deck list after deletion.
          },
        ),
      ),
    );
  }

  // Method to navigate to CardList screen to view flashcards in a deck.
  void _viewDeckCards(Deck deck) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => CardList(deck: deck),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Determine the number of columns in the grid based on the screen width.
    double screenWidth = MediaQuery.of(context).size.width;
    int columns;

    if (screenWidth < 600) {
      columns = 2; // 2 columns for mobile.
    } else if (screenWidth < 1200) {
      columns = 3; // 3 columns for tablet.
    } else {
      columns = 4; // 4 columns for desktop.
    }

    // Determine font size based on screen width for responsive text.
    double fontSize;
    if (screenWidth < 600) {
      fontSize = 16; // Font size for mobile.
    } else if (screenWidth < 1200) {
      fontSize = 20; // Font size for tablet.
    } else {
      fontSize = 24; // Font size for desktop.
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Deck List'), // Title for the app bar.
        actions: [
          // Button to import decks from JSON.
          IconButton(
            icon: const Icon(Icons.file_upload),
            onPressed: _importDecksFromJson,
          ),
        ],
      ),
      // Body displays decks in a grid layout.
      body: GridView.count(
        crossAxisCount: columns, // Set the number of columns based on screen size.
        padding: const EdgeInsets.all(5), // Padding around grid items.
        children: List.generate(
          _decks.length, // Number of items in the grid.
              (index) => Card(
            color: Colors.cyan, // Card background color.
            child: InkWell(
              onTap: () => _viewDeckCards(_decks[index]), // View deck's cards on tap.
              child: Stack(
                children: [
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0), // Inner padding.
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center, // Center vertically in column.
                        crossAxisAlignment: CrossAxisAlignment.center, // Center horizontally in column.
                        children: [
                          // Display the deck title.
                          Text(
                            _decks[index].title,
                            style: TextStyle(fontSize: fontSize), // Font size based on screen width.
                            textAlign: TextAlign.center,
                          ),
                          // Display flashcard count for the deck.
                          FutureBuilder<int>(
                            future: DeckDatabase.instance.getFlashcardCount(_decks[index].id!),
                            builder: (context, snapshot) {
                              final count = snapshot.data ?? 0; // Default count to 0 if no data.
                              return Text(
                                '($count cards)', // Display the flashcard count.
                                style: TextStyle(fontSize: fontSize * 0.95), // Slightly smaller font size.
                                textAlign: TextAlign.center,
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Positioned edit button on the bottom-right of the card.
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () => _editDeck(_decks[index]), // Edit deck on button tap.
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      // Floating action button to add a new deck.
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add), // Add icon on the button.
        onPressed: _addDeck, // Call _addDeck method when pressed.
      ),
    );
  }
}
