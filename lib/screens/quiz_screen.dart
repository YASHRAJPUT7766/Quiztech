// lib/screens/quiz_screen.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/question_model.dart';
import '../models/user_model.dart';
import '../services/local_storage_service.dart';
import '../theme/app_theme.dart';
import 'result_screen.dart';

class QuizScreen extends StatefulWidget {
  final QuizCategory cat;
  final List<QuestionModel> questions;
  final UserModel? user;
  const QuizScreen({super.key, required this.cat, required this.questions, required this.user});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> with TickerProviderStateMixin {
  int _qIdx = 0;
  int? _selected;
  int _score = 0;
  int _timeLeft = 5;
  bool _answered = false;
  Timer? _timer;
  late List<int?> _userAnswers;
  bool _saving = false; // FIX: guard against double _finish() call

  late AnimationController _timerAnim;

  @override
  void initState() {
    super.initState();
    _timerAnim = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    );
    _userAnswers = List.filled(widget.questions.length, null);
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _timerAnim.dispose();
    super.dispose();
  }

  void _startTimer() {
    _timeLeft = 5;
    _timerAnim.reset();
    _timerAnim.forward();
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) return;
      setState(() => _timeLeft--);
      if (_timeLeft <= 0) {
        t.cancel();
        _autoNext();
      }
    });
  }

  void _autoNext() {
    if (_answered) return;
    setState(() {
      _answered = true;
      _userAnswers[_qIdx] = null; // skipped
    });
    Future.delayed(const Duration(milliseconds: 800), _next);
  }

  void _answer(int idx) {
    if (_answered) return;
    _timer?.cancel();
    _timerAnim.stop();
    final correct = widget.questions[_qIdx].correctIndex == idx;
    setState(() {
      _selected = idx;
      _answered = true;
      _userAnswers[_qIdx] = idx;
      if (correct) _score++;
    });
    Future.delayed(const Duration(milliseconds: 1200), _next);
  }

  void _next() {
    if (!mounted) return;
    if (_qIdx < widget.questions.length - 1) {
      setState(() {
        _qIdx++;
        _selected = null;
        _answered = false;
      });
      _startTimer();
    } else {
      _finish();
    }
  }

  Future<void> _finish() async {
    // FIX: double-call guard — also cancel timer to prevent autoNext triggering again
    if (_saving) return;
    _timer?.cancel();
    _timerAnim.stop();
    if (mounted) setState(() => _saving = true);

    final won = _score >= 10;
    final extraCorrect = _score > 10 ? _score - 10 : 0;
    // score=10 → ₹4, score=11 → ₹6 ... score=15 → ₹14 (₹2 per correct above 10, base ₹4)
    final moneyEarned = won ? (extraCorrect * 2.0 + 4.0) : 0.0;
    final creditsChange = widget.cat.isFree ? 0 : -widget.cat.entryCost;

    final uid = widget.user?.uid;
    if (uid != null) {
      await LocalStorageService().saveQuizResult(
        uid: uid,
        category: widget.cat.id,
        score: _score,
        totalQuestions: widget.questions.length,
        creditsChange: creditsChange,
        moneyEarned: moneyEarned,
        won: won,
      );
    }

    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => ResultScreen(
          user: widget.user,
          cat: widget.cat,
          score: _score,
          total: widget.questions.length,
          moneyEarned: moneyEarned,
          creditsChange: creditsChange,
          won: won,
          questions: widget.questions,
          userAnswers: _userAnswers,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final q = widget.questions[_qIdx];
    final danger = _timeLeft <= 2;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Header
            _buildHeader(danger),
            // Progress bar
            LinearProgressIndicator(
              value: (_qIdx + 1) / widget.questions.length,
              backgroundColor: Colors.grey.shade200,
              valueColor: AlwaysStoppedAnimation<Color>(
                  Color(int.parse('0xFF${widget.cat.color.substring(1)}'))),
              minHeight: 4,
            ),
            // Meta row
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Question ${_qIdx + 1} of ${widget.questions.length}',
                      style: GoogleFonts.outfit(
                          fontWeight: FontWeight.w700, fontSize: 12,
                          color: Colors.grey.shade500)),
                  Text('Score: $_score ✅',
                      style: GoogleFonts.outfit(
                          fontWeight: FontWeight.w800, fontSize: 13,
                          color: AppTheme.primary)),
                ],
              ),
            ),
            // Question
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.grey.shade200),
                        boxShadow: [BoxShadow(
                            color: Colors.black.withOpacity(0.04), blurRadius: 8)],
                      ),
                      child: Text(q.question,
                          style: GoogleFonts.outfit(
                              fontWeight: FontWeight.w800, fontSize: 17,
                              color: const Color(0xFF111111), height: 1.4)),
                    ),
                    const SizedBox(height: 14),
                    // Options
                    ...List.generate(q.options.length, (i) => _buildOption(i, q)),
                    const SizedBox(height: 80),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      // FIX: disable FAB while saving to prevent double navigation
      floatingActionButton: (_answered && !_saving)
          ? Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _qIdx < widget.questions.length - 1 ? _next : _finish,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    backgroundColor: AppTheme.primary,
                  ),
                  child: Text(
                    _qIdx < widget.questions.length - 1 ? 'Next Question →' : 'See Results 🏆',
                    style: GoogleFonts.outfit(
                        fontWeight: FontWeight.w800, fontSize: 16, color: Colors.white),
                  ),
                ),
              ),
            )
          : (_saving
              ? const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: SizedBox(
                    width: double.infinity,
                    child: Center(child: CircularProgressIndicator()),
                  ),
                )
              : null),
    );
  }

  Widget _buildHeader(bool danger) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => _showQuitDialog(),
            child: Container(
              width: 32, height: 32,
              decoration: BoxDecoration(
                  shape: BoxShape.circle, color: Colors.grey.shade100),
              child: const Icon(Icons.close, size: 16, color: Colors.grey),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(widget.cat.name,
                style: GoogleFonts.outfit(fontWeight: FontWeight.w800, fontSize: 15)),
          ),
          // Timer circle
          SizedBox(
            width: 44, height: 44,
            child: Stack(
              alignment: Alignment.center,
              children: [
                AnimatedBuilder(
                  animation: _timerAnim,
                  builder: (_, __) => CircularProgressIndicator(
                    value: 1 - _timerAnim.value,
                    strokeWidth: 3,
                    backgroundColor: Colors.grey.shade200,
                    valueColor: AlwaysStoppedAnimation<Color>(
                        danger ? AppTheme.red : AppTheme.primary),
                  ),
                ),
                Text('$_timeLeft',
                    style: GoogleFonts.outfit(
                        fontWeight: FontWeight.w900,
                        fontSize: 16,
                        color: danger ? AppTheme.red : AppTheme.primary)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOption(int i, QuestionModel q) {
    final letters = ['A', 'B', 'C', 'D'];
    Color bg = Colors.white;
    Color border = Colors.grey.shade300;
    Color text = const Color(0xFF374151);
    Color letterBg = const Color(0xFFF3F4F6);
    Color letterColor = Colors.grey;

    if (_answered) {
      if (i == q.correctIndex) {
        bg = AppTheme.greenLight;
        border = AppTheme.green;
        text = AppTheme.green;
        letterBg = AppTheme.green;
        letterColor = Colors.white;
      } else if (i == _selected && i != q.correctIndex) {
        bg = AppTheme.redLight;
        border = AppTheme.red;
        text = AppTheme.red;
        letterBg = AppTheme.red;
        letterColor = Colors.white;
      }
    } else if (_selected == i) {
      bg = AppTheme.primaryLight;
      border = AppTheme.primary;
      text = AppTheme.primary;
    }

    return GestureDetector(
      onTap: () => _answer(i),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: border, width: 1.5),
        ),
        child: Row(children: [
          Container(
            width: 28, height: 28,
            decoration: BoxDecoration(shape: BoxShape.circle, color: letterBg),
            child: Center(child: Text(letters[i],
                style: GoogleFonts.outfit(
                    fontWeight: FontWeight.w800, fontSize: 13, color: letterColor))),
          ),
          const SizedBox(width: 12),
          Expanded(child: Text(q.options[i],
              style: GoogleFonts.dmSans(fontSize: 14, color: text, fontWeight: FontWeight.w500))),
          if (_answered && i == q.correctIndex)
            const Icon(Icons.check_circle, color: AppTheme.green, size: 20),
          if (_answered && i == _selected && i != q.correctIndex)
            const Icon(Icons.cancel, color: AppTheme.red, size: 20),
        ]),
      ),
    );
  }

  void _showQuitDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Quit Quiz?', style: GoogleFonts.outfit(fontWeight: FontWeight.w900)),
        content: Text('Your progress will be lost and entry credits won\'t be refunded.',
            style: GoogleFonts.dmSans()),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Continue', style: GoogleFonts.outfit(color: AppTheme.primary)),
          ),
          ElevatedButton(
            onPressed: () {
              _timer?.cancel();
              Navigator.of(context)
                ..pop()
                ..pop();
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.red),
            child: Text('Quit', style: GoogleFonts.outfit(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
