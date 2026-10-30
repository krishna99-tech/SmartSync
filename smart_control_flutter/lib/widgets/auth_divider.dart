import 'package:flutter/material.dart';
import 'auth_background.dart';

class AuthDivider extends StatelessWidget {
  final String text;

  const AuthDivider({
    super.key,
    this.text = 'or continue with',
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final borderColor =
        isDark ? AuthColors.cardBorderDark : AuthColors.cardBorderLight;
    final textMuted =
        isDark ? AuthColors.textMutedDark : AuthColors.textMutedLight;

    return Row(
      children: [
        Expanded(
          child: Divider(
            color: borderColor,
            thickness: 1,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: Text(
            text,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: textMuted,
              letterSpacing: 0.2,
            ),
          ),
        ),
        Expanded(
          child: Divider(
            color: borderColor,
            thickness: 1,
          ),
        ),
      ],
    );
  }
}

