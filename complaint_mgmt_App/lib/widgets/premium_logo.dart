import 'package:flutter/material.dart';
import '../utils/app_colors.dart';

class PremiumLogo extends StatelessWidget {
  final double size;
  const PremiumLogo({Key? key, this.size = 80}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primary, AppColors.accent],
        ),
        borderRadius: BorderRadius.circular(size * 0.3),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.4),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Icon(Icons.shield_rounded, size: size * 0.6, color: Colors.white.withOpacity(0.9)),
          Icon(Icons.check_rounded, size: size * 0.35, color: AppColors.accent),
          Positioned(
            right: size * 0.2,
            bottom: size * 0.2,
            child: Icon(Icons.settings, size: size * 0.2, color: Colors.white.withOpacity(0.5)),
          ),
        ],
      ),
    );
  }
}
