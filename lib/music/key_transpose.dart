/// Transpose math: given the keyboardist's comfortable reference key and
/// the key the room is actually singing in, work out how many semitones
/// to set the keyboard's transpose control to.
///
/// This is a direct port of the reference chart worked out for F♯
/// (C -> -6, C♯ -> -5, D -> -4 ... F♯ -> 0 ... B -> +5), generalised so
/// it works from any reference key, not just F♯.
class KeyTranspose {
  // Offsets in pitch-class order relative to the reference: index 0 is
  // "same pitch class as reference" (0 semitones), rotating from there.
  static const List<int> _offsetsFromReference = [
    -6, -5, -4, -3, -2, -1, 0, 1, 2, 3, 4, 5,
  ];

  /// Returns the transpose amount, in the range [-6, 5], to apply on the
  /// keyboard so that playing the usual [referencePitchClass]-major
  /// shapes sounds in [detectedPitchClass] major.
  static int semitonesFor({
    required int referencePitchClass,
    required int detectedPitchClass,
  }) {
    final index = ((detectedPitchClass - referencePitchClass + 6) % 12 + 12) % 12;
    return _offsetsFromReference[index];
  }
}
