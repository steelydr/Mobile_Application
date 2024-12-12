class Flashcard {
  final int? id;
  final int deckId;
  final String question;
  final String answer;

  Flashcard({this.id, required this.deckId, required this.question, required this.answer});

  Map<String, dynamic> toMap() => {
    'id': id,
    'deckId': deckId,
    'question': question,
    'answer': answer,
  };

  factory Flashcard.fromMap(Map<String, dynamic> map) => Flashcard(
    id: map['id'],
    deckId: map['deckId'],
    question: map['question'],
    answer: map['answer'],
  );
}
