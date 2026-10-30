import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../theme/app_theme.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final User? _user = FirebaseAuth.instance.currentUser;
  bool _showToken = false;

  void _copyToClipboard(String text, String label) {
    HapticFeedback.lightImpact();
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: AppColors.online, size: 18),
            const SizedBox(width: 8),
            Text('$label copied to clipboard!'),
          ],
        ),
        backgroundColor: const Color(0xFF1E1E2E),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Future<void> _confirmLogout() async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        final isDark = Theme.of(ctx).brightness == Brightness.dark;
        return AlertDialog(
          backgroundColor: isDark ? const Color(0xFF1B1B2C) : Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: Row(
            children: const [
              Icon(Icons.power_settings_new, color: AppColors.offline, size: 24),
              SizedBox(width: 10),
              Text(
                'Confirm Sign Out',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
            ],
          ),
          content: const Text(
            'Are you sure you want to end your current session? You can sign back in anytime with your email and password.',
            style: TextStyle(fontSize: 14),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: const Text('Cancel', style: TextStyle(fontWeight: FontWeight.w600)),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(ctx).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.offline,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Sign Out', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );

    if (shouldLogout == true) {
      HapticFeedback.heavyImpact();
      await FirebaseAuth.instance.signOut();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final cardBg = isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC);
    final textMain = isDark ? Colors.white : const Color(0xFF111827);
    final textMuted = isDark ? const Color(0xFF9CA3AF) : const Color(0xFF6B7280);
    final borderColor = isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0);
    final itemBg = isDark ? const Color(0xFF161F30) : Colors.white;

    final email = _user?.email ?? 'User';
    final uid = _user?.uid ?? 'No UID Available';

    final rawName = email.contains('@') ? email.split('@').first : email;
    final userName = rawName
        .replaceAll('.', ' ')
        .replaceAll('_', ' ')
        .split(' ')
        .map((w) => w.isNotEmpty ? '${w[0].toUpperCase()}${w.substring(1)}' : '')
        .join(' ');

    final initials = userName.isNotEmpty
        ? (userName.trim().contains(' ')
            ? '${userName.split(' ')[0][0]}${userName.split(' ')[1][0]}'
            : userName.substring(0, userName.length > 2 ? 2 : 1).toUpperCase())
        : 'SH';

    return Scaffold(
      backgroundColor: cardBg,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(22, 20, 22, 32),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Clean Modern Profile Header (No split background shade)
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.person_rounded,
                          color: AppColors.primary,
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Profile',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w800,
                                letterSpacing: -0.5,
                                color: textMain,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Manage credentials and ESP32 device keys.',
                              style: TextStyle(
                                fontSize: 13,
                                color: textMuted,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // User Identity Card
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: itemBg,
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(color: borderColor),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 62,
                                  height: 62,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    gradient: const LinearGradient(
                                      colors: [
                                        AppColors.primary,
                                        AppColors.primaryLight,
                                      ],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: AppColors.primary
                                            .withValues(alpha: 0.35),
                                        blurRadius: 12,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: Center(
                                    child: Text(
                                      initials,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 20,
                                        fontWeight: FontWeight.w900,
                                        letterSpacing: 1,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        userName,
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w900,
                                          color: textMain,
                                        ),
                                      ),
                                      const SizedBox(height: 3),
                                      Row(
                                        children: [
                                          const Icon(Icons.mail_outline,
                                              size: 13,
                                              color: AppColors.primary),
                                          const SizedBox(width: 5),
                                          Expanded(
                                            child: Text(
                                              email,
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.w600,
                                                color: textMuted,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 6),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 8, vertical: 3),
                                        decoration: BoxDecoration(
                                          color: AppColors.online
                                              .withValues(alpha: 0.12),
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                        child: const Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(Icons.verified,
                                                size: 12,
                                                color: AppColors.online),
                                            SizedBox(width: 4),
                                            Text(
                                              'Active User',
                                              style: TextStyle(
                                                fontSize: 10,
                                                fontWeight: FontWeight.w800,
                                                color: AppColors.online,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 18),

                          // UUID Token Card
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: itemBg,
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(color: borderColor),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    const Icon(Icons.vpn_key_rounded,
                                        color: AppColors.primary, size: 18),
                                    const SizedBox(width: 8),
                                    Text(
                                      'DEVICE INSTANCE KEY (UUID)',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w900,
                                        letterSpacing: 1,
                                        color: textMain,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  'Use this key in your ESP32 code to link your hardware to this profile.',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: textMuted,
                                    height: 1.35,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 14, vertical: 10),
                                  decoration: BoxDecoration(
                                    color: isDark
                                        ? Colors.black.withValues(alpha: 0.35)
                                        : Colors.white,
                                    borderRadius: BorderRadius.circular(14),
                                    border: Border.all(color: borderColor),
                                  ),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: SelectableText(
                                          _showToken
                                              ? uid
                                              : '••••••••••••••••••••••••••••••••••••',
                                          style: TextStyle(
                                            fontFamily: 'monospace',
                                            fontSize: 13,
                                            fontWeight: FontWeight.w700,
                                            letterSpacing:
                                                _showToken ? 0.3 : 2,
                                            color: textMain,
                                          ),
                                        ),
                                      ),
                                      IconButton(
                                        icon: Icon(
                                          _showToken
                                              ? Icons.visibility_off_outlined
                                              : Icons.visibility_outlined,
                                          color: textMuted,
                                          size: 18,
                                        ),
                                        onPressed: () {
                                          HapticFeedback.selectionClick();
                                          setState(() {
                                            _showToken = !_showToken;
                                          });
                                        },
                                      ),
                                      IconButton(
                                        icon: const Icon(
                                          Icons.copy_rounded,
                                          color: AppColors.primary,
                                          size: 18,
                                        ),
                                        onPressed: () => _copyToClipboard(
                                            uid, 'Device Key'),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Database Path: users/$uid/devices',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontFamily: 'monospace',
                                    color: textMuted,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 18),

                          // Hardware & System Specs
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: itemBg,
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(color: borderColor),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'SYSTEM STATUS',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 1,
                                    color: textMuted,
                                  ),
                                ),
                                const SizedBox(height: 14),
                                _buildInfoTile(
                                  icon: Icons.memory,
                                  label: 'Hardware Controller',
                                  value: 'ESP32 / ESP8266 IoT Chipset',
                                  textMain: textMain,
                                  textMuted: textMuted,
                                ),
                                const Divider(height: 18),
                                _buildInfoTile(
                                  icon: Icons.cloud_done,
                                  label: 'Cloud Database',
                                  value: 'Firebase Realtime DB (Live)',
                                  textMain: textMain,
                                  textMuted: textMuted,
                                ),
                                const Divider(height: 18),
                                _buildInfoTile(
                                  icon: Icons.brightness_auto,
                                  label: 'Theme',
                                  value: isDark
                                      ? 'System (Dark Mode)'
                                      : 'System (Light Mode)',
                                  textMain: textMain,
                                  textMuted: textMuted,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),

                          // Logout Button
                          SizedBox(
                            height: 50,
                            child: ElevatedButton.icon(
                              onPressed: _confirmLogout,
                              icon: const Icon(Icons.power_settings_new,
                                  size: 18),
                              label: const Text(
                                'Sign Out',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.offline,
                                foregroundColor: Colors.white,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          }

  Widget _buildInfoTile({
    required IconData icon,
    required String label,
    required String value,
    required Color textMain,
    required Color textMuted,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(7),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: AppColors.primary, size: 16),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(fontSize: 11, color: textMuted),
              ),
              Text(
                value,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: textMain,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
