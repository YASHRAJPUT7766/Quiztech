// lib/screens/result_screen.dart
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/question_model.dart';
import '../models/user_model.dart';
import '../theme/app_theme.dart';
import 'home_screen.dart';
import 'category_screen.dart';

class ResultScreen extends StatefulWidget {
  final QuizCategory cat;
  final int score;
  final int total;
  final double moneyEarned;
  final int creditsChange;
  final bool won;
  final List<QuestionModel> questions;
  final List<int?> userAnswers;
  // FIX: pass user so Play Again can go back to CategoryScreen
  final UserModel? user;

  const ResultScreen({
    super.key,
    required this.cat,
    required this.score,
    required this.total,
    required this.moneyEarned,
    required this.creditsChange,
    required this.won,
    required this.questions,
    required this.userAnswers,
    this.user,
  });

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> with SingleTickerProviderStateMixin {
  late ConfettiController _confetti;
  late AnimationController _anim;
  late Animation<double> _scoreFill;

  @override
  void initState() {
    super.initState();
    _confetti = ConfettiController(duration: const Duration(seconds: 4));
    _anim = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200));
    _scoreFill = Tween<double>(begin: 0, end: widget.score / widget.total)
        .animate(CurvedAnimation(parent: _anim, curve: Curves.easeInOut));

    _anim.forward();
    if (widget.won) {
      Future.delayed(const Duration(milliseconds: 300), () => _confetti.play());
    }
  }

  @override
  void dispose() {
    _confetti.dispose();
    _anim.dispose();
    super.dispose();
  }

  String get _emoji {
    final pct = widget.score / widget.total;
    if (pct == 1.0) return '🏆';
    if (pct >= 0.8) return '🎉';
    if (pct >= 0.67) return '😊';
    if (pct >= 0.5) return '😐';
    return '😞';
  }

  String get _title {
    final pct = widget.score / widget.total;
    if (pct == 1.0) return 'Perfect Score!';
    if (pct >= 0.8) return 'Excellent!';
    if (pct >= 0.67) return 'Well Done!';
    if (pct >= 0.5) return 'Good Try!';
    return 'Better Luck Next Time!';
  }

  Color get _heroColor {
    if (widget.won) return AppTheme.primary;
    return const Color(0xFF6B7280);
  }

  @override
  Widget build(BuildContext context) {
    final pct = (widget.score / widget.total * 100).round();

    return Scaffold(
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              // Hero section
              SliverToBoxAdapter(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft, end: Alignment.bottomRight,
                      colors: [_heroColor, _heroColor.withOpacity(0.7)],
                    ),
                  ),
                  padding: EdgeInsets.fromLTRB(
                      24, MediaQuery.of(context).padding.top + 20, 24, 80),
                  child: Column(
                    children: [
                      Text(_emoji, style: const TextStyle(fontSize: 72)),
                      const SizedBox(height: 10),
                      Text(_title,
                          style: GoogleFonts.outfit(
                              fontWeight: FontWeight.w900, fontSize: 28, color: Colors.white)),
                      const SizedBox(height: 4),
                      Text('${widget.cat.name} Quiz',
                          style: GoogleFonts.outfit(fontSize: 14, color: Colors.white70)),
                      if (widget.won) ...[
                        const SizedBox(height: 10),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text('🏆 You Won! ₹${widget.moneyEarned.toStringAsFixed(2)} Earned',
                              style: GoogleFonts.outfit(
                                  fontWeight: FontWeight.w800, fontSize: 14, color: Colors.white)),
                        ),
                      ],
                    ],
                  ),
                ),
              ),

              // Score card
              SliverToBoxAdapter(
                child: Transform.translate(
                  offset: const Offset(0, -48),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 18),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(22),
                        boxShadow: [BoxShadow(
                            color: Colors.black.withOpacity(0.1), blurRadius: 24)],
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              // Score circle
                              AnimatedBuilder(
                                animation: _anim,
                                builder: (_, __) => Container(
                                  width: 100, height: 100,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    gradient: LinearGradient(
                                      colors: [_heroColor, _heroColor.withOpacity(0.7)],
                                    ),
                                    boxShadow: [BoxShadow(
                                        color: _heroColor.withOpacity(0.3),
                                        blurRadius: 16, offset: const Offset(0, 6))],
                                  ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text('$pct%',
                                          style: GoogleFonts.outfit(
                                              fontWeight: FontWeight.w900,
                                              fontSize: 26, color: Colors.white)),
                                      Text('Score',
                                          style: GoogleFonts.outfit(
                                              fontSize: 11, color: Colors.white70)),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(width: 20),
                              // Quick stats
                              Expanded(child: Column(children: [
                                _quickStat(Icons.check_circle_rounded,
                                    '${widget.score} Correct', AppTheme.green),
                                const SizedBox(height: 8),
                                _quickStat(Icons.cancel_rounded,
                                    '${widget.total - widget.score} Wrong', AppTheme.red),
                                const SizedBox(height: 8),
                                _quickStat(Icons.category_rounded,
                                    widget.cat.name, AppTheme.primary),
                              ])),
                            ],
                          ),
                          const SizedBox(height: 16),
                          // Progress bar
                          AnimatedBuilder(
                            animation: _scoreFill,
                            builder: (_, __) => Column(children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(5),
                                child: LinearProgressIndicator(
                                  value: _scoreFill.value,
                                  minHeight: 10,
                                  backgroundColor: Colors.grey.shade200,
                                  valueColor: AlwaysStoppedAnimation<Color>(_heroColor),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('0', style: GoogleFonts.outfit(
                                      fontSize: 11, color: Colors.grey.shade500)),
                                  Text('Win line: 10',
                                      style: GoogleFonts.outfit(
                                          fontSize: 11, color: Colors.orange,
                                          fontWeight: FontWeight.w700)),
                                  Text('${widget.total}',
                                      style: GoogleFonts.outfit(
                                          fontSize: 11, color: Colors.grey.shade500)),
                                ],
                              ),
                            ]),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              // Earnings card
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(18, -28, 18, 0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    padding: const EdgeInsets.all(18),
                    child: Column(children: [
                      Row(children: [
                        const Text('💰', style: TextStyle(fontSize: 18)),
                        const SizedBox(width: 8),
                        Text('Earnings Breakdown',
                            style: GoogleFonts.outfit(
                                fontWeight: FontWeight.w800, fontSize: 15)),
                      ]),
                      const SizedBox(height: 14),
                      _earnRow('Entry Cost',
                          widget.cat.isFree ? 'FREE' : '${widget.creditsChange} credits',
                          widget.creditsChange < 0 ? AppTheme.red : Colors.grey),
                      const Divider(height: 1),
                      _earnRow('Cash Earned',
                          widget.won ? '+₹${widget.moneyEarned.toStringAsFixed(2)}' : '₹0',
                          widget.won ? AppTheme.green : Colors.grey),
                      const Divider(height: 1),
                      _earnRow('Score',
                          '${widget.score}/${widget.total}',
                          AppTheme.primary),
                    ]),
                  ),
                ),
              ),

              // Not enough msg
              if (!widget.won) SliverToBoxAdapter(
                child: Container(
                  margin: const EdgeInsets.fromLTRB(18, 12, 18, 0),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEF3C7),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Colors.orange.withOpacity(0.3)),
                  ),
                  child: Text(
                    '⚠️ You needed 10+ to win. You scored ${widget.score}. '
                    '${10 - widget.score > 0 ? "Just ${10 - widget.score} more correct!" : ""}',
                    style: GoogleFonts.outfit(
                        fontSize: 13, color: const Color(0xFF92400E), fontWeight: FontWeight.w600),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),

              // Answer review
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(18, 16, 18, 6),
                  child: Text('Answer Review',
                      style: GoogleFonts.outfit(fontWeight: FontWeight.w800, fontSize: 16)),
                ),
              ),
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (_, i) => _answerItem(i),
                  childCount: widget.questions.length,
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 110)),
            ],
          ),

          // Action buttons at bottom
          Positioned(
            bottom: 0, left: 0, right: 0,
            child: Container(
              color: Colors.white,
              padding: EdgeInsets.fromLTRB(
                  16, 12, 16, MediaQuery.of(context).padding.bottom + 12),
              child: Row(children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(builder: (_) => const HomeScreen()),
                        (_) => false),
                    icon: const Icon(Icons.home_rounded),
                    label: Text('Home', style: GoogleFonts.outfit(fontWeight: FontWeight.w700)),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  // FIX: Play Again should go to CategoryScreen, not HomeScreen
                  child: ElevatedButton.icon(
                    onPressed: () => Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(
                          builder: (_) => CategoryScreen(
                            cat: widget.cat,
                            user: widget.user,
                          ),
                        ),
                        (route) => route.isFirst),
                    icon: const Icon(Icons.replay_rounded),
                    label: Text('Play Again', style: GoogleFonts.outfit(fontWeight: FontWeight.w800)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _heroColor,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                  ),
                ),
              ]),
            ),
          ),

          // Confetti
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confetti,
              blastDirection: pi / 2,
              maxBlastForce: 5,
              minBlastForce: 2,
              emissionFrequency: 0.05,
              numberOfParticles: 50,
              gravity: 0.1,
            ),
          ),
        ],
      ),
    );
  }

  Widget _quickStat(IconData icon, String label, Color color) {
    return Row(children: [
      Icon(icon, color: color, size: 18),
      const SizedBox(width: 8),
      Text(label, style: GoogleFonts.dmSans(
          fontSize: 13, color: const Color(0xFF374151), fontWeight: FontWeight.w500)),
    ]);
  }

  Widget _earnRow(String label, String value, Color valueColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: GoogleFonts.dmSans(color: Colors.grey.shade600, fontSize: 13)),
          Text(value, style: GoogleFonts.outfit(
              fontWeight: FontWeight.w900, fontSize: 15, color: valueColor)),
        ],
      ),
    );
  }

  Widget _answerItem(int i) {
    final q = widget.questions[i];
    final userAns = widget.userAnswers[i];
    final correct = q.correctIndex;
    final isCorrect = userAns == correct;
    final isSkipped = userAns == null;

    Color bg = isCorrect ? AppTheme.greenLight : (isSkipped ? const Color(0xFFFEF3C7) : AppTheme.redLight);
    Color accent = isCorrect ? AppTheme.green : (isSkipped ? Colors.orange : AppTheme.red);
    String icon = isCorrect ? '✅' : (isSkipped ? '⏭️' : '❌');

    return Container(
      margin: const EdgeInsets.fromLTRB(18, 0, 18, 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: accent.withOpacity(0.3)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Text(icon, style: const TextStyle(fontSize: 16)),
          const SizedBox(width: 8),
          Expanded(child: Text('Q${i + 1}: ${q.question}',
              style: GoogleFonts.outfit(
                  fontWeight: FontWeight.w700, fontSize: 13, color: const Color(0xFF111111)))),
        ]),
        const SizedBox(height: 8),
        Text('✅ Correct: ${q.options[correct]}',
            style: GoogleFonts.dmSans(fontSize: 12, color: AppTheme.green, fontWeight: FontWeight.w600)),
        if (!isCorrect && !isSkipped)
          Text('❌ Your answer: ${q.options[userAns!]}',
              style: GoogleFonts.dmSans(fontSize: 12, color: AppTheme.red)),
        if (isSkipped)
          Text('⏭️ Skipped (time ran out)',
              style: GoogleFonts.dmSans(fontSize: 12, color: Colors.orange)),
      ]),
    );
  }
}
