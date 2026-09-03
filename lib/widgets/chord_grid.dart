import 'package:flutter/material.dart';

import '../music/chord_theory.dart';
import '../theme/app_colors.dart';

class ChordGrid extends StatelessWidget {
  const ChordGrid({super.key, required this.chords});

  final List<DiatonicChord> chords;

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 4,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 6,
      crossAxisSpacing: 6,
      childAspectRatio: 1.5,
      children: chords.map((chord) {
        final isTonic = chord.degree == 'I';
        final isMinorOrDim = chord.quality != ChordQuality.major;
        return Container(
          decoration: BoxDecoration(
            color: isTonic ? AppColors.brassDim.withOpacity(0.25) : AppColors.chordCell,
            border: Border.all(color: isTonic ? AppColors.brassDim : AppColors.panelEdge),
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(5),
              bottomRight: Radius.circular(5),
            ),
          ),
          alignment: Alignment.center,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(chord.degree, style: const TextStyle(fontSize: 10.5, color: AppColors.inkDim)),
              const SizedBox(height: 3),
              Text(
                chord.name,
                style: TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: isTonic ? AppColors.brass : (isMinorOrDim ? AppColors.minor : AppColors.ink),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
