// lib/services/local_storage_service.dart
// Firebase-free local data storage using SharedPreferences.
// Sirf login mein Firebase use hoga — yahan sab local hai.
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import 'auth_service.dart';

class LocalStorageService {
  static const _userKey = 'local_user_v1';

  // ── Save user to SharedPreferences ──
  Future<void> saveUser(UserModel user) async {
    final prefs = await SharedPreferences.getInstance();
    final map = user.toMap();
    // Timestamp nahi store hoga — ISO string use karo
    map['createdAt'] = user.createdAt.toIso8601String();
    // quizHistory mein Timestamp ho sakta hai — convert karo
    map['quizHistory'] = user.quizHistory.map((h) {
      final entry = Map<String, dynamic>.from(h);
      if (entry['date'] is! String) {
        entry['date'] = DateTime.now().toIso8601String();
      }
      return entry;
    }).toList();
    await prefs.setString(_userKey, jsonEncode(map));
  }

  // ── Load user from SharedPreferences ──
  Future<UserModel?> getUser() async {
    final prefs = await SharedPreferences.getInstance();
    final json = prefs.getString(_userKey);
    if (json == null) return null;
    try {
      final map = Map<String, dynamic>.from(jsonDecode(json));
      // createdAt ko null kar do taaki fromMap DateTime.now() use kare
      map['createdAt'] = null;
      return UserModel.fromMap(map);
    } catch (_) {
      return null;
    }
  }

  // ── Stream user — quiz baad update ke liye periodic refresh ──
  Stream<UserModel?> streamUser() async* {
    yield await getUser();
    while (true) {
      await Future.delayed(const Duration(seconds: 2));
      yield await getUser();
    }
  }

  // ── Create user doc (login ke baad call hoga) ──
  Future<void> createUserDoc({
    required String uid,
    required String name,
    required String email,
    String? photoUrl,
    String? referredBy,
  }) async {
    // Agar isi uid ka user already local mein hai toh skip
    final existing = await getUser();
    if (existing != null && existing.uid == uid) return;

    final refCode = AuthService.genRef(uid);
    // FIX: referral bonus sirf tab dena jab referredBy valid ho
    final welcomeCredits = (referredBy != null && referredBy.isNotEmpty) ? 600 : 500;

    final user = UserModel(
      uid: uid,
      name: name,
      email: email,
      photoUrl: photoUrl,
      credits: welcomeCredits,
      moneyBalance: 0.0,
      streak: 0,
      totalWins: 0,
      totalQuizzes: 0,
      referralCode: refCode,
      createdAt: DateTime.now(),
      quizHistory: const [],
    );
    await saveUser(user);
  }

  // ── Quiz result save karo ──
  Future<void> saveQuizResult({
    required String uid,
    required String category,
    required int score,
    required int totalQuestions,
    required int creditsChange,
    required double moneyEarned,
    required bool won,
  }) async {
    final user = await getUser();
    if (user == null) return;

    final now = DateTime.now();
    final dateStr =
        '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';

    // Streak calculate karo
    final prefs = await SharedPreferences.getInstance();
    final lastPlay = prefs.getString('last_play_$uid');
    int newStreak = user.streak;
    if (lastPlay == null) {
      newStreak = 1;
    } else {
      final lastDate = DateTime.parse(lastPlay);
      final diff = now.difference(lastDate).inDays;
      if (diff == 1) {
        newStreak += 1;
      } else if (diff > 1) {
        newStreak = 1;
      }
      // Same day → streak unchanged
    }
    await prefs.setString('last_play_$uid', dateStr);

    // Streak bonus
    int streakBonus = 0;
    if (newStreak % 7 == 0) {
      streakBonus = 500;
    } else if (newStreak % 3 == 0) {
      streakBonus = 100;
    }

    final historyEntry = <String, dynamic>{
      'category': category,
      'score': score,
      'total': totalQuestions,
      'won': won,
      'moneyEarned': moneyEarned,
      'creditsChange': creditsChange,
      'date': now.toIso8601String(),
    };

    final updatedUser = user.copyWith(
      credits: (user.credits + creditsChange + streakBonus).clamp(0, 999999),
      moneyBalance: user.moneyBalance + moneyEarned,
      totalQuizzes: user.totalQuizzes + 1,
      totalWins: won ? user.totalWins + 1 : user.totalWins,
      streak: newStreak,
      quizHistory: [...user.quizHistory, historyEntry],
    );
    await saveUser(updatedUser);
  }

  // ── Name update ──
  Future<void> updateName(String uid, String name) async {
    final user = await getUser();
    if (user == null) return;
    await saveUser(user.copyWith(name: name));
  }

  // ── Photo update ──
  Future<void> updatePhoto(String uid, String photoUrl) async {
    final user = await getUser();
    if (user == null) return;
    await saveUser(user.copyWith(photoUrl: photoUrl));
  }

  // ── Promo code redeem ──
  Future<String?> redeemPromo(String uid, String code) async {
    final user = await getUser();
    if (user == null) return 'User not found';

    final prefs = await SharedPreferences.getInstance();
    final used = prefs.getStringList('used_promos_$uid') ?? [];
    if (used.contains(code)) return 'Already redeemed';

    if (!_isValidPromo(code)) return 'Invalid code';

    await prefs.setStringList('used_promos_$uid', [...used, code]);
    await saveUser(user.copyWith(credits: user.credits + 500));
    return null; // null = success
  }

  // FIX: lambda syntax se proper function mein change kiya
  bool _isValidPromo(String code) {
    const s = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
    int seed = 0xDEADBEEF;

    int rng() {
      seed = ((seed ^ 61) ^ (seed >> 16)) & 0xFFFFFFFF;
      seed = (seed + (seed << 3)) & 0xFFFFFFFF;
      seed ^= (seed >> 4);
      seed = (seed * 0x27d4eb2d) & 0xFFFFFFFF;
      seed ^= (seed >> 15);
      return seed;
    }

    for (int i = 0; i < 500; i++) {
      String c = '';
      for (int j = 0; j < 5; j++) c += s[rng() % s.length];
      if (c == code) return true;
    }
    return false;
  }

  // ── Withdrawal submit karo ──
  Future<void> submitWithdrawal({
    required String uid,
    required String method,
    required String account,
    required double amount,
  }) async {
    final user = await getUser();
    if (user == null) return;

    // Balance kam karo
    await saveUser(user.copyWith(moneyBalance: user.moneyBalance - amount));

    // Request locally save karo
    final prefs = await SharedPreferences.getInstance();
    final withdrawals = prefs.getStringList('withdrawals_$uid') ?? [];
    final entry = jsonEncode({
      'uid': uid,
      'method': method,
      'account': account,
      'amount': amount,
      'status': 'pending',
      'requestedAt': DateTime.now().toIso8601String(),
    });
    await prefs.setStringList('withdrawals_$uid', [...withdrawals, entry]);
  }

  // ── Admin check (local mein always false) ──
  Future<bool> isAdmin(String uid) async => false;

  // ── Leaderboard (locally empty) ──
  Future<List<Map<String, dynamic>>> getLeaderboard(String category) async =>
      [];

  // ── Admin: pending withdrawals stream (locally empty) ──
  Stream<List<Map<String, dynamic>>> getPendingWithdrawals() async* {
    yield [];
  }

  // ── Admin: withdrawal update (noop locally) ──
  Future<void> updateWithdrawal(String docId, String status) async {}
}
