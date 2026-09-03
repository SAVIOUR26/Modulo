import 'note.dart';

enum ChordQuality { major, minor, diminished }

class DiatonicChord {
  final String degree; // Roman numeral, e.g. "I", "ii", "vii°"
  final String name; // e.g. "F♯", "G♯m"
  final ChordQuality quality;

  const DiatonicChord(this.degree, this.name, this.quality);
}

/// Builds the seven diatonic triads for a major key from a single root
/// pitch class.
///
/// Note: chords are named from pitch class alone (sharps only), not full
/// key-signature spelling — e.g. the vii° of F♯ major prints as "F°"
/// rather than the stricter enharmonic "E♯°". Same pitch either way, and
/// simpler to read at a glance on stage.
class ChordTheory {
  static const List<int> _majorScaleSteps = [0, 2, 4, 5, 7, 9, 11];
  static const List<String> _romanNumerals = [
    'I', 'ii', 'iii', 'IV', 'V', 'vi', 'vii°',
  ];
  static const List<ChordQuality> _qualities = [
    ChordQuality.major,
    ChordQuality.minor,
    ChordQuality.minor,
    ChordQuality.major,
    ChordQuality.major,
    ChordQuality.minor,
    ChordQuality.diminished,
  ];

  static List<DiatonicChord> diatonicChordsFor(int rootPitchClass) {
    return List.generate(7, (i) {
      final pc = (rootPitchClass + _majorScaleSteps[i]) % 12;
      final quality = _qualities[i];
      final suffix = switch (quality) {
        ChordQuality.minor => 'm',
        ChordQuality.diminished => '°',
        ChordQuality.major => '',
      };
      return DiatonicChord(_romanNumerals[i], '${Note.nameFor(pc)}$suffix', quality);
    });
  }
}
