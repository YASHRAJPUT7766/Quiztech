// lib/models/question_model.dart
class QuestionModel {
  final String question;
  final List<String> options;
  final int correctIndex;

  QuestionModel({
    required this.question,
    required this.options,
    required this.correctIndex,
  });

  factory QuestionModel.fromMap(Map<String, dynamic> map) {
    return QuestionModel(
      question: map['q'] ?? '',
      options: List<String>.from(map['o'] ?? []),
      correctIndex: (map['a'] ?? 0).toInt(),
    );
  }
}

class QuizCategory {
  final String id;
  final String name;
  final String emoji;
  final String color;
  final int questionCount;
  final bool isFree;
  final int entryCost; // in credits

  const QuizCategory({
    required this.id,
    required this.name,
    required this.emoji,
    required this.color,
    required this.questionCount,
    this.isFree = false,
    this.entryCost = 200,
  });
}

const List<QuizCategory> kCategories = [
  QuizCategory(id: 'gk', name: 'General Knowledge', emoji: '🌍', color: '#4F46E5', questionCount: 80, isFree: true, entryCost: 0),
  QuizCategory(id: 'science', name: 'Science', emoji: '🔬', color: '#059669', questionCount: 70, entryCost: 200),
  QuizCategory(id: 'math', name: 'Mathematics', emoji: '🔢', color: '#D97706', questionCount: 60, entryCost: 200),
  QuizCategory(id: 'history', name: 'History', emoji: '🏛️', color: '#7C3AED', questionCount: 60, entryCost: 200),
  QuizCategory(id: 'sports', name: 'Sports', emoji: '⚽', color: '#DC2626', questionCount: 60, entryCost: 200),
  QuizCategory(id: 'tech', name: 'Technology', emoji: '💻', color: '#0891B2', questionCount: 60, entryCost: 200),
  QuizCategory(id: 'bollywood', name: 'Bollywood', emoji: '🎬', color: '#DB2777', questionCount: 60, entryCost: 200),
  QuizCategory(id: 'geography', name: 'Geography', emoji: '🗺️', color: '#16A34A', questionCount: 60, entryCost: 200),
  QuizCategory(id: 'cricket', name: 'Cricket', emoji: '🏏', color: '#EA580C', questionCount: 60, entryCost: 200),
  QuizCategory(id: 'english', name: 'English', emoji: '📚', color: '#6D28D9', questionCount: 60, entryCost: 200),
  QuizCategory(id: 'current', name: 'Current Affairs', emoji: '📰', color: '#0F766E', questionCount: 60, entryCost: 200),
  QuizCategory(id: 'riddles', name: 'Riddles', emoji: '🧩', color: '#B45309', questionCount: 60, entryCost: 200),
];
