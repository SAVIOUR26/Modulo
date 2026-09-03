import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

class StatusBar extends StatelessWidget {
  const StatusBar({super.key, required this.isListening, required this.onToggle});

  final bool isListening;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isListening ? AppColors.teal : AppColors.inkDim,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              isListening ? 'Listening' : 'Not listening',
              style: const TextStyle(fontSize: 12, color: AppColors.inkDim),
            ),
          ],
        ),
        ElevatedButton(
          onPressed: onToggle,
          style: isListening
              ? ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  foregroundColor: AppColors.danger,
                  side: const BorderSide(color: AppColors.danger),
                  elevation: 0,
                )
              : null,
          child: Text(isListening ? 'Stop' : 'Start listening'),
        ),
      ],
    );
  }
}
