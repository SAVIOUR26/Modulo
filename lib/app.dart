import 'package:flutter/material.dart';

import 'screens/home_screen.dart';
import 'state/listener_controller.dart';
import 'state/settings_controller.dart';
import 'theme/app_theme.dart';

class ModuloApp extends StatefulWidget {
  const ModuloApp({super.key});

  @override
  State<ModuloApp> createState() => _ModuloAppState();
}

class _ModuloAppState extends State<ModuloApp> {
  final SettingsController settings = SettingsController();
  final ListenerController listener = ListenerController();

  @override
  void initState() {
    super.initState();
    settings.load();
  }

  @override
  void dispose() {
    listener.dispose();
    settings.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Modulo',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark,
      home: HomeScreen(settings: settings, listener: listener),
    );
  }
}
