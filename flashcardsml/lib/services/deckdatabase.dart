// Import necessary packages for SQLite database, file path, and file storage.
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import '../models/deck.dart'; // Import the Deck model.

class DeckDatabase {
  // Singleton instance of DeckDatabase for managing a single database instance across the app.
  static final DeckDatabase instance = DeckDatabase._init();
  // Private field to store the SQLite database instance.
  static Database? _database;

  // Private named constructor for initializing the DeckDatabase.
  DeckDatabase._init();

  // Getter method to retrieve the database instance, creating it if necessary.
  Future<Database> get database async {
    if (_database != null) return _database!; // Return the existing database if it exists.
    _database = await _initDB('deck.db'); // Initialize and assign the database if it doesn't exist.
    return _database!;
  }

  // Method to initialize the database with a specified file name.
  Future<Database> _initDB(String fileName) async {
    // Get the documents directory path for storing the database file.
    final documentsDirectory = await getApplicationDocumentsDirectory();
    final path = join(documentsDirectory.path, fileName); // Create the full path to the database file.

    // Check if the database file already exists at the specified path.
    if (await databaseExists(path)) {
      print('Using existing database at: $path');
      // Open the existing database file without recreating it.
      return await openDatabase(path);
    } else {
      print('Creating new database at: $path');
      // Create a new database file and return the database instance.
      return await openDatabase(path, version: 1, onCreate: _createDB);
    }
  }

  // Method to create the database schema, defining tables and fields.
  Future<void> _createDB(Database db, int version) async {
    // SQL command to create the 'decks' table with auto-incrementing ID, title, and flashcard count.
    await db.execute('''
      CREATE TABLE decks (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        flashcardCount INTEGER DEFAULT 0
      )
    ''');

    // SQL command to create the 'flashcards' table with fields for deck ID, question, answer, and creation date.
    await db.execute('''
      CREATE TABLE flashcards (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        deckId INTEGER,
        question TEXT NOT NULL,
        answer TEXT NOT NULL,
        createdAt TEXT NOT NULL,
        FOREIGN KEY (deckId) REFERENCES decks (id) ON DELETE CASCADE
      )
    ''');
  }

  // CRUD operations for the Deck table.

  // Insert a new deck into the database and return the generated ID.
  Future<int> insertDeck(Deck deck) async {
    final db = await instance.database; // Get the database instance.
    final data = {
      'title': deck.title, // Prepare data for insertion, including the title.
    };
    return await db.insert('decks', data); // Insert the deck and return its ID.
  }

  // Update an existing deck in the database.
  Future<void> updateDeck(Deck deck) async {
    final db = await instance.database;
    await db.update(
      'decks',
      deck.toMap(), // Convert the Deck instance to a map for updating.
      where: 'id = ?', // Specify the row to update based on the ID.
      whereArgs: [deck.id], // Use the deck's ID as an argument.
    );
  }

  // Retrieve all decks from the database as a list.
  Future<List<Deck>> getDecks() async {
    final db = await instance.database;
    final result = await db.query('decks'); // Query all rows in the 'decks' table.
    return result.map((map) => Deck.fromMap(map)).toList(); // Map query results to Deck objects.
  }

  // Delete a deck by its ID and return the number of rows deleted.
  Future<int> deleteDeck(int id) async {
    final db = await instance.database;
    return await db.delete('decks', where: 'id = ?', whereArgs: [id]); // Delete deck by ID.
  }

  // CRUD operations for the Flashcard table.

  // Insert a new flashcard into the database.
  Future<void> insertFlashcard(Flashcard flashcard) async {
    final db = await instance.database;
    await db.insert('flashcards', flashcard.toMap()); // Insert flashcard as a map.
  }

  // Update an existing flashcard in the database.
  Future<void> updateFlashcard(Flashcard flashcard) async {
    final db = await instance.database;
    await db.update(
      'flashcards',
      flashcard.toMap(), // Convert the Flashcard instance to a map for updating.
      where: 'id = ?', // Specify the row to update based on the ID.
      whereArgs: [flashcard.id], // Use the flashcard's ID as an argument.
    );
  }

  // Retrieve all flashcards for a specific deck by deck ID.
  Future<List<Flashcard>> getFlashcards(int deckId) async {
    final db = await instance.database;
    final result = await db.query(
      'flashcards',
      where: 'deckId = ?', // Query flashcards associated with the specified deck ID.
      whereArgs: [deckId],
    );
    return result.map((map) => Flashcard.fromMap(map)).toList(); // Map results to Flashcard objects.
  }

  // Delete a flashcard by its ID and return the number of rows deleted.
  Future<int> deleteFlashcard(int id) async {
    final db = await instance.database;
    return await db.delete('flashcards', where: 'id = ?', whereArgs: [id]); // Delete flashcard by ID.
  }

  // Get the count of flashcards in a specific deck by deck ID.
  Future<int> getFlashcardCount(int deckId) async {
    final db = await instance.database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM flashcards WHERE deckId = ?', // SQL to count flashcards in the deck.
      [deckId],
    );

    return Sqflite.firstIntValue(result) ?? 0; // Return the count or 0 if null.
  }

  // Close the database connection when it's no longer needed.
  Future<void> close() async {
    final db = await instance.database;
    db.close(); // Close the database connection.
  }
}
