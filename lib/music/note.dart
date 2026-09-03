import 'dart:math' as math;

/// Utilities for working with pitch classes (0 = C .. 11 = B), spelled
/// with sharps throughout to match how keyboardists in this context
/// read chord charts (F♯, not G♭).
class Note {
  static const List<String> names = [
    'C', 'C♯', 'D', 'D♯', 'E', 'F', 'F♯', 'G', 'G♯', 'A', 'A♯', 'B',
  ];

  /// Converts a frequency in Hz to a fractional MIDI note number
  /// (A4 = 440Hz = MIDI 69).
  static double frequencyToMidi(double frequencyHz) {
    return 69.0 + 12.0 * (math.log(frequencyHz / 440.0) / math.ln2);
  }

  /// Reduces a (possibly fractional) MIDI note number to a pitch class
  /// in the range [0, 11].
  static int pitchClassFromMidi(double midi) {
    final rounded = midi.round();
    return ((rounded % 12) + 12) % 12;
  }

  static String nameFor(int pitchClass) => names[((pitchClass % 12) + 12) % 12];
}
