// lib/screens/login_screen.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/auth_service.dart';
import '../services/local_storage_service.dart';
import '../theme/app_theme.dart';
import 'home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with SingleTickerProviderStateMixin {
  final _auth = AuthService();
  late TabController _tab;
  final _emailC = TextEditingController();
  final _passC = TextEditingController();
  final _regEmailC = TextEditingController();
  final _regPassC = TextEditingController();
  final _regNameC = TextEditingController();
  final _refC = TextEditingController();
  bool _loading = false;
  bool _obscure = true;

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tab.dispose();
    _emailC.dispose(); _passC.dispose();
    _regEmailC.dispose(); _regPassC.dispose(); _regNameC.dispose(); _refC.dispose();
    super.dispose();
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(msg), backgroundColor: AppTheme.red));
  }

  Future<void> _login() async {
    if (_emailC.text.isEmpty || _passC.text.isEmpty) {
      _showError('Please fill all fields'); return;
    }
    setState(() => _loading = true);
    try {
      final cred = await _auth.signInWithEmail(_emailC.text.trim(), _passC.text);
      final fu = cred.user!;
      await LocalStorageService().createUserDoc(
        uid: fu.uid,
        name: fu.displayName ?? fu.email!.split('@')[0],
        email: fu.email ?? '',
        photoUrl: fu.photoURL,
      );
      _goHome();
    } catch (e) {
      _showError('Login failed: ${e.toString().split(']').last.trim()}');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _register() async {
    if (_regNameC.text.isEmpty || _regEmailC.text.isEmpty || _regPassC.text.isEmpty) {
      _showError('Please fill all fields'); return;
    }
    if (_regPassC.text.length < 6) {
      _showError('Password must be 6+ characters'); return;
    }
    setState(() => _loading = true);
    try {
      final cred = await _auth.registerWithEmail(
          _regNameC.text.trim(), _regEmailC.text.trim(), _regPassC.text);
      final fu = cred.user!;
      await LocalStorageService().createUserDoc(
        uid: fu.uid,
        name: _regNameC.text.trim(),
        email: fu.email ?? '',
        photoUrl: fu.photoURL,
        referredBy: _refC.text.trim().isNotEmpty ? _refC.text.trim().toUpperCase() : null,
      );
      _goHome();
    } catch (e) {
      _showError('Registration failed: ${e.toString().split(']').last.trim()}');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _googleSignIn() async {
    setState(() => _loading = true);
    try {
      final cred = await _auth.signInWithGoogle();
      if (cred != null) {
        final fu = cred.user!;
        await LocalStorageService().createUserDoc(
          uid: fu.uid,
          name: fu.displayName ?? 'Player',
          email: fu.email ?? '',
          photoUrl: fu.photoURL,
        );
        _goHome();
      }
    } catch (e) {
      _showError('Google sign-in failed');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _goHome() {
    Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const HomeScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            // ── Hero ──
            Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft, end: Alignment.bottomRight,
                  colors: [AppTheme.primary, AppTheme.primary2],
                ),
              ),
              padding: EdgeInsets.only(
                  top: MediaQuery.of(context).padding.top + 36,
                  bottom: 36, left: 24, right: 24),
              child: Column(
                children: [
                  Container(
                    width: 68, height: 68,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(18),
                      color: Colors.white.withOpacity(0.2),
                      border: Border.all(color: Colors.white.withOpacity(0.3), width: 2),
                    ),
                    child: const Center(child: Text('🎯', style: TextStyle(fontSize: 34))),
                  ),
                  const SizedBox(height: 14),
                  RichText(text: TextSpan(
                    style: GoogleFonts.outfit(fontWeight: FontWeight.w900, fontSize: 32,
                        color: Colors.white, letterSpacing: -0.5),
                    children: [
                      const TextSpan(text: 'Quiz'),
                      TextSpan(text: 'Tech',
                          style: GoogleFonts.outfit(color: const Color(0xFFC4B5FD))),
                    ],
                  )),
                  const SizedBox(height: 4),
                  Text('PLAY QUIZ · WIN REAL MONEY',
                      style: GoogleFonts.outfit(
                          color: Colors.white60, fontSize: 11, letterSpacing: 1.5)),
                  const SizedBox(height: 20),
                  Row(mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _statWidget('10K+', 'Players'),
                      const SizedBox(width: 32),
                      _statWidget('₹50K+', 'Paid Out'),
                      const SizedBox(width: 32),
                      _statWidget('3200+', 'Questions'),
                    ],
                  ),
                ],
              ),
            ),

            // ── Form ──
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  // Tabs
                  Container(
                    decoration: BoxDecoration(
                        color: const Color(0xFFEEF0F6),
                        borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.all(3),
                    child: TabBar(
                      controller: _tab,
                      indicator: BoxDecoration(
                          color: Colors.white, borderRadius: BorderRadius.circular(10),
                          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 8)]),
                      indicatorSize: TabBarIndicatorSize.tab,
                      dividerColor: Colors.transparent,
                      labelColor: AppTheme.primary,
                      unselectedLabelColor: const Color(0xFF9CA3AF),
                      labelStyle: GoogleFonts.outfit(fontWeight: FontWeight.w800, fontSize: 14),
                      tabs: const [Tab(text: 'Login'), Tab(text: 'Register')],
                    ),
                  ),
                  const SizedBox(height: 22),

                  // Google button
                  _googleBtn(),
                  const SizedBox(height: 18),
                  _divider(),
                  const SizedBox(height: 18),

                  AnimatedBuilder(
                    animation: _tab,
                    builder: (_, __) => SizedBox(
                      height: _tab.index == 0 ? 180 : 340,
                      child: TabBarView(
                        controller: _tab,
                        physics: const NeverScrollableScrollPhysics(),
                        children: [
                          // Login form
                          Column(children: [
                            _field('Email', _emailC, TextInputType.emailAddress),
                            const SizedBox(height: 14),
                            _passField(),
                          ]),
                          // Register form
                          Column(children: [
                            _field('Full Name', _regNameC, TextInputType.name),
                            const SizedBox(height: 12),
                            _field('Email', _regEmailC, TextInputType.emailAddress),
                            const SizedBox(height: 12),
                            _field('Password (6+ chars)', _regPassC, TextInputType.text, obscure: true),
                            const SizedBox(height: 12),
                            _field('Referral Code (optional)', _refC, TextInputType.text),
                          ]),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),
                  AnimatedBuilder(
                    animation: _tab,
                    builder: (_, __) => SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _loading ? null : (_tab.index == 0 ? _login : _register),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          backgroundColor: AppTheme.primary,
                        ),
                        child: _loading
                            ? const SizedBox(width: 20, height: 20,
                                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                            : Text(_tab.index == 0 ? 'Login' : 'Create Account',
                                style: GoogleFonts.outfit(
                                    fontWeight: FontWeight.w900, fontSize: 16, color: Colors.white)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _statWidget(String val, String lbl) {
    return Column(children: [
      Text(val, style: GoogleFonts.outfit(fontWeight: FontWeight.w900, fontSize: 20, color: Colors.white)),
      Text(lbl, style: GoogleFonts.outfit(fontSize: 11, color: Colors.white54)),
    ]);
  }

  Widget _googleBtn() {
    return InkWell(
      onTap: _loading ? null : _googleSignIn,
      borderRadius: BorderRadius.circular(13),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(13),
          border: Border.all(color: const Color(0xFFE5E7EB)),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 8)],
        ),
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          const Text('G', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF4285F4))),
          const SizedBox(width: 10),
          Text('Continue with Google',
              style: GoogleFonts.dmSans(fontWeight: FontWeight.w700, fontSize: 15, color: const Color(0xFF111111))),
        ]),
      ),
    );
  }

  Widget _divider() {
    return Row(children: [
      const Expanded(child: Divider()),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Text('OR', style: GoogleFonts.outfit(
            color: const Color(0xFF9CA3AF), fontSize: 11, letterSpacing: 1)),
      ),
      const Expanded(child: Divider()),
    ]);
  }

  Widget _field(String label, TextEditingController c, TextInputType type, {bool obscure = false}) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label.toUpperCase(),
          style: GoogleFonts.outfit(fontSize: 11, fontWeight: FontWeight.w700,
              color: const Color(0xFF374151), letterSpacing: 0.5)),
      const SizedBox(height: 5),
      TextField(
        controller: c,
        keyboardType: type,
        obscureText: obscure,
        decoration: InputDecoration(
          filled: true, fillColor: Colors.white,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE5E7EB))),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE5E7EB))),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppTheme.primary, width: 1.5)),
          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
        ),
      ),
    ]);
  }

  Widget _passField() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('PASSWORD',
          style: GoogleFonts.outfit(fontSize: 11, fontWeight: FontWeight.w700,
              color: const Color(0xFF374151), letterSpacing: 0.5)),
      const SizedBox(height: 5),
      TextField(
        controller: _passC,
        obscureText: _obscure,
        decoration: InputDecoration(
          filled: true, fillColor: Colors.white,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE5E7EB))),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE5E7EB))),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppTheme.primary, width: 1.5)),
          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
          suffixIcon: IconButton(
            icon: Icon(_obscure ? Icons.visibility_off : Icons.visibility, color: Colors.grey),
            onPressed: () => setState(() => _obscure = !_obscure),
          ),
        ),
      ),
    ]);
  }
}
