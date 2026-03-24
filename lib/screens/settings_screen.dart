// lib/screens/settings_screen.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../main.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../services/local_storage_service.dart';
import '../theme/app_theme.dart';
import 'login_screen.dart';
import 'admin_screen.dart';

class SettingsScreen extends StatefulWidget {
  final UserModel? user;
  const SettingsScreen({super.key, required this.user});
  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _checkingAdmin = false;

  Future<void> _checkAdmin() async {
    setState(() => _checkingAdmin = true);
    final uid = widget.user?.uid;
    if (uid == null) {
      setState(() => _checkingAdmin = false);
      return;
    }
    final isAdmin = await LocalStorageService().isAdmin(uid);
    setState(() => _checkingAdmin = false);
    if (!mounted) return;
    if (isAdmin) {
      Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminScreen()));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Access denied. Admins only.'),
          backgroundColor: AppTheme.red));
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = QuizTechApp.of(context)?.isDark ?? false;

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Container(
            padding: EdgeInsets.fromLTRB(16, MediaQuery.of(context).padding.top + 16, 16, 16),
            child: Text('Settings',
                style: GoogleFonts.outfit(fontWeight: FontWeight.w900, fontSize: 28)),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _section('Appearance'),
                _tile(
                  icon: isDark ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
                  color: Colors.indigo,
                  title: 'Dark Mode',
                  trailing: Switch(
                    value: isDark,
                    activeColor: AppTheme.primary,
                    onChanged: (_) => QuizTechApp.of(context)?.toggleTheme(),
                  ),
                ),

                const SizedBox(height: 16),
                _section('Account'),
                _tile(
                  icon: Icons.person_rounded,
                  color: Colors.blue,
                  title: 'Profile',
                  subtitle: widget.user?.email ?? '',
                  onTap: () {},
                ),
                _tile(
                  icon: Icons.notifications_rounded,
                  color: Colors.orange,
                  title: 'Notifications',
                  onTap: () {},
                ),
                _tile(
                  icon: Icons.lock_rounded,
                  color: Colors.green,
                  title: 'Privacy & Security',
                  onTap: () {},
                ),

                const SizedBox(height: 16),
                _section('App Info'),
                _tile(
                  icon: Icons.info_rounded,
                  color: Colors.teal,
                  title: 'About QuizTech',
                  subtitle: 'Version 1.0.0',
                  onTap: () => _showAbout(),
                ),
                _tile(
                  icon: Icons.description_rounded,
                  color: Colors.purple,
                  title: 'Terms & Conditions',
                  onTap: () {},
                ),
                _tile(
                  icon: Icons.privacy_tip_rounded,
                  color: Colors.pink,
                  title: 'Privacy Policy',
                  onTap: () {},
                ),
                _tile(
                  icon: Icons.star_rounded,
                  color: Colors.amber,
                  title: 'Rate the App',
                  onTap: () {},
                ),

                const SizedBox(height: 16),
                _section('Admin'),
                _tile(
                  icon: Icons.admin_panel_settings_rounded,
                  color: AppTheme.red,
                  title: 'Admin Panel',
                  subtitle: 'Manage withdrawals & users',
                  trailing: _checkingAdmin
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2))
                      : null,
                  onTap: _checkingAdmin ? null : _checkAdmin,
                ),

                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () async {
                      await AuthService().signOut();
                      if (!mounted) return;
                      Navigator.of(context).pushAndRemoveUntil(
                          MaterialPageRoute(builder: (_) => const LoginScreen()),
                          (_) => false);
                    },
                    icon: const Icon(Icons.logout_rounded, color: AppTheme.red),
                    label: Text('Sign Out',
                        style: GoogleFonts.outfit(
                            color: AppTheme.red,
                            fontWeight: FontWeight.w800,
                            fontSize: 15)),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      side: const BorderSide(color: AppTheme.red),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _section(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(title,
          style: GoogleFonts.outfit(
              fontWeight: FontWeight.w800,
              fontSize: 13,
              color: Colors.grey.shade500,
              letterSpacing: 0.5)),
    );
  }

  Widget _tile({
    required IconData icon,
    required Color color,
    required String title,
    String? subtitle,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: ListTile(
        leading: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
              shape: BoxShape.circle, color: color.withOpacity(0.12)),
          child: Icon(icon, color: color, size: 18),
        ),
        title: Text(title,
            style: GoogleFonts.dmSans(fontWeight: FontWeight.w600, fontSize: 14)),
        subtitle: subtitle != null
            ? Text(subtitle,
                style: GoogleFonts.dmSans(
                    fontSize: 11, color: Colors.grey.shade500))
            : null,
        trailing: trailing ??
            (onTap != null
                ? const Icon(Icons.chevron_right, color: Colors.grey, size: 18)
                : null),
        onTap: onTap,
      ),
    );
  }

  void _showAbout() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('🎯 QuizTech',
            style: GoogleFonts.outfit(fontWeight: FontWeight.w900)),
        content: Text(
          'Play quizzes, earn credits, win real cash!\n\n'
          'Version: 1.0.0\n'
          'Questions: 3200+\n'
          'Categories: 12\n\n'
          'Built with Flutter & Firebase.',
          style: GoogleFonts.dmSans(height: 1.6),
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close', style: GoogleFonts.outfit()),
          ),
        ],
      ),
    );
  }
}
