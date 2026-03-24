// lib/services/firestore_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';

class FirestoreService {
  final _db = FirebaseFirestore.instance;

  // ── Create user document (same as website's ensureUserDoc) ──
  Future<void> createUserDoc({
    required String uid,
    required String name,
    required String email,
    String? photoUrl,
    String? referredBy,
  }) async {
    final ref = _db.collection('users').doc(uid);
    final snap = await ref.get();
    if (snap.exists) return;

    final refCode = AuthService.genRef(uid);
    await ref.set({
      'uid': uid,
      'name': name,
      'email': email,
      'photoUrl': photoUrl,
      'credits': 500, // Welcome bonus
      'moneyBalance': 0.0,
      'streak': 0,
      'lastPlayDate': null,
      'totalWins': 0,
      'totalQuizzes': 0,
      'referralCode': refCode,
      'referredBy': referredBy,
      'quizHistory': [],
      'withdrawals': [],
      'createdAt': FieldValue.serverTimestamp(),
    });

    // If referred, give 100 credits bonus to referrer
    if (referredBy != null) {
      final refQuery = await _db
          .collection('users')
          .where('referralCode', isEqualTo: referredBy)
          .limit(1)
          .get();
      if (refQuery.docs.isNotEmpty) {
        await refQuery.docs.first.reference.update({
          'credits': FieldValue.increment(100),
        });
      }
    }
  }

  // ── Get user document ──
  Future<UserModel?> getUserDoc(String uid) async {
    final snap = await _db.collection('users').doc(uid).get();
    if (!snap.exists) return null;
    return UserModel.fromMap(snap.data()!);
  }

  // ── Stream user document (realtime) ──
  Stream<UserModel?> streamUserDoc(String uid) {
    return _db.collection('users').doc(uid).snapshots().map((snap) {
      if (!snap.exists) return null;
      return UserModel.fromMap(snap.data()!);
    });
  }

  // ── Update user credits and money after quiz ──
  Future<void> saveQuizResult({
    required String uid,
    required String category,
    required int score,
    required int totalQuestions,
    required int creditsChange, // negative if paid entry
    required double moneyEarned,
    required bool won,
  }) async {
    final ref = _db.collection('users').doc(uid);
    final now = DateTime.now();
    final dateStr = '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';

    // Check streak
    final snap = await ref.get();
    final data = snap.data()!;
    final lastPlay = data['lastPlayDate'] as String?;
    int newStreak = (data['streak'] ?? 0).toInt();

    if (lastPlay == null) {
      newStreak = 1;
    } else {
      final lastDate = DateTime.parse(lastPlay);
      final diff = now.difference(lastDate).inDays;
      if (diff == 1) {
        newStreak = newStreak + 1;
      } else if (diff > 1) {
        newStreak = 1;
      }
    }

    // Streak bonus credits
    int streakBonus = 0;
    if (newStreak % 7 == 0) streakBonus = 500;
    else if (newStreak % 3 == 0) streakBonus = 100;

    final historyEntry = {
      'category': category,
      'score': score,
      'total': totalQuestions,
      'won': won,
      'moneyEarned': moneyEarned,
      'creditsChange': creditsChange,
      'date': Timestamp.now(),
    };

    await ref.update({
      'credits': FieldValue.increment(creditsChange + streakBonus),
      'moneyBalance': FieldValue.increment(moneyEarned),
      'totalQuizzes': FieldValue.increment(1),
      'totalWins': won ? FieldValue.increment(1) : FieldValue.increment(0),
      'streak': newStreak,
      'lastPlayDate': dateStr,
      'quizHistory': FieldValue.arrayUnion([historyEntry]),
    });

    // Add to leaderboard
    await _db.collection('leaderboard').doc('$uid-$category').set({
      'uid': uid,
      'name': data['name'],
      'category': category,
      'score': score,
      'won': won,
      'updatedAt': Timestamp.now(),
    }, SetOptions(merge: true));
  }

  // ── Update user name ──
  Future<void> updateName(String uid, String name) async {
    await _db.collection('users').doc(uid).update({'name': name});
  }

  // ── Update photo URL ──
  Future<void> updatePhoto(String uid, String photoUrl) async {
    await _db.collection('users').doc(uid).update({'photoUrl': photoUrl});
  }

  // ── Redeem promo code ──
  Future<String?> redeemPromo(String uid, String code) async {
    // Check if code already redeemed
    final ref = _db.collection('users').doc(uid);
    final snap = await ref.get();
    final used = List<String>.from(snap.data()?['usedPromos'] ?? []);
    if (used.contains(code)) return 'Already redeemed';

    // Validate code
    if (!_isValidPromo(code)) return 'Invalid code';

    await ref.update({
      'credits': FieldValue.increment(500),
      'usedPromos': FieldValue.arrayUnion([code]),
    });
    return null; // null = success
  }

  // FIX: lambda syntax se proper local function mein change kiya
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

  // ── Submit withdrawal request ──
  Future<void> submitWithdrawal({
    required String uid,
    required String method,
    required String account,
    required double amount,
  }) async {
    final ref = _db.collection('users').doc(uid);
    await ref.update({
      'moneyBalance': FieldValue.increment(-amount),
    });
    await _db.collection('withdrawals').add({
      'uid': uid,
      'method': method,
      'account': account,
      'amount': amount,
      'status': 'pending',
      'requestedAt': Timestamp.now(),
    });
  }

  // ── Get leaderboard ──
  Future<List<Map<String, dynamic>>> getLeaderboard(String category) async {
    final snap = await _db
        .collection('leaderboard')
        .where('category', isEqualTo: category)
        .orderBy('score', descending: true)
        .limit(20)
        .get();
    return snap.docs.map((d) => d.data()).toList();
  }

  // ── Check if admin ──
  Future<bool> isAdmin(String uid) async {
    final snap = await _db.collection('admins').doc(uid).get();
    return snap.exists;
  }

  // ── Get pending withdrawals (admin) ──
  Stream<List<Map<String, dynamic>>> getPendingWithdrawals() {
    return _db
        .collection('withdrawals')
        .where('status', isEqualTo: 'pending')
        .snapshots()
        .map((s) => s.docs.map((d) => {'id': d.id, ...d.data()}).toList());
  }

  // ── Approve/Reject withdrawal (admin) ──
  Future<void> updateWithdrawal(String docId, String status) async {
    await _db.collection('withdrawals').doc(docId).update({'status': status});
  }
}
