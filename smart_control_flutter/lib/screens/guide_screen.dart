import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class GuideScreen extends StatelessWidget {
  const GuideScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final cardBg = isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC);
    final textMain = isDark ? Colors.white : const Color(0xFF111827);
    final textMuted =
        isDark ? const Color(0xFF9CA3AF) : const Color(0xFF6B7280);
    final borderColor =
        isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0);
    final itemBg = isDark ? const Color(0xFF161F30) : Colors.white;

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
                  // Clean Modern Header (No split background shade)
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.menu_book_rounded,
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
                              'Instructions',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w800,
                                letterSpacing: -0.5,
                                color: textMain,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Learn how to set up and control your smart devices.',
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

                  // Introduction banner
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: AppColors.primary.withValues(alpha: 0.25),
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.lightbulb_outline,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Quick Setup Guide',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w800,
                                  color: textMain,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Follow the 4 simple steps below to integrate your hardware controller.',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: textMuted,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Step 1: Wi-Fi Setup
                  _buildStepCard(
                    stepNumber: '1',
                    title: 'Connect Controller to Wi-Fi',
                    subtitle: 'Power on your ESP32 microcontroller relay board.',
                    icon: Icons.wifi,
                    color: const Color(0xFF3B82F6),
                    content:
                        '• Ensure your ESP32 board is powered via a 5V/2A DC adapter or USB.\n'
                        '• On first boot, connect to the "SmartControl_AP" access point from your phone.\n'
                        '• Open your browser to 192.168.4.1 and enter your 2.4GHz home Wi-Fi credentials.\n'
                        '• The onboard LED will pulse blue while linking to the network.',
                    itemBg: itemBg,
                    borderColor: borderColor,
                    textMain: textMain,
                    textMuted: textMuted,
                  ),
                  const SizedBox(height: 16),

                  // Step 2: Device Key Binding
                  _buildStepCard(
                    stepNumber: '2',
                    title: 'Copy Device Key (UUID)',
                    subtitle:
                        'Bind your ESP32 firmware to this SmartHome account.',
                    icon: Icons.vpn_key_rounded,
                    color: AppColors.primary,
                    content:
                        '• Navigate to the "Profile" tab in this app.\n'
                        '• Locate the "DEVICE INSTANCE KEY" card and tap the copy button.\n'
                        '• Paste this key into your Arduino firmware file (secrets.h -> #define USER_UID "YOUR_KEY").\n'
                        '• Upload the code to your ESP32 board.',
                    itemBg: itemBg,
                    borderColor: borderColor,
                    textMain: textMain,
                    textMuted: textMuted,
                  ),
                  const SizedBox(height: 16),

                  // Step 3: Appliance Controls
                  _buildStepCard(
                    stepNumber: '3',
                    title: 'Control & Customize Devices',
                    subtitle:
                        'Toggle appliances and configure custom names.',
                    icon: Icons.touch_app,
                    color: const Color(0xFF10B981),
                    content:
                        '• On the "Devices" tab, tap any device card or switch to toggle instantly.\n'
                        '• Tap "Setup Devices" to scale between 1 and 8 connected devices.\n'
                        '• Tap appliance icons to switch between Light, Fan, AC, or Plug icons.',
                    itemBg: itemBg,
                    borderColor: borderColor,
                    textMain: textMain,
                    textMuted: textMuted,
                  ),
                  const SizedBox(height: 16),

                  // Step 4: Status Indicator
                  _buildStepCard(
                    stepNumber: '4',
                    title: 'Hardware Heartbeat & Status',
                    subtitle:
                        'Check live connection status of your ESP32.',
                    icon: Icons.wifi_tethering,
                    color: const Color(0xFF8B5CF6),
                    content:
                        '• A green glowing "SYSTEM ONLINE" badge indicates live connectivity.\n'
                        '• If status displays "OFFLINE", verify your ESP32 has power and is connected to 2.4GHz Wi-Fi.\n'
                        '• Tap the sync icon in the top right of the Devices tab to ping the controller.',
                    itemBg: itemBg,
                    borderColor: borderColor,
                    textMain: textMain,
                    textMuted: textMuted,
                  ),
                  const SizedBox(height: 24),

                  // Troubleshooting Box
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: itemBg,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: borderColor),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.help_outline,
                              color: AppColors.primary,
                              size: 18,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Frequently Asked Questions',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w800,
                                color: textMain,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        _buildFaqItem(
                          question: 'Why does the app show "Device Offline"?',
                          answer:
                              'Check if your ESP32 is powered and connected to the same Wi-Fi router. Verify your UUID in firmware matches the key in Profile.',
                          textMain: textMain,
                          textMuted: textMuted,
                        ),
                        const Divider(height: 20),
                        _buildFaqItem(
                          question: 'Can I control devices outside home?',
                          answer:
                              'Yes. As long as your ESP32 has internet access and your phone is online via mobile data or Wi-Fi, control is real-time via cloud sync.',
                          textMain: textMain,
                          textMuted: textMuted,
                        ),
                        const Divider(height: 20),
                        _buildFaqItem(
                          question: 'How do I add more appliances?',
                          answer:
                              'Tap "Setup Devices" on the Devices tab. Increase the device count up to 8, select your desired icons, and tap Save.',
                          textMain: textMain,
                          textMuted: textMuted,
                        ),
                      ],
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

  Widget _buildStepCard({
    required String stepNumber,
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required String content,
    required Color itemBg,
    required Color borderColor,
    required Color textMain,
    required Color textMuted,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: itemBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Icon(icon, color: color, size: 20),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: color.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            'STEP $stepNumber',
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w900,
                              color: color,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                              color: textMain,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 11,
                        color: textMuted,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            content,
            style: TextStyle(
              fontSize: 12,
              height: 1.55,
              color: textMuted,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFaqItem({
    required String question,
    required String answer,
    required Color textMain,
    required Color textMuted,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          question,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: textMain,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          answer,
          style: TextStyle(
            fontSize: 12,
            height: 1.4,
            color: textMuted,
          ),
        ),
      ],
    );
  }
}
