// The Deck class represents a collection of flashcards and includes fields for ID, title, and flashcard count.
class Deck {
  // Unique identifier for the deck, nullable as it may not be assigned initially.
  final int? id;
  // Title of the deck, required for each deck.
  final String title;
  // The number of flashcards in the deck, defaulting to 0 if not provided.
  final int flashcardCount;

  // Constructor for initializing a Deck instance with optional ID, required title, and optional flashcard count.
  Deck({this.id, required this.title, this.flashcardCount = 0});

  // Method to convert a Deck instance to a map (dictionary) for easy storage in databases.
  Map<String, dynamic> toMap() {
    return {
      'id': id, // Map the 'id' field of the deck.
      'title': title, // Map the 'title' field of the deck.
      'flashcardCount': flashcardCount, // Map the 'flashcardCount' field of the deck.
    };
  }

  // Factory constructor to create a Deck instance from a map (e.g., from a database record).
  factory Deck.fromMap(Map<String, dynamic> map) {
    return Deck(
      id: map['id'], // Retrieve the 'id' from the map, if it exists.
      title: map['title'], // Retrieve the 'title' from the map.
      flashcardCount: map['flashcardCount'] ?? 0, // Retrieve 'flashcardCount', defaulting to 0 if absent.
    );
  }
}

// The Flashcard class represents an individual flashcard with a question, answer, and creation timestamp.
class Flashcard {
  // Unique identifier for the flashcard, nullable as it may not be assigned initially.
  final int? id;
  // Identifier for the associated deck to which this flashcard belongs.
  final int deckId;
  // Question on the flashcard.
  final String question;
  // Answer on the flashcard.
  final String answer;
  // Timestamp for when the flashcard was created.
  final DateTime createdAt;

  // Constructor to initialize a Flashcard instance, with a default timestamp if 'createdAt' is not provided.
  Flashcard({
    this.id, // Optional ID for the flashcard.
    required this.deckId, // Required deck ID to link the flashcard to a deck.
    required this.question, // Required question text for the flashcard.
    required this.answer, // Required answer text for the flashcard.
    DateTime? createdAt, // Optional creation timestamp for the flashcard.
  }) : this.createdAt = createdAt ?? DateTime.now(); // Assign current time if 'createdAt' is null.

  // Method to convert a Flashcard instance to a map for easy storage in databases.
  Map<String, dynamic> toMap() => {
    'id': id, // Map the 'id' field of the flashcard.
    'deckId': deckId, // Map the 'deckId' field linking to a deck.
    'question': question, // Map the 'question' text.
    'answer': answer, // Map the 'answer' text.
    'createdAt': createdAt.toIso8601String(), // Convert 'createdAt' to a string in ISO 8601 format for storage.
  };

  // Factory constructor to create a Flashcard instance from a map (e.g., from a database record).
  factory Flashcard.fromMap(Map<String, dynamic> map) => Flashcard(
    id: map['id'], // Retrieve the 'id' from the map, if it exists.
    deckId: map['deckId'], // Retrieve the 'deckId' to associate with a deck.
    question: map['question'], // Retrieve the 'question' from the map.
    answer: map['answer'], // Retrieve the 'answer' from the map.
    createdAt: map['createdAt'] != null
        ? DateTime.parse(map['createdAt']) // Parse 'createdAt' string back to DateTime.
        : DateTime.now(), // Default to current time if 'createdAt' is absent in the map.
  );
}
