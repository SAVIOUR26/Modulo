import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

class KeyReadout extends StatelessWidget {
  const KeyReadout({
    super.key,
    required this.keyName,
    required this.confidence,
    required this.isListening,
  });

  final String? keyName;
  final double confidence;
  final bool isListening;

  @override
  Widget build(BuildContext context) {
    final label = keyName ?? (isListening ? 'Listening…' : '—');
    return Column(
      children: [
        const Text('Detected key', style: TextStyle(fontSize: 11.5, color: AppColors.inkDim)),
        const SizedBox(height: 6),
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'monospace',
            fontSize: 36,
            fontWeight: FontWeight.w700,
            color: AppColors.ink,
          ),
        ),
        const SizedBox(height: 10),
        FractionallySizedBox(
          widthFactor: 0.7,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(2),
            child: LinearProgressIndicator(
              value: confidence.clamp(0.0, 1.0),
              minHeight: 3,
              backgroundColor: AppColors.panelEdge,
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.teal),
            ),
          ),
        ),
      ],
    );
  }
}
