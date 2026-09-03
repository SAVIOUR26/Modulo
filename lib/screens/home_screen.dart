import 'package:flutter/material.dart';

import '../music/chord_theory.dart';
import '../music/key_transpose.dart';
import '../music/note.dart';
import '../state/listener_controller.dart';
import '../state/settings_controller.dart';
import '../theme/app_colors.dart';
import '../widgets/brand_header.dart';
import '../widgets/chord_grid.dart';
import '../widgets/key_readout.dart';
import '../widgets/status_bar.dart';
import '../widgets/transpose_readout.dart';
import 'settings_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key, required this.settings, required this.listener});

  final SettingsController settings;
  final ListenerController listener;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Modulo'),
        actions: [
          IconButton(
            icon: const Icon(Icons.tune),
            tooltip: 'Reference key',
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => SettingsScreen(settings: settings)),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 440),
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
              child: ListenableBuilder(
                listenable: Listenable.merge([listener, settings]),
                builder: (context, _) {
                  final referencePc = settings.referencePitchClass;
                  final estimate = listener.currentEstimate;
                  final transpose = estimate == null
                      ? null
                      : KeyTranspose.semitonesFor(
                          referencePitchClass: referencePc,
                          detectedPitchClass: estimate.tonicPitchClass,
                        );
                  final chords = ChordTheory.diatonicChordsFor(referencePc);
                  final referenceName = Note.nameFor(referencePc);

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 4),
                      const BrandHeader(),
                      const SizedBox(height: 18),
                      Container(
                        decoration: BoxDecoration(
                          color: AppColors.panel,
                          border: Border.all(color: AppColors.panelEdge),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        padding: const EdgeInsets.fromLTRB(20, 22, 20, 18),
                        child: Column(
                          children: [
                            StatusBar(
                              isListening: listener.isListening,
                              onToggle: () =>
                                  listener.isListening ? listener.stop() : listener.start(),
                            ),
                            const SizedBox(height: 16),
                            KeyReadout(
                              keyName: estimate == null ? null : Note.nameFor(estimate.tonicPitchClass),
                              confidence: estimate?.confidence ?? 0,
                              isListening: listener.isListening,
                            ),
                            const Divider(height: 32),
                            TransposeReadout(transpose: transpose, referenceName: referenceName),
                            const SizedBox(height: 16),
                            Text(
                              'Your $referenceName reference — always the same, regardless of transpose',
                              textAlign: TextAlign.center,
                              style: const TextStyle(fontSize: 13.5, color: AppColors.inkDim),
                            ),
                            const SizedBox(height: 12),
                            ChordGrid(chords: chords),
                            if (listener.errorMessage != null) ...[
                              const SizedBox(height: 14),
                              Text(
                                listener.errorMessage!,
                                textAlign: TextAlign.center,
                                style: const TextStyle(fontSize: 12.5, color: AppColors.danger),
                              ),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),
                      const Text(
                        "Give it 3–6 seconds of melody before trusting the reading — a single note isn't a key.",
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 11.5, color: AppColors.inkDim),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
