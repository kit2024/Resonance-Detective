
import 'dart:async';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter_audio_capture/flutter_audio_capture.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:fftea/fftea.dart';

class AppState with ChangeNotifier {
  final FlutterAudioCapture _audioCapture = FlutterAudioCapture();
  List<double> _latestFft = [];
  bool _isListening = false;
  static const double _dbMin = -120.0;

  List<double> get latestFft => _latestFft;
  bool get isListening => _isListening;

  Future<void> startListening() async {
    if (await Permission.microphone.request().isGranted) {
      try {
        await _audioCapture.start(
          (dynamic data) {
            _processAudio(data as List<dynamic>);
          },
          (Object error) {
            if (kDebugMode) {
              print('Error: $error');
            }
            _isListening = false;
            notifyListeners();
          },
          sampleRate: 44100,
          bufferSize: 8192,
        );
        _isListening = true;
        notifyListeners();
      } catch (e) {
        if (kDebugMode) {
          print('Error starting audio capture: $e');
        }
      }
    } else {
      if (kDebugMode) {
        print('Microphone permission denied');
      }
    }
  }

  void stopListening() async {
    try {
      await _audioCapture.stop();
      _isListening = false;
      _latestFft = [];
      notifyListeners();
    } catch (e) {
      if (kDebugMode) {
        print('Error stopping audio capture: $e');
      }
    }
  }

  void _processAudio(List<dynamic> data) {
  // Convert samples safely (handles int or double input)
  final samples = data.map((e) => (e as num).toDouble()).toList();
  if (samples.isEmpty) return;

  // Apply Hann window (custom method below)
  final windowedSamples = _applyHannWindow(samples);

  // Perform FFT
  final fft = FFT(windowedSamples.length);
  final fftResult = fft.realFft(windowedSamples);

  // Get magnitudes and keep only positive frequencies
  final magnitudes = fftResult.magnitudes();
  final half = magnitudes.length ~/ 2;
  final halfMagnitudes = magnitudes.sublist(0, half);

  // Convert to decibels
  final dbValues = halfMagnitudes.map((mag) {
    final safeMag = mag.clamp(1e-10, double.infinity).toDouble();
    final db = 20 * log10(safeMag);
    return db.clamp(_dbMin, 0.0);
  }).toList();

  _latestFft = dbValues;
  notifyListeners();
}
List<double> _applyHannWindow(List<double> samples) {
  final int N = samples.length;
  if (N <= 1) return List<double>.from(samples);

  final List<double> out = List<double>.filled(N, 0.0);
  for (int n = 0; n < N; n++) {
    // Hann window: w[n] = 0.5 * (1 - cos(2πn / (N-1)))
    final double w = 0.5 * (1 - cos(2 * pi * n / (N - 1)));
    out[n] = samples[n] * w;
  }
  return out;
}
}

/// A helper function to calculate the base-10 logarithm.
double log10(double x) => log(x) / ln10;
