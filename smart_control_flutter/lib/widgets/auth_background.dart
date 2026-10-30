import 'package:flutter/material.dart';

class AuthColors {
  // Shadcn / Next.js Clean Palette
  static const Color primary = Color(0xFF2563EB); // Vibrant Primary Blue
  static const Color primaryHover = Color(0xFF1D4ED8);
  static const Color primaryLight = Color(0xFFDBEAFE);
  static const Color primarySoft = Color(0xFFEFF6FF);
  static const Color primaryBorder = Color(0xFFBFDBFE);

  // Background & Surfaces
  static const Color bgLight = Color(0xFFF8FAFC);
  static const Color bgDark = Color(0xFF090D16);
  static const Color surfaceLight = Colors.white;
  static const Color surfaceDark = Color(0xFF111827);

  // Borders
  static const Color cardBorderLight = Color(0xFFE2E8F0);
  static const Color cardBorderDark = Color(0xFF1E293B);

  // Input Fields
  static const Color inputBgLight = Color(0xFFF8FAFC);
  static const Color inputBgDark = Color(0xFF0F172A);
  static const Color inputBorderLight = Color(0xFFE2E8F0);
  static const Color inputBorderDark = Color(0xFF1E293B);

  // Typography
  static const Color textMainLight = Color(0xFF0F172A);
  static const Color textMainDark = Color(0xFFF8FAFC);
  static const Color textMutedLight = Color(0xFF64748B);
  static const Color textMutedDark = Color(0xFF94A3B8);

  // Semantic
  static const Color success = Color(0xFF16A34A);
  static const Color error = Color(0xFFDC2626);
}

class AuthBackground extends StatelessWidget {
  final Widget child;
  final String title;
  final String subtitle;
  final String? badgeText;
  final VoidCallback? onBack;
  final double headerHeightFactor;
  final Widget? headerWidget;

  const AuthBackground({
    super.key,
    required this.child,
    required this.title,
    required this.subtitle,
    this.badgeText,
    this.onBack,
    this.headerHeightFactor = 0.30,
    this.headerWidget,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final size = MediaQuery.of(context).size;

    final bgColor = isDark ? AuthColors.bgDark : AuthColors.bgLight;
    final cardBg = isDark ? AuthColors.surfaceDark : AuthColors.surfaceLight;
    final cardBorder =
        isDark ? AuthColors.cardBorderDark : AuthColors.cardBorderLight;
    final textMain =
        isDark ? AuthColors.textMainDark : AuthColors.textMainLight;
    final textMuted =
        isDark ? AuthColors.textMutedDark : AuthColors.textMutedLight;

    return Scaffold(
      backgroundColor: bgColor,
      body: Stack(
        children: [
          // Subtle, minimal Next.js ambient gradient (zero photo, zero distraction)
          Positioned(
            top: -100,
            left: size.width * 0.2,
            child: Container(
              width: 320,
              height: 320,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AuthColors.primary.withValues(alpha: isDark ? 0.08 : 0.04),
              ),
            ),
          ),

          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(
                    horizontal: 20, vertical: 24),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 430),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Shadcn Elevated Card Container
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 30),
                        decoration: BoxDecoration(
                          color: cardBg,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: cardBorder,
                            width: 1.0,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(
                                  alpha: isDark ? 0.30 : 0.04),
                              blurRadius: 18,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            if (headerWidget != null)
                              headerWidget!
                            else ...[
                              Text(
                                title,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: -0.4,
                                  color: textMain,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                subtitle,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w400,
                                  color: textMuted,
                                  height: 1.45,
                                ),
                              ),
                            ],
                            const SizedBox(height: 24),
                            child,
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Footer copyright or tagline
                      Center(
                        child: Text(
                          'SmartControl Hub • Secure IoT Platform',
                          style: TextStyle(
                            fontSize: 12,
                            color: textMuted.withValues(alpha: 0.7),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class AuthTextField extends StatelessWidget {
  final String label;
  final String hintText;
  final TextEditingController controller;
  final bool isPassword;
  final bool showPassword;
  final VoidCallback? onTogglePassword;
  final TextInputType keyboardType;
  final IconData? prefixIcon;

  const AuthTextField({
    super.key,
    required this.label,
    required this.hintText,
    required this.controller,
    this.isPassword = false,
    this.showPassword = false,
    this.onTogglePassword,
    this.keyboardType = TextInputType.text,
    this.prefixIcon,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textMain =
        isDark ? AuthColors.textMainDark : AuthColors.textMainLight;
    final textMuted =
        isDark ? AuthColors.textMutedDark : AuthColors.textMutedLight;
    final inputBg = isDark ? AuthColors.inputBgDark : AuthColors.inputBgLight;
    final inputBorder =
        isDark ? AuthColors.inputBorderDark : AuthColors.inputBorderLight;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: textMain,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          height: 48,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: inputBg,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: inputBorder, width: 1.0),
          ),
          child: Row(
            children: [
              if (prefixIcon != null) ...[
                Icon(prefixIcon, size: 18, color: textMuted),
                const SizedBox(width: 10),
              ],
              Expanded(
                child: TextField(
                  controller: controller,
                  keyboardType: keyboardType,
                  obscureText: isPassword && !showPassword,
                  style: TextStyle(
                    color: textMain,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                  decoration: InputDecoration(
                    hintText: hintText,
                    hintStyle: TextStyle(
                      color: textMuted.withValues(alpha: 0.7),
                      fontSize: 13,
                    ),
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ),
              if (isPassword && onTogglePassword != null)
                IconButton(
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
                  icon: Icon(
                    showPassword
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                    color: textMuted,
                    size: 18,
                  ),
                  onPressed: onTogglePassword,
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class AuthPrimaryButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;

  const AuthPrimaryButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AuthColors.primary,
          foregroundColor: Colors.white,
          disabledBackgroundColor: AuthColors.primary.withValues(alpha: 0.6),
          disabledForegroundColor: Colors.white70,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16),
        ),
        child: isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Text(
                text,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.2,
                  color: Colors.white,
                ),
              ),
      ),
    );
  }
}
