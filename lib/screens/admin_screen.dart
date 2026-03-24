// lib/screens/admin_screen.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/local_storage_service.dart';
import '../theme/app_theme.dart';

class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});
  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  final _db = LocalStorageService();
  int _tab = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Admin Panel',
            style: GoogleFonts.outfit(fontWeight: FontWeight.w900)),
        backgroundColor: AppTheme.red,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // Tab bar
          Container(
            color: AppTheme.red.withOpacity(0.08),
            child: Row(
              children: [
                _tabBtn(0, '💸 Withdrawals'),
                _tabBtn(1, '👥 Users'),
              ],
            ),
          ),
          Expanded(
            child: _tab == 0 ? _withdrawals() : _users(),
          ),
        ],
      ),
    );
  }

  Widget _tabBtn(int idx, String label) {
    final sel = _tab == idx;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _tab = idx),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            border: Border(bottom: BorderSide(
                color: sel ? AppTheme.red : Colors.transparent, width: 2)),
          ),
          child: Text(label, textAlign: TextAlign.center,
              style: GoogleFonts.outfit(
                  fontWeight: FontWeight.w700, fontSize: 13,
                  color: sel ? AppTheme.red : Colors.grey)),
        ),
      ),
    );
  }

  Widget _withdrawals() {
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: _db.getPendingWithdrawals(),
      builder: (ctx, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        final list = snap.data ?? [];
        if (list.isEmpty) {
          return Center(
            child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              const Text('✅', style: TextStyle(fontSize: 48)),
              const SizedBox(height: 12),
              Text('No pending withdrawals',
                  style: GoogleFonts.outfit(fontWeight: FontWeight.w700, fontSize: 16)),
            ]),
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: list.length,
          itemBuilder: (_, i) => _withdrawItem(list[i]),
        );
      },
    );
  }

  Widget _withdrawItem(Map<String, dynamic> w) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8)],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Expanded(child: Text('${w['method']?.toString().toUpperCase() ?? 'UPI'} Withdrawal',
              style: GoogleFonts.outfit(fontWeight: FontWeight.w800, fontSize: 15))),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFFFEF3C7),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text('PENDING',
                style: GoogleFonts.outfit(fontWeight: FontWeight.w800,
                    fontSize: 10, color: Colors.orange)),
          ),
        ]),
        const SizedBox(height: 8),
        _info('Amount', '₹${w['amount']?.toString() ?? '0'}'),
        _info('Account', w['account']?.toString() ?? '-'),
        _info('User ID', (w['uid']?.toString() ?? '').length >= 8
            ? (w['uid'].toString().substring(0, 8) + '...')
            : (w['uid']?.toString() ?? '-')),
        const SizedBox(height: 12),
        Row(children: [
          Expanded(child: OutlinedButton.icon(
            onPressed: () => _updateStatus(w['id'], 'rejected'),
            icon: const Icon(Icons.close, color: AppTheme.red, size: 16),
            label: Text('Reject', style: GoogleFonts.outfit(color: AppTheme.red, fontWeight: FontWeight.w700)),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: AppTheme.red),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          )),
          const SizedBox(width: 10),
          Expanded(child: ElevatedButton.icon(
            onPressed: () => _updateStatus(w['id'], 'approved'),
            icon: const Icon(Icons.check, size: 16),
            label: Text('Approve', style: GoogleFonts.outfit(fontWeight: FontWeight.w700)),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.green,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          )),
        ]),
      ]),
    );
  }

  Widget _info(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(children: [
        Text('$label: ', style: GoogleFonts.dmSans(color: Colors.grey.shade500, fontSize: 12)),
        Expanded(child: Text(value,
            style: GoogleFonts.dmSans(fontWeight: FontWeight.w600, fontSize: 12),
            overflow: TextOverflow.ellipsis)),
      ]),
    );
  }

  Future<void> _updateStatus(String? id, String status) async {
    if (id == null) return;
    await _db.updateWithdrawal(id, status);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Withdrawal ${status}d'),
        backgroundColor: status == 'approved' ? AppTheme.green : AppTheme.red));
  }

  Widget _users() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          const Text('👥', style: TextStyle(fontSize: 48)),
          const SizedBox(height: 12),
          Text('User Management',
              style: GoogleFonts.outfit(fontWeight: FontWeight.w800, fontSize: 18)),
          const SizedBox(height: 8),
          Text('Go to Firebase Console to manage users directly.',
              style: GoogleFonts.dmSans(color: Colors.grey.shade500),
              textAlign: TextAlign.center),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {},
            child: Text('Open Firebase Console',
                style: GoogleFonts.outfit(fontWeight: FontWeight.w700)),
          ),
        ]),
      ),
    );
  }
}
