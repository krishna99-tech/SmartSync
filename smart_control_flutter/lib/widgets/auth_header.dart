import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'auth_background.dart';

class AuthHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  final String? svgAsset;
  final IconData? fallbackIcon;

  const AuthHeader({
    super.key,
    required this.title,
    required this.subtitle,
    this.svgAsset,
    this.fallbackIcon,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textMain =
        isDark ? AuthColors.textMainDark : AuthColors.textMainLight;
    final textMuted =
        isDark ? AuthColors.textMutedDark : AuthColors.textMutedLight;
    final badgeBg = isDark
        ? const Color(0xFF1E293B)
        : const Color(0xFFEFF6FF);
    final badgeBorder = isDark
        ? const Color(0xFF334155)
        : const Color(0xFFDBEAFE);

    return Column(
      children: [
        if (svgAsset != null || fallbackIcon != null) ...[
          Container(
            width: 52,
            height: 52,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: badgeBg,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: badgeBorder, width: 1.0),
            ),
            child: svgAsset != null
                ? SvgPicture.asset(
                    svgAsset!,
                    width: 28,
                    height: 28,
                  )
                : Icon(
                    fallbackIcon,
                    size: 26,
                    color: AuthColors.primary,
                  ),
          ),
          const SizedBox(height: 18),
        ],
        Text(
          title,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.5,
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
    );
  }
}

