import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:record/record.dart';

import '../audio/key_estimator.dart';
import '../audio/pitch_detector.dart';
import '../music/note.dart';

/// Owns the microphone stream end-to-end: starts/stops recording,
/// converts incoming PCM16 bytes into a rolling analysis buffer, runs
/// pitch detection + key estimation on that buffer, and exposes the
/// result to the UI via ChangeNotifier.
class ListenerController extends ChangeNotifier {
  final AudioRecorder _recorder = AudioRecorder();
  StreamSubscription<Uint8List>? _subscription;

  static const int _sampleRate = 44100;
  // ~55ms of audio — long enough to contain at least two full periods of
  // the lowest vocal frequency we look for (80Hz), short enough to stay
  // responsive as the buffer slides forward with each new chunk.
  static const int _analysisWindowSamples = 2400;
  static const Duration _detectionInterval = Duration(milliseconds: 100);

  final List<double> _rollingBuffer = <double>[];
  final KeyEstimator _keyEstimator = KeyEstimator();
  DateTime _lastDetectionAt = DateTime.fromMillisecondsSinceEpoch(0);

  bool isListening = false;
  String? errorMessage;
  KeyEstimate? currentEstimate;

  Future<void> start() async {
    errorMessage = null;
    try {
      final hasPermission = await _recorder.hasPermission();
      if (!hasPermission) {
        errorMessage =
            'Microphone access was blocked. Allow it in your device settings and try again.';
        notifyListeners();
        return;
      }

      final stream = await _recorder.startStream(
        const RecordConfig(
          encoder: AudioEncoder.pcm16bits,
          sampleRate: _sampleRate,
          numChannels: 1,
        ),
      );

      _rollingBuffer.clear();
      _keyEstimator.reset();
      currentEstimate = null;
      isListening = true;
      notifyListeners();

      _subscription = stream.listen(
        _onAudioChunk,
        onError: (Object e) {
          errorMessage = 'Listening stopped unexpectedly: $e';
          stop();
        },
      );
    } catch (e) {
      errorMessage = 'Could not start listening: $e';
      isListening = false;
      notifyListeners();
    }
  }

  Future<void> stop() async {
    await _subscription?.cancel();
    _subscription = null;
    if (await _recorder.isRecording()) {
      await _recorder.stop();
    }
    isListening = false;
    currentEstimate = null;
    _rollingBuffer.clear();
    _keyEstimator.reset();
    notifyListeners();
  }

  void _onAudioChunk(Uint8List bytes) {
    // 16-bit little-endian PCM -> normalized doubles in [-1, 1].
    final byteData = ByteData.sublistView(bytes);
    for (var i = 0; i + 1 < bytes.length; i += 2) {
      final sample = byteData.getInt16(i, Endian.little) / 32768.0;
      _rollingBuffer.add(sample);
    }
    if (_rollingBuffer.length > _analysisWindowSamples) {
      _rollingBuffer.removeRange(0, _rollingBuffer.length - _analysisWindowSamples);
    }

    final now = DateTime.now();
    if (now.difference(_lastDetectionAt) < _detectionInterval) return;
    if (_rollingBuffer.length < _analysisWindowSamples) return;
    _lastDetectionAt = now;

    final freq = PitchDetector.detect(_rollingBuffer, _sampleRate);
    if (freq != null) {
      final midi = Note.frequencyToMidi(freq);
      final pitchClass = Note.pitchClassFromMidi(midi);
      _keyEstimator.addPitchClass(pitchClass, now);
    }

    currentEstimate = _keyEstimator.estimate(now);
    notifyListeners();
  }

  @override
  void dispose() {
    _subscription?.cancel();
    _recorder.dispose();
    super.dispose();
  }
}
