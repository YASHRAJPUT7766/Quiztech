// lib/screens/rewards_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/user_model.dart';
import '../services/local_storage_service.dart';
import '../theme/app_theme.dart';

class RewardsScreen extends StatefulWidget {
  final UserModel? user;
  const RewardsScreen({super.key, required this.user});
  @override
  State<RewardsScreen> createState() => _RewardsScreenState();
}

class _RewardsScreenState extends State<RewardsScreen> {
  final _db = LocalStorageService();
  String _tab = 'upi';

  final _methods = [
    _Method('upi', '💳 UPI', '₹20 min'),
    _Method('paytm', '📱 Paytm', '₹20 min'),
    _Method('gpay', '🟢 GPay', '₹20 min'),
    _Method('amazon', '🛍️ Amazon', '₹50 min'),
    _Method('flipkart', '🛒 Flipkart', '₹50 min'),
    _Method('bank', '🏦 Bank', '₹100 min'),
  ];

  @override
  Widget build(BuildContext context) {
    final user = widget.user;
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(child: _header(user)),
        SliverToBoxAdapter(child: _howItWorks()),
        SliverToBoxAdapter(child: _tabBar()),
        SliverToBoxAdapter(child: _withdrawForm()),
        const SliverToBoxAdapter(child: SizedBox(height: 24)),
      ],
    );
  }

  Widget _header(UserModel? user) {
    return Container(
      padding: EdgeInsets.fromLTRB(18, MediaQuery.of(context).padding.top + 16, 18, 20),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft, end: Alignment.bottomRight,
          colors: [AppTheme.primary, AppTheme.primary2],
        ),
      ),
      child: Column(
        children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text('Rewards', style: GoogleFonts.outfit(
                fontWeight: FontWeight.w900, fontSize: 24, color: Colors.white)),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white.withOpacity(0.3)),
              ),
              child: Row(children: [
                const Text('🪙', style: TextStyle(fontSize: 18)),
                const SizedBox(width: 6),
                Text('${user?.credits ?? 0}',
                    style: GoogleFonts.outfit(
                        fontWeight: FontWeight.w900, fontSize: 18, color: Colors.white)),
              ]),
            ),
          ]),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withOpacity(0.25)),
            ),
            child: Column(
              children: [
                Text('Total Cash Balance',
                    style: GoogleFonts.outfit(color: Colors.white70, fontSize: 13)),
                const SizedBox(height: 4),
                Text('₹${(user?.moneyBalance ?? 0).toStringAsFixed(2)}',
                    style: GoogleFonts.outfit(
                        fontWeight: FontWeight.w900, fontSize: 40, color: Colors.white)),
                const SizedBox(height: 4),
                Text('Available for withdrawal',
                    style: GoogleFonts.outfit(color: Colors.white60, fontSize: 11)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _howItWorks() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.primaryLight,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('💡 How Earnings Work',
              style: GoogleFonts.outfit(
                  fontWeight: FontWeight.w800, fontSize: 14, color: AppTheme.primary)),
          const SizedBox(height: 10),
          _howRow('Score 10+ out of 15 to qualify for cash'),
          _howRow('Score 10 → ₹4 base + ₹2 per each extra correct'),
          _howRow('Perfect score (15/15) = ₹14 cash!'),
          _howRow('Minimum ₹20 balance required to withdraw'),
          _howRow('Credits can be used to play paid quizzes'),
        ],
      ),
    );
  }

  Widget _howRow(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 5),
      child: Row(children: [
        const Icon(Icons.check_rounded, size: 14, color: AppTheme.primary),
        const SizedBox(width: 8),
        Expanded(child: Text(text,
            style: GoogleFonts.dmSans(fontSize: 13, color: AppTheme.primary))),
      ]),
    );
  }

  Widget _tabBar() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        children: _methods.map((m) {
          final sel = _tab == m.id;
          return GestureDetector(
            onTap: () => setState(() => _tab = m.id),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.only(right: 10),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                gradient: sel ? const LinearGradient(
                    colors: [AppTheme.primary, AppTheme.primary2]) : null,
                color: sel ? null : const Color(0xFFE9E9F0),
                borderRadius: BorderRadius.circular(20),
                boxShadow: sel ? [BoxShadow(
                    color: AppTheme.primary.withOpacity(0.3), blurRadius: 10)] : null,
              ),
              child: Text(m.label,
                  style: GoogleFonts.outfit(
                      fontWeight: FontWeight.w800, fontSize: 13,
                      color: sel ? Colors.white : Colors.grey.shade600)),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _withdrawForm() {
    final method = _methods.firstWhere((m) => m.id == _tab);
    final balance = widget.user?.moneyBalance ?? 0.0;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: _WithdrawForm(
        method: method,
        balance: balance,
        onSubmit: (account, amount) async {
          final uid = widget.user?.uid;
          if (uid == null) return;
          try {
            await _db.submitWithdrawal(
                uid: uid, method: _tab, account: account, amount: amount);
            if (!mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                content: Text('✅ Withdrawal request submitted! 1-3 business days.'),
                backgroundColor: AppTheme.green));
          } catch (e) {
            if (!mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text('Error: ${e.toString()}'),
                backgroundColor: AppTheme.red));
          }
        },
      ),
    );
  }
}

class _WithdrawForm extends StatefulWidget {
  final _Method method;
  final double balance;
  final Function(String account, double amount) onSubmit;
  const _WithdrawForm({required this.method, required this.balance, required this.onSubmit});
  @override
  State<_WithdrawForm> createState() => _WithdrawFormState();
}

class _WithdrawFormState extends State<_WithdrawForm> {
  final _accountC = TextEditingController();
  final _amountC = TextEditingController();
  bool _loading = false;

  double get _minAmount {
    switch (widget.method.id) {
      case 'amazon': case 'flipkart': return 50;
      case 'bank': return 100;
      default: return 20;
    }
  }

  String get _placeholder {
    switch (widget.method.id) {
      case 'upi': return 'yourname@upi';
      case 'paytm': return '10-digit Paytm number';
      case 'gpay': return '10-digit GPay number';
      case 'amazon': return 'Amazon-linked email/phone';
      case 'flipkart': return 'Flipkart-linked email/phone';
      case 'bank': return 'Account number / IFSC';
      default: return 'Enter account details';
    }
  }

  Future<void> _submit() async {
    final account = _accountC.text.trim();
    final amount = double.tryParse(_amountC.text.trim()) ?? 0;
    if (account.isEmpty) {
      _err('Please enter account details'); return;
    }
    if (amount < _minAmount) {
      _err('Minimum withdrawal is ₹$_minAmount'); return;
    }
    if (amount > widget.balance) {
      _err('Insufficient balance'); return;
    }
    setState(() => _loading = true);
    await widget.onSubmit(account, amount);
    if (mounted) {
      setState(() => _loading = false);
      _accountC.clear();
      _amountC.clear();
    }
  }

  void _err(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(msg), backgroundColor: AppTheme.red));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.grey.shade200),
      ),
      padding: const EdgeInsets.all(18),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Withdraw via ${widget.method.label}',
            style: GoogleFonts.outfit(fontWeight: FontWeight.w800, fontSize: 16)),
        const SizedBox(height: 4),
        Text('Min: ${widget.method.minAmount} · Your balance: ₹${widget.balance.toStringAsFixed(2)}',
            style: GoogleFonts.outfit(fontSize: 12, color: Colors.grey.shade500)),
        const SizedBox(height: 16),
        _label('Account Details'),
        TextField(
          controller: _accountC,
          decoration: _deco(_placeholder),
        ),
        const SizedBox(height: 14),
        _label('Amount (₹)'),
        TextField(
          controller: _amountC,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}'))],
          decoration: _deco('Enter amount (min ₹$_minAmount)'),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFFFEF3C7),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            '⚠️ Withdrawals processed in 1-3 business days. '
            'Ensure your account details are correct.',
            style: GoogleFonts.dmSans(fontSize: 12, color: const Color(0xFF92400E)),
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: _loading ? null : _submit,
            icon: _loading
                ? const SizedBox(width: 16, height: 16,
                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                : const Icon(Icons.send_rounded),
            label: Text('Request Withdrawal',
                style: GoogleFonts.outfit(fontWeight: FontWeight.w800, fontSize: 15)),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.green,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
          ),
        ),
      ]),
    );
  }

  Widget _label(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(text.toUpperCase(),
          style: GoogleFonts.outfit(
              fontSize: 10, fontWeight: FontWeight.w700,
              color: Colors.grey.shade500, letterSpacing: 0.5)),
    );
  }

  InputDecoration _deco(String hint) {
    return InputDecoration(
      hintText: hint,
      filled: true, fillColor: const Color(0xFFF9FAFB),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE5E7EB))),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE5E7EB))),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppTheme.primary, width: 1.5)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
    );
  }
}

class _Method {
  final String id, label, minAmount;
  const _Method(this.id, this.label, this.minAmount);
}
