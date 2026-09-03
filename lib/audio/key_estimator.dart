import 'pitch_sample.dart';

class KeyEstimate {
  final int tonicPitchClass;
  final double confidence; // 0..1

  const KeyEstimate(this.tonicPitchClass, this.confidence);
}

/// Keeps a rolling window of recently detected pitch classes and scores
/// them against a rotated Krumhansl–Kessler major-key profile to guess
/// the song's tonal center — not just whatever single note is sounding
/// this instant.
class KeyEstimator {
  static const Duration windowDuration = Duration(seconds: 8);
  static const int minSamplesForEstimate = 6;

  static const List<double> _majorProfile = [
    6.35, 2.23, 3.48, 2.33, 4.38, 4.09, 2.52, 5.19, 2.39, 3.66, 2.29, 2.88,
  ];

  final List<PitchSample> _history = [];

  void addPitchClass(int pitchClass, DateTime timestamp) {
    _history.add(PitchSample(pitchClass, timestamp));
  }

  void reset() => _history.clear();

  KeyEstimate? estimate(DateTime now) {
    _history.removeWhere((s) => now.difference(s.timestamp) > windowDuration);

    final histogram = List<int>.filled(12, 0);
    for (final s in _history) {
      histogram[s.pitchClass]++;
    }
    final total = histogram.fold<int>(0, (a, b) => a + b);
    if (total < minSamplesForEstimate) return null;

    var bestTonic = 0;
    var bestScore = double.negativeInfinity;
    var secondScore = double.negativeInfinity;

    for (var tonic = 0; tonic < 12; tonic++) {
      var score = 0.0;
      for (var pc = 0; pc < 12; pc++) {
        final profileIndex = (pc - tonic + 12) % 12;
        score += histogram[pc] * _majorProfile[profileIndex];
      }
      if (score > bestScore) {
        secondScore = bestScore;
        bestScore = score;
        bestTonic = tonic;
      } else if (score > secondScore) {
        secondScore = score;
      }
    }

    final confidence = bestScore > 0
        ? ((bestScore - secondScore) / bestScore).clamp(0.0, 1.0)
        : 0.0;

    return KeyEstimate(bestTonic, confidence);
  }
}
