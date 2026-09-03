import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

class BrandHeader extends StatelessWidget {
  const BrandHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Text(
          'Modulo',
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: AppColors.ink),
        ),
        const SizedBox(height: 4),
        const Text(
          'Listens to the room, tells you the transpose',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 12.5, color: AppColors.inkDim),
        ),
        const SizedBox(height: 2),
        Text(
          'Designed by Saviour Najuna · Powered by Thirdsan',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 10.5, color: AppColors.inkDim.withValues(alpha: 0.8)),
        ),
      ],
    );
  }
}
