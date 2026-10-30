import 'package:flutter/material.dart';
import 'auth_background.dart';

class AuthSocialButton extends StatelessWidget {
  final String label;
  final Widget icon;
  final VoidCallback onPressed;

  const AuthSocialButton({
    super.key,
    required this.label,
    required this.icon,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textMain =
        isDark ? AuthColors.textMainDark : AuthColors.textMainLight;
    final btnBg =
        isDark ? const Color(0xFF161F30) : Colors.white;
    final borderColor =
        isDark ? AuthColors.inputBorderDark : AuthColors.inputBorderLight;

    return SizedBox(
      height: 48,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          backgroundColor: btnBg,
          foregroundColor: textMain,
          side: BorderSide(color: borderColor, width: 1.0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 16),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            icon,
            const SizedBox(width: 10),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: textMain,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

