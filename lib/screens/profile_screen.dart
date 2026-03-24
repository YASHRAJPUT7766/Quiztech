// lib/screens/profile_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../services/local_storage_service.dart';
import '../theme/app_theme.dart';
import 'login_screen.dart';

class ProfileScreen extends StatefulWidget {
  final UserModel? user;
  const ProfileScreen({super.key, required this.user});
  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _db = LocalStorageService();
  final _nameC = TextEditingController();
  bool _editingName = false;

  @override
  void initState() {
    super.initState();
    _nameC.text = widget.user?.name ?? '';
  }

  @override
  void didUpdateWidget(ProfileScreen old) {
    super.didUpdateWidget(old);
    if (widget.user?.name != old.user?.name) {
      _nameC.text = widget.user?.name ?? '';
    }
  }

  Future<void> _saveName() async {
    final uid = widget.user?.uid;
    if (uid == null || _nameC.text.trim().isEmpty) return;
    await _db.updateName(uid, _nameC.text.trim());
    setState(() => _editingName = false);
    _showToast('Name updated!');
  }

  Future<void> _signOut() async {
    await AuthService().signOut();
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LoginScreen()), (_) => false);
  }

  void _showToast(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(msg), backgroundColor: AppTheme.green,
        behavior: SnackBarBehavior.floating));
  }

  String get _initial =>
      widget.user?.name.isNotEmpty == true ? widget.user!.name[0].toUpperCase() : 'U';

  @override
  Widget build(BuildContext context) {
    final user = widget.user;
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(child: _hero(user)),
        SliverToBoxAdapter(child: _statsCard(user)),
        SliverToBoxAdapter(child: _nameEdit()),
        SliverToBoxAdapter(child: _referralCard(user)),
        SliverToBoxAdapter(child: _menuSection()),
        SliverToBoxAdapter(child: _historySection(user)),
        const SliverToBoxAdapter(child: SizedBox(height: 24)),
      ],
    );
  }

  Widget _hero(UserModel? user) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft, end: Alignment.bottomRight,
          colors: [AppTheme.primary, AppTheme.primary2],
        ),
      ),
      padding: EdgeInsets.fromLTRB(
          16, MediaQuery.of(context).padding.top + 24, 16, 40),
      child: Column(
        children: [
          Stack(
            alignment: Alignment.bottomRight,
            children: [
              Container(
                width: 80, height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.22),
                  border: Border.all(color: Colors.white.withOpacity(0.5), width: 3),
                ),
                child: user?.photoUrl != null
                    ? ClipOval(child: Image.network(user!.photoUrl!, fit: BoxFit.cover))
                    : Center(child: Text(_initial,
                        style: GoogleFonts.outfit(fontWeight: FontWeight.w900,
                            fontSize: 32, color: Colors.white))),
              ),
              Container(
                width: 26, height: 26,
                decoration: const BoxDecoration(
                    shape: BoxShape.circle, color: Colors.white),
                child: const Icon(Icons.edit, size: 14, color: AppTheme.primary),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(user?.name ?? 'Player',
              style: GoogleFonts.outfit(fontWeight: FontWeight.w900,
                  fontSize: 22, color: Colors.white)),
          const SizedBox(height: 4),
          Text(user?.email ?? '',
              style: GoogleFonts.outfit(fontSize: 13, color: Colors.white54)),
        ],
      ),
    );
  }

  Widget _statsCard(UserModel? user) {
    return Transform.translate(
      offset: const Offset(0, -18),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.shade200),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 12)],
          ),
          child: Row(
            children: [
              _pStat('${user?.credits ?? 0}', 'Credits'),
              _pStat('${user?.streak ?? 0}🔥', 'Streak'),
              _pStat('${user?.totalWins ?? 0}', 'Wins'),
              _pStat('₹${(user?.moneyBalance ?? 0).toStringAsFixed(0)}', 'Earned'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _pStat(String val, String lbl) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14),
        child: Column(children: [
          Text(val, style: GoogleFonts.outfit(fontWeight: FontWeight.w900, fontSize: 18)),
          Text(lbl, style: GoogleFonts.outfit(fontSize: 11, color: Colors.grey.shade500)),
        ]),
      ),
    );
  }

  Widget _nameEdit() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.grey.shade200),
        ),
        padding: const EdgeInsets.all(14),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('DISPLAY NAME',
              style: GoogleFonts.outfit(
                  fontSize: 11, fontWeight: FontWeight.w700,
                  color: Colors.grey.shade500, letterSpacing: 0.5)),
          const SizedBox(height: 8),
          Row(children: [
            Expanded(
              child: TextField(
                controller: _nameC,
                enabled: _editingName,
                style: GoogleFonts.outfit(fontWeight: FontWeight.w700, fontSize: 15),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: _editingName ? Colors.white : const Color(0xFFF3F4F6),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(
                          color: _editingName ? AppTheme.primary : Colors.transparent)),
                  enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: AppTheme.primary, width: 1.5)),
                  disabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: Colors.transparent)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                ),
              ),
            ),
            const SizedBox(width: 10),
            ElevatedButton(
              onPressed: _editingName ? _saveName : () => setState(() => _editingName = true),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primary,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              ),
              child: Text(_editingName ? 'Save' : 'Edit',
                  style: GoogleFonts.outfit(fontWeight: FontWeight.w800, fontSize: 13)),
            ),
          ]),
        ]),
      ),
    );
  }

  Widget _referralCard(UserModel? user) {
    final refCode = user?.referralCode ?? '------';
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(colors: [AppTheme.primary, AppTheme.primary2]),
          borderRadius: BorderRadius.circular(16),
        ),
        padding: const EdgeInsets.all(16),
        child: Row(children: [
          const Text('🎁', style: TextStyle(fontSize: 28)),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Your Referral Code',
                style: GoogleFonts.outfit(color: Colors.white70, fontSize: 12)),
            Text(refCode,
                style: GoogleFonts.outfit(
                    fontWeight: FontWeight.w900, fontSize: 22, color: Colors.white,
                    letterSpacing: 3)),
            Text('Friend joins = +100 credits each!',
                style: GoogleFonts.outfit(color: Colors.white60, fontSize: 11)),
          ])),
          IconButton(
            onPressed: () {
              Clipboard.setData(ClipboardData(text: refCode));
              _showToast('Code copied! 📋');
            },
            icon: const Icon(Icons.copy, color: Colors.white),
          ),
        ]),
      ),
    );
  }

  Widget _menuSection() {
    final items = [
      _MenuItem(Icons.history_rounded, 'Quiz History', 'See all past quizzes', Colors.blue, () {}),
      _MenuItem(Icons.card_giftcard_rounded, 'Promo Code', 'Redeem for 500 credits', Colors.green,
          () => _showPromoDialog()),
      _MenuItem(Icons.share_rounded, 'Share App', 'Invite friends & earn', Colors.orange, () {}),
      _MenuItem(Icons.help_outline_rounded, 'Help & Support', 'Get help', Colors.purple, () {}),
      _MenuItem(Icons.logout_rounded, 'Sign Out', '', AppTheme.red, _signOut),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: items.map((item) => Container(
          margin: const EdgeInsets.only(bottom: 6),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: ListTile(
            leading: Container(
              width: 36, height: 36,
              decoration: BoxDecoration(
                  shape: BoxShape.circle, color: item.color.withOpacity(0.12)),
              child: Icon(item.icon, color: item.color, size: 18),
            ),
            title: Text(item.title,
                style: GoogleFonts.dmSans(fontWeight: FontWeight.w600, fontSize: 14)),
            subtitle: item.subtitle.isNotEmpty
                ? Text(item.subtitle,
                    style: GoogleFonts.dmSans(fontSize: 11, color: Colors.grey.shade500))
                : null,
            trailing: const Icon(Icons.chevron_right, color: Colors.grey, size: 18),
            onTap: item.onTap,
          ),
        )).toList(),
      ),
    );
  }

  Widget _historySection(UserModel? user) {
    final history = user?.quizHistory.reversed.take(5).toList() ?? [];
    if (history.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Recent Quizzes',
              style: GoogleFonts.outfit(fontWeight: FontWeight.w800, fontSize: 16)),
          const SizedBox(height: 10),
          ...history.map((h) {
            final won = h['won'] == true;
            final score = h['score'] ?? 0;
            final total = h['total'] ?? 15;
            final cat = h['category'] ?? 'gk';
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: ListTile(
                leading: Container(
                  width: 38, height: 38,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: won ? AppTheme.greenLight : AppTheme.redLight,
                  ),
                  child: Center(child: Text(won ? '🏆' : '😞',
                      style: const TextStyle(fontSize: 18))),
                ),
                title: Text(cat.toString().toUpperCase(),
                    style: GoogleFonts.outfit(fontWeight: FontWeight.w700, fontSize: 13)),
                subtitle: Text(won ? 'Won!' : 'Lost',
                    style: GoogleFonts.dmSans(
                        fontSize: 11, color: won ? AppTheme.green : AppTheme.red)),
                trailing: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text('$score/$total',
                        style: GoogleFonts.outfit(
                            fontWeight: FontWeight.w900, fontSize: 16,
                            color: won ? AppTheme.green : AppTheme.red)),
                    if (won && h['moneyEarned'] != null)
                      Text('+₹${(h['moneyEarned'] as num).toStringAsFixed(2)}',
                          style: GoogleFonts.outfit(fontSize: 10, color: AppTheme.green)),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  void _showPromoDialog() {
    final c = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('🎟️ Promo Code',
            style: GoogleFonts.outfit(fontWeight: FontWeight.w900)),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          Text('Enter a valid promo code to get 500 bonus credits!',
              style: GoogleFonts.dmSans(color: Colors.grey.shade600)),
          const SizedBox(height: 14),
          TextField(
            controller: c,
            textCapitalization: TextCapitalization.characters,
            decoration: InputDecoration(
              hintText: 'e.g. ABCDE',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ]),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              final uid = widget.user?.uid;
              if (uid == null) return;
              final error = await _db.redeemPromo(uid, c.text.trim().toUpperCase());
              if (!context.mounted) return;
              Navigator.pop(context);
              if (error == null) {
                _showToast('🎉 +500 Credits Added!');
              } else {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text(error), backgroundColor: AppTheme.red));
              }
            },
            child: Text('Redeem', style: GoogleFonts.outfit(fontWeight: FontWeight.w800)),
          ),
        ],
      ),
    );
  }
}

class _MenuItem {
  final IconData icon;
  final String title, subtitle;
  final Color color;
  final VoidCallback onTap;
  const _MenuItem(this.icon, this.title, this.subtitle, this.color, this.onTap);
}
