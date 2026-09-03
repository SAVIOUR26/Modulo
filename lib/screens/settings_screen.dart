import 'package:flutter/material.dart';

import '../music/note.dart';
import '../state/settings_controller.dart';
import '../theme/app_colors.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key, required this.settings});

  final SettingsController settings;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Reference key')),
      body: ListenableBuilder(
        listenable: settings,
        builder: (context, _) {
          return ListView.separated(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: Note.names.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final selected = settings.referencePitchClass == index;
              return ListTile(
                title: Text(
                  Note.names[index],
                  style: const TextStyle(fontFamily: 'monospace', fontSize: 16),
                ),
                subtitle: index == 0
                    ? const Text('Chord shapes and transpose values are worked out from this key')
                    : null,
                trailing: selected ? const Icon(Icons.check, color: AppColors.brass) : null,
                onTap: () => settings.setReferencePitchClass(index),
              );
            },
          );
        },
      ),
    );
  }
}
