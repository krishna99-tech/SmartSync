import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class AuthSvgIllustration extends StatelessWidget {
  final String assetName;
  final double width;
  final double height;
  final BoxFit fit;

  const AuthSvgIllustration({
    super.key,
    required this.assetName,
    this.width = 48,
    this.height = 48,
    this.fit = BoxFit.contain,
  });

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      assetName,
      width: width,
      height: height,
      fit: fit,
    );
  }
}

