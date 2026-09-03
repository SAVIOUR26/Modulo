import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

class TransposeReadout extends StatelessWidget {
  const TransposeReadout({super.key, required this.transpose, required this.referenceName});

  final int? transpose;
  final String referenceName;

  @override
  Widget build(BuildContext context) {
    final value = transpose;
    final display = value == null ? '0' : (value > 0 ? '+$value' : '$value');
    final String note;
    if (value == null) {
      note = 'Listening for a key…';
    } else if (value == 0) {
      note = 'Same key — no transpose needed';
    } else if (value.abs() == 6) {
      note = 'Or ${-value}, same pitch either way';
    } else {
      note = '${value > 0 ? 'Raise' : 'Lower'} keyboard transpose, keep playing $referenceName shapes';
    }

    return Column(
      children: [
        const Text('Set keyboard transpose to', style: TextStyle(fontSize: 11.5, color: AppColors.inkDim)),
        Text(
          display,
          style: const TextStyle(
            fontFamily: 'monospace',
            fontSize: 68,
            fontWeight: FontWeight.w700,
            color: AppColors.brass,
            height: 1,
          ),
        ),
        const SizedBox(height: 6),
        Text(note, textAlign: TextAlign.center, style: const TextStyle(fontSize: 13, color: AppColors.inkDim)),
      ],
    );
  }
}
