// lib/services/auth_service.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final _auth = FirebaseAuth.instance;
  final _google = GoogleSignIn(scopes: ['email', 'profile']);

  Stream<User?> get userStream => _auth.authStateChanges();
  User? get currentUser => _auth.currentUser;

  Future<UserCredential> signInWithEmail(String email, String password) async {
    return await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  Future<UserCredential> registerWithEmail(
      String name, String email, String password) async {
    final cred = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    await cred.user?.updateDisplayName(name);
    return cred;
  }

  Future<UserCredential?> signInWithGoogle() async {
    final googleUser = await _google.signIn();
    if (googleUser == null) return null;

    final googleAuth = await googleUser.authentication;
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );
    return await _auth.signInWithCredential(credential);
  }

  Future<void> signOut() async {
    await _google.signOut();
    await _auth.signOut();
  }

  static String genRef(String uid) {
    const s = "ABCDEFGHJKLMNPQRSTUVWXYZ23456789";
    var seed = uid.codeUnitAt(0) * 31 + uid.codeUnitAt(uid.length - 1);
    String r = '';
    for (int i = 0; i < 6; i++) {
      seed = (seed * 1664525 + 1013904223) & 0xFFFFFFFF;
      r += s[seed % s.length];
    }
    return r;
  }
}
