// lib/screens/home_screen.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/question_model.dart';
import '../models/user_model.dart';
import '../services/local_storage_service.dart';
import '../theme/app_theme.dart';
import 'category_screen.dart';
import 'profile_screen.dart';
import 'rewards_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _db = LocalStorageService();
  int _navIdx = 0;
  // FIX: use Timer instead of recursive Future.delayed to prevent memory leak
  Timer? _tickerTimer;

  final _tickers = [
    '🎉 Rahul from Delhi won ₹8 on Science!',
    '⚡ Priya scored 15/15 — ₹14 earned!',
    '🔥 Amit — 7-day streak +500 credits!',
    '💰 Sneha withdrew ₹50 via UPI!',
    '🎮 300+ players online now!',
    '🏆 Kumar cracked the Math quiz perfectly!',
  ];
  int _tickerIdx = 0;

  @override
  void initState() {
    super.initState();
    // FIX: periodic timer cancels cleanly on dispose
    _tickerTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      if (!mounted) return;
      setState(() => _tickerIdx = (_tickerIdx + 1) % _tickers.length);
    });
  }

  @override
  void dispose() {
    _tickerTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<UserModel?>(
      stream: _db.streamUser(),
      builder: (ctx, snap) {
        final user = snap.data;
        return Scaffold(
          body: IndexedStack(
            index: _navIdx,
            children: [
              _HomeTab(user: user, tickerMsg: _tickers[_tickerIdx]),
              RewardsScreen(user: user),
              ProfileScreen(user: user),
              SettingsScreen(user: user),
            ],
          ),
          bottomNavigationBar: _buildNav(),
        );
      },
    );
  }

  Widget _buildNav() {
    const items = [
      {'icon': Icons.home_rounded, 'label': 'Home'},
      {'icon': Icons.monetization_on_rounded, 'label': 'Rewards'},
      {'icon': Icons.person_rounded, 'label': 'Profile'},
      {'icon': Icons.settings_rounded, 'label': 'Settings'},
    ];
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey.shade200)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 12)],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 60,
          child: Row(
            children: List.generate(items.length, (i) {
              final sel = _navIdx == i;
              return Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _navIdx = i),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(items[i]['icon'] as IconData,
                          color: sel ? AppTheme.primary : Colors.grey.shade400,
                          size: 24),
                      const SizedBox(height: 2),
                      Text(items[i]['label'] as String,
                          style: GoogleFonts.outfit(
                              fontSize: 10,
                              fontWeight: sel ? FontWeight.w800 : FontWeight.w500,
                              color: sel ? AppTheme.primary : Colors.grey.shade400)),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

// ── Home Tab ──
class _HomeTab extends StatelessWidget {
  final UserModel? user;
  final String tickerMsg;
  const _HomeTab({required this.user, required this.tickerMsg});

  String get _initial => (user?.name.isNotEmpty == true) ? user!.name[0].toUpperCase() : 'U';

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(child: _hero(context)),
        SliverToBoxAdapter(child: _ticker()),
        SliverToBoxAdapter(child: _dailyBanner(context)),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 6),
            child: Row(children: [
              Text('Quiz Categories', style: GoogleFonts.outfit(
                  fontWeight: FontWeight.w800, fontSize: 16, color: const Color(0xFF111111))),
              const SizedBox(width: 6),
              Text('970+ questions', style: GoogleFonts.outfit(
                  fontSize: 12, color: Colors.grey.shade500)),
            ]),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          sliver: SliverGrid(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              childAspectRatio: 2.1,
            ),
            delegate: SliverChildBuilderDelegate(
              (_, i) => _CategoryCard(cat: kCategories[i], user: user),
              childCount: kCategories.length,
            ),
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 24)),
      ],
    );
  }

  Widget _hero(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft, end: Alignment.bottomRight,
          colors: [AppTheme.primary, AppTheme.primary2],
        ),
      ),
      padding: EdgeInsets.fromLTRB(16, MediaQuery.of(context).padding.top + 12, 16, 18),
      child: Column(
        children: [
          // Top bar
          Row(
            children: [
              Container(
                width: 44, height: 44,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.22),
                  border: Border.all(color: Colors.white.withOpacity(0.44), width: 2),
                ),
                child: user?.photoUrl != null
                    ? ClipOval(child: Image.network(user!.photoUrl!, fit: BoxFit.cover))
                    : Center(child: Text(_initial,
                        style: GoogleFonts.outfit(fontWeight: FontWeight.w900,
                            fontSize: 18, color: Colors.white))),
              ),
              const SizedBox(width: 12),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(user != null ? 'Hello, ${user!.name.split(' ')[0]}!' : 'Welcome!',
                    style: GoogleFonts.outfit(fontWeight: FontWeight.w800,
                        fontSize: 15, color: Colors.white)),
                Text('Pick a category to start earning',
                    style: GoogleFonts.outfit(fontSize: 11, color: Colors.white60)),
              ])),
              // Coins pill
              GestureDetector(
                onTap: () {},
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white.withOpacity(0.3)),
                  ),
                  child: Row(children: [
                    const Text('🪙', style: TextStyle(fontSize: 14)),
                    const SizedBox(width: 4),
                    Text('${user?.credits ?? 500}',
                        style: GoogleFonts.outfit(
                            fontWeight: FontWeight.w900, fontSize: 14, color: Colors.white)),
                  ]),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          // Stats row
          Row(
            children: [
              _stat('${user?.credits ?? 500}', 'Credits'),
              _stat('${user?.streak ?? 0}🔥', 'Streak'),
              _stat('${user?.totalWins ?? 0}', 'Wins'),
              _stat('₹${(user?.moneyBalance ?? 0).toStringAsFixed(2)}', 'Earned'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _stat(String val, String lbl) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 3),
        padding: const EdgeInsets.symmetric(vertical: 9),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.13),
          borderRadius: BorderRadius.circular(11),
        ),
        child: Column(children: [
          Text(val, style: GoogleFonts.outfit(
              fontWeight: FontWeight.w900, fontSize: 15, color: Colors.white)),
          Text(lbl, style: GoogleFonts.outfit(fontSize: 10, color: Colors.white60)),
        ]),
      ),
    );
  }

  Widget _ticker() {
    return Container(
      color: const Color(0xFFF9FAFB),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: AppTheme.red.withOpacity(0.1),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Row(children: [
              Container(width: 6, height: 6,
                  decoration: const BoxDecoration(color: AppTheme.red, shape: BoxShape.circle)),
              const SizedBox(width: 4),
              Text('LIVE', style: GoogleFonts.outfit(
                  fontWeight: FontWeight.w800, fontSize: 10, color: AppTheme.red)),
            ]),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 400),
              child: Text(tickerMsg, key: ValueKey(tickerMsg),
                  style: GoogleFonts.dmSans(fontSize: 12, color: Colors.grey.shade600),
                  overflow: TextOverflow.ellipsis),
            ),
          ),
        ],
      ),
    );
  }

  Widget _dailyBanner(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(context,
          MaterialPageRoute(builder: (_) => CategoryScreen(cat: kCategories[0], user: user))),
      child: Container(
        margin: const EdgeInsets.fromLTRB(16, 10, 16, 4),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFF97316), Color(0xFFEA580C)],
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            const Text('⚡', style: TextStyle(fontSize: 32)),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Daily Challenge — FREE!',
                  style: GoogleFonts.outfit(fontWeight: FontWeight.w800,
                      fontSize: 14, color: Colors.white)),
              Text('GK · 15 Qs · 5 sec · Win ₹ if 10+ correct',
                  style: GoogleFonts.outfit(fontSize: 11, color: Colors.white70)),
            ])),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text('FREE',
                  style: GoogleFonts.outfit(fontWeight: FontWeight.w800,
                      fontSize: 11, color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Category Card ──
class _CategoryCard extends StatelessWidget {
  final QuizCategory cat;
  final UserModel? user;
  const _CategoryCard({required this.cat, required this.user});

  @override
  Widget build(BuildContext context) {
    final color = Color(int.parse('0xFF${cat.color.substring(1)}'));
    return GestureDetector(
      onTap: () => _showConfirm(context, color),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8)],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(
          children: [
            Container(
              width: 40, height: 40,
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(child: Text(cat.emoji, style: const TextStyle(fontSize: 18))),
            ),
            const SizedBox(width: 10),
            Expanded(child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(cat.name,
                    style: GoogleFonts.outfit(fontWeight: FontWeight.w700,
                        fontSize: 12, color: const Color(0xFF111111)),
                    maxLines: 1, overflow: TextOverflow.ellipsis),
                Text(cat.isFree ? 'FREE' : '${cat.entryCost} credits',
                    style: GoogleFonts.outfit(
                        fontSize: 10,
                        color: cat.isFree ? AppTheme.green : Colors.grey.shade500)),
              ],
            )),
            if (cat.isFree)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: AppTheme.greenLight,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text('FREE',
                    style: GoogleFonts.outfit(
                        fontSize: 9, fontWeight: FontWeight.w800, color: AppTheme.green)),
              ),
          ],
        ),
      ),
    );
  }

  void _showConfirm(BuildContext context, Color color) {
    final credits = user?.credits ?? 500;
    final canAfford = cat.isFree || credits >= cat.entryCost;

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(cat.emoji, style: const TextStyle(fontSize: 48)),
            const SizedBox(height: 8),
            Text('Start ${cat.name} Quiz?',
                style: GoogleFonts.outfit(fontWeight: FontWeight.w900, fontSize: 20)),
            const SizedBox(height: 16),
            _row('Category', cat.name),
            _row('Questions', '15 · 5 second timer'),
            _row('Entry Cost', cat.isFree ? 'FREE' : '${cat.entryCost} credits'),
            _row('Win Condition', '10+ out of 15 correct'),
            _row('Max Earn', 'Up to ₹14 cash'),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppTheme.primaryLight,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text('💡 ₹4 base for 10/15 + ₹2 per extra correct. Perfect 15/15 = ₹14!',
                  style: GoogleFonts.outfit(
                      fontSize: 12, color: AppTheme.primary, fontWeight: FontWeight.w600),
                  textAlign: TextAlign.center),
            ),
            const SizedBox(height: 16),
            if (!canAfford) ...[
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppTheme.redLight,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text('❌ Not enough credits! You need ${cat.entryCost} credits.',
                    style: GoogleFonts.outfit(
                        fontSize: 12, color: AppTheme.red, fontWeight: FontWeight.w600),
                    textAlign: TextAlign.center),
              ),
              const SizedBox(height: 12),
            ],
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: canAfford ? () {
                  Navigator.pop(context);
                  Navigator.push(context, MaterialPageRoute(
                      builder: (_) => CategoryScreen(cat: cat, user: user)));
                } : null,
                icon: const Icon(Icons.play_arrow_rounded),
                label: Text(cat.isFree ? 'Start FREE' : 'Start — ${cat.entryCost} Credits',
                    style: GoogleFonts.outfit(fontWeight: FontWeight.w800, fontSize: 15)),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  backgroundColor: color,
                ),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel', style: GoogleFonts.outfit(color: Colors.grey)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _row(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: GoogleFonts.dmSans(color: Colors.grey.shade600, fontSize: 13)),
          Text(value, style: GoogleFonts.outfit(fontWeight: FontWeight.w700, fontSize: 13)),
        ],
      ),
    );
  }
}
