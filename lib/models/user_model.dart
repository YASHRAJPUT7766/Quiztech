// lib/models/user_model.dart
class UserModel {
  final String uid;
  final String name;
  final String email;
  final String? photoUrl;
  final int credits;
  final double moneyBalance;
  final int streak;
  final int totalWins;
  final int totalQuizzes;
  final String referralCode;
  final DateTime createdAt;
  final List<Map<String, dynamic>> quizHistory;

  UserModel({
    required this.uid,
    required this.name,
    required this.email,
    this.photoUrl,
    this.credits = 500,
    this.moneyBalance = 0.0,
    this.streak = 0,
    this.totalWins = 0,
    this.totalQuizzes = 0,
    required this.referralCode,
    required this.createdAt,
    this.quizHistory = const [],
  });

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] ?? '',
      name: map['name'] ?? 'Player',
      email: map['email'] ?? '',
      photoUrl: map['photoUrl'],
      credits: (map['credits'] ?? 500).toInt(),
      moneyBalance: (map['moneyBalance'] ?? 0.0).toDouble(),
      streak: (map['streak'] ?? 0).toInt(),
      totalWins: (map['totalWins'] ?? 0).toInt(),
      totalQuizzes: (map['totalQuizzes'] ?? 0).toInt(),
      referralCode: map['referralCode'] ?? '',
      createdAt: map['createdAt'] != null
          ? (map['createdAt'] is String
              ? DateTime.tryParse(map['createdAt']) ?? DateTime.now()
              : (map['createdAt'] as dynamic).toDate())
          : DateTime.now(),
      quizHistory: List<Map<String, dynamic>>.from(map['quizHistory'] ?? []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'photoUrl': photoUrl,
      'credits': credits,
      'moneyBalance': moneyBalance,
      'streak': streak,
      'totalWins': totalWins,
      'totalQuizzes': totalQuizzes,
      'referralCode': referralCode,
      'quizHistory': quizHistory,
    };
  }

  UserModel copyWith({
    String? name,
    String? photoUrl,
    int? credits,
    double? moneyBalance,
    int? streak,
    int? totalWins,
    int? totalQuizzes,
    List<Map<String, dynamic>>? quizHistory,
  }) {
    return UserModel(
      uid: uid,
      name: name ?? this.name,
      email: email,
      photoUrl: photoUrl ?? this.photoUrl,
      credits: credits ?? this.credits,
      moneyBalance: moneyBalance ?? this.moneyBalance,
      streak: streak ?? this.streak,
      totalWins: totalWins ?? this.totalWins,
      totalQuizzes: totalQuizzes ?? this.totalQuizzes,
      referralCode: referralCode,
      createdAt: createdAt,
      quizHistory: quizHistory ?? this.quizHistory,
    );
  }
}
