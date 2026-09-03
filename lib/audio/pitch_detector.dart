import 'dart:math' as math;

/// Autocorrelation-based fundamental frequency estimator, restricted to
/// the human vocal range (~80–1000Hz) to keep the search cheap and to
/// avoid latching onto noise outside singing range.
///
/// Pure Dart, no Flutter dependency — safe to unit test directly, and
/// safe to run on a background isolate if the analysis window is ever
/// made large enough to need one.
class PitchDetector {
  static const double _minFrequencyHz = 80.0;
  static const double _maxFrequencyHz = 1000.0;
  static const double _voicedThreshold = 0.82;
  static const double _rmsSilenceThreshold = 0.012;

  /// Returns the estimated fundamental frequency in Hz, or null if the
  /// buffer is silent or doesn't look confidently pitched.
  static double? detect(List<double> samples, int sampleRate) {
    final size = samples.length;
    if (size < 4) return null;

    double rms = 0;
    for (var i = 0; i < size; i++) {
      rms += samples[i] * samples[i];
    }
    rms = math.sqrt(rms / size);
    if (rms < _rmsSilenceThreshold) return null;

    final minLag = (sampleRate / _maxFrequencyHz).floor();
    final maxLag = math.min((sampleRate / _minFrequencyHz).floor(), size - 2);
    if (maxLag <= minLag) return null;

    final c0 = _correlateAt(samples, 0, size);
    if (c0 <= 0) return null;

    var bestLag = -1;
    var bestCorr = 0.0;
    for (var lag = minLag; lag <= maxLag; lag++) {
      final c = _correlateAt(samples, lag, size);
      if (c > bestCorr) {
        bestCorr = c;
        bestLag = lag;
      }
    }
    if (bestLag <= 0 || bestCorr / c0 < _voicedThreshold) return null;

    // Parabolic interpolation around the peak for sub-sample precision.
    final cPrev = _correlateAt(samples, bestLag - 1, size);
    final cNext = _correlateAt(samples, bestLag + 1, size);
    final denom = cPrev - 2 * bestCorr + cNext;
    final shift = denom != 0 ? 0.5 * (cPrev - cNext) / denom : 0.0;
    final refinedLag = bestLag + shift;
    if (refinedLag <= 0) return null;

    return sampleRate / refinedLag;
  }

  static double _correlateAt(List<double> samples, int lag, int size) {
    double sum = 0;
    final n = size - lag;
    for (var i = 0; i < n; i++) {
      sum += samples[i] * samples[i + lag];
    }
    return sum;
  }
}
