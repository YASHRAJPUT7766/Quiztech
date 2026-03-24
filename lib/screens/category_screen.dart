// lib/screens/category_screen.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../data/questions_db.dart';
import '../models/question_model.dart';
import '../models/user_model.dart';
import '../theme/app_theme.dart';
import 'quiz_screen.dart';

class CategoryScreen extends StatelessWidget {
  final QuizCategory cat;
  final UserModel? user;
  const CategoryScreen({super.key, required this.cat, required this.user});

  @override
  Widget build(BuildContext context) {
    final color = Color(int.parse('0xFF${cat.color.substring(1)}'));
    final credits = user?.credits ?? 500;
    final canAfford = cat.isFree || credits >= cat.entryCost;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft, end: Alignment.bottomRight,
                    colors: [color, color.withOpacity(0.7)],
                  ),
                ),
                child: SafeArea(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(height: 20),
                        Text(cat.emoji, style: const TextStyle(fontSize: 64)),
                        const SizedBox(height: 8),
                        Text(cat.name,
                            style: GoogleFonts.outfit(
                                fontWeight: FontWeight.w900,
                                fontSize: 24, color: Colors.white)),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Info cards
                  _infoRow([
                    _InfoItem('15', 'Questions', Icons.quiz_rounded, color),
                    _InfoItem('5s', 'Per Question', Icons.timer_rounded, Colors.orange),
                    _InfoItem(cat.isFree ? 'FREE' : '${cat.entryCost}cr',
                        'Entry', Icons.token_rounded,
                        cat.isFree ? AppTheme.green : AppTheme.primary),
                  ]),
                  const SizedBox(height: 16),
                  _infoRow([
                    _InfoItem('₹14', 'Max Earn', Icons.currency_rupee_rounded, AppTheme.green),
                    _InfoItem('10+', 'Win Score', Icons.emoji_events_rounded, Colors.amber),
                    _InfoItem('₹2', 'Per Correct', Icons.add_circle_rounded, AppTheme.green),
                  ]),
                  const SizedBox(height: 24),

                  // How to win
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: color.withOpacity(0.2)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('📋 How to Win',
                            style: GoogleFonts.outfit(
                                fontWeight: FontWeight.w800, fontSize: 15, color: color)),
                        const SizedBox(height: 10),
                        _rule('Answer 15 questions as fast as possible'),
                        _rule('Each question has 5 second timer'),
                        _rule('Score 10+ to be eligible for cash reward'),
                        _rule('₹4 base for 10/15 + ₹2 per each extra correct'),
                        _rule('Perfect 15/15 = ₹14 cash!'),
                        if (!cat.isFree)
                          _rule('Entry costs ${cat.entryCost} credits'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Credits status
                  if (!cat.isFree) Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: canAfford ? AppTheme.greenLight : AppTheme.redLight,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(children: [
                      Icon(canAfford ? Icons.check_circle : Icons.cancel,
                          color: canAfford ? AppTheme.green : AppTheme.red),
                      const SizedBox(width: 10),
                      Text(canAfford
                          ? 'You have $credits credits. Cost: ${cat.entryCost}'
                          : 'Need ${cat.entryCost} credits, you have $credits',
                          style: GoogleFonts.outfit(
                              fontWeight: FontWeight.w600,
                              color: canAfford ? AppTheme.green : AppTheme.red)),
                    ]),
                  ),

                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: canAfford ? () {
                        final questions = QDB.getQuestions(cat.id);
                        Navigator.pushReplacement(context, MaterialPageRoute(
                            builder: (_) => QuizScreen(
                                cat: cat, questions: questions, user: user)));
                      } : null,
                      icon: const Icon(Icons.play_arrow_rounded, size: 22),
                      label: Text(cat.isFree ? '🚀 Start FREE Quiz' : '🚀 Start Quiz',
                          style: GoogleFonts.outfit(
                              fontWeight: FontWeight.w800, fontSize: 16)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: color,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoRow(List<_InfoItem> items) {
    return Row(
      children: items.map((item) => Expanded(child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: item.color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: item.color.withOpacity(0.2)),
        ),
        child: Column(
          children: [
            Icon(item.icon, color: item.color, size: 22),
            const SizedBox(height: 4),
            Text(item.value,
                style: GoogleFonts.outfit(
                    fontWeight: FontWeight.w900, fontSize: 16, color: item.color)),
            Text(item.label,
                style: GoogleFonts.outfit(fontSize: 10, color: Colors.grey.shade600)),
          ],
        ),
      ))).toList(),
    );
  }

  Widget _rule(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(children: [
        const Icon(Icons.check_rounded, size: 14, color: AppTheme.green),
        const SizedBox(width: 8),
        Expanded(child: Text(text,
            style: GoogleFonts.dmSans(fontSize: 13, color: const Color(0xFF374151)))),
      ]),
    );
  }
}

class _InfoItem {
  final String value, label;
  final IconData icon;
  final Color color;
  const _InfoItem(this.value, this.label, this.icon, this.color);
}
