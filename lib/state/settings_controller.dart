import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Persists the keyboardist's comfortable reference key (defaults to F♯,
/// matching Saviour's own playing) so it's remembered between sessions.
class SettingsController extends ChangeNotifier {
  static const String _referenceKeyPrefsKey = 'reference_pitch_class';
  static const int defaultReferencePitchClass = 6; // F♯

  int referencePitchClass = defaultReferencePitchClass;
  bool _loaded = false;

  Future<void> load() async {
    if (_loaded) return;
    final prefs = await SharedPreferences.getInstance();
    referencePitchClass = prefs.getInt(_referenceKeyPrefsKey) ?? defaultReferencePitchClass;
    _loaded = true;
    notifyListeners();
  }

  Future<void> setReferencePitchClass(int pitchClass) async {
    referencePitchClass = pitchClass;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_referenceKeyPrefsKey, pitchClass);
  }
}
