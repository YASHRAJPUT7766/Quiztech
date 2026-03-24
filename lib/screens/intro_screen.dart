// lib/screens/intro_screen.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme/app_theme.dart';
import 'login_screen.dart';

class IntroScreen extends StatefulWidget {
  const IntroScreen({super.key});
  @override
  State<IntroScreen> createState() => _IntroScreenState();
}

class _IntroScreenState extends State<IntroScreen> {
  final _ctrl = PageController();
  int _page = 0;

  final _slides = [
    _Slide('🎯', 'Play & Win Real Money',
        'Answer quiz questions correctly and earn real ₹ cash rewards directly to your UPI, Paytm or bank account!'),
    _Slide('🔥', '12 Categories, 3200+ Questions',
        'GK, Science, Math, History, Sports, Bollywood, Cricket, Technology and many more exciting categories!'),
    _Slide('💰', 'Free Daily Challenge',
        'Play the Daily GK Challenge for FREE every day! Score 10+ out of 15 to win real money rewards.'),
    _Slide('🏆', 'Streaks & Bonuses',
        'Play daily to build your streak! Get bonus credits on 3-day, 7-day streaks. Refer friends for extra credits!'),
  ];

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _next() {
    if (_page < _slides.length - 1) {
      _ctrl.nextPage(
          duration: const Duration(milliseconds: 350), curve: Curves.easeInOut);
    } else {
      _finish();
    }
  }

  Future<void> _finish() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('seen_intro', true);
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _ctrl,
                onPageChanged: (i) => setState(() => _page = i),
                itemCount: _slides.length,
                itemBuilder: (_, i) => _SlideWidget(slide: _slides[i]),
              ),
            ),
            // Dots
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(_slides.length, (i) => AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: _page == i ? 24 : 8,
                height: 8,
                margin: const EdgeInsets.symmetric(horizontal: 3),
                decoration: BoxDecoration(
                  color: _page == i ? AppTheme.primary : const Color(0xFFE5E7EB),
                  borderRadius: BorderRadius.circular(4),
                ),
              )),
            ),
            const SizedBox(height: 28),
            // Buttons
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _next,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primary,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14)),
                      ),
                      child: Text(
                        _page < _slides.length - 1 ? 'Next →' : 'Get Started 🚀',
                        style: GoogleFonts.outfit(
                            fontWeight: FontWeight.w800, fontSize: 16),
                      ),
                    ),
                  ),
                  if (_page < _slides.length - 1) ...[
                    const SizedBox(height: 10),
                    TextButton(
                      onPressed: _finish,
                      child: Text('Skip',
                          style: GoogleFonts.outfit(
                              color: const Color(0xFF9CA3AF), fontWeight: FontWeight.w600)),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

class _Slide {
  final String emoji, title, desc;
  const _Slide(this.emoji, this.title, this.desc);
}

class _SlideWidget extends StatelessWidget {
  final _Slide slide;
  const _SlideWidget({super.key, required this.slide});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [
                  AppTheme.primary.withOpacity(0.15),
                  AppTheme.primary2.withOpacity(0.08),
                ],
              ),
            ),
            child: Center(
                child: Text(slide.emoji, style: const TextStyle(fontSize: 56))),
          ),
          const SizedBox(height: 36),
          Text(slide.title,
              textAlign: TextAlign.center,
              style: GoogleFonts.outfit(
                  fontSize: 26,
                  fontWeight: FontWeight.w900,
                  color: const Color(0xFF111111),
                  letterSpacing: -0.5)),
          const SizedBox(height: 16),
          Text(slide.desc,
              textAlign: TextAlign.center,
              style: GoogleFonts.dmSans(
                  fontSize: 15, color: const Color(0xFF6B7280), height: 1.6)),
        ],
      ),
    );
  }
}
