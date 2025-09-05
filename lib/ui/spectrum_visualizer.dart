import 'dart:async';
import 'dart:math';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:record/record.dart';
import 'package:fftea/fftea.dart';

class AppState with ChangeNotifier {
  StreamSubscription<Uint8List>? _audioSubscription;
  final _audioRecorder = AudioRecorder();
  List<double> _latestFft = [];
  bool _isListening = false;
  static const double _dbMin = -90.0;
  static const int _numBands = 128;

  List<InputDevice> _audioDevices = [];
  InputDevice? _selectedAudioDevice;

  List<double> get latestFft => _latestFft;
  bool get isListening => _isListening;
  List<InputDevice> get audioDevices => _audioDevices;
  InputDevice? get selectedAudioDevice => _selectedAudioDevice;

  AppState() {
    // Initialize with a silent baseline
    _latestFft = List<double>.filled(_numBands, _dbMin);
    // Fetch audio devices on initialization
    refreshAudioDevices();
  }

  @override
  void dispose() {
    _audioSubscription?.cancel();
    _audioRecorder.dispose();
    super.dispose();
  }

  Future<void> refreshAudioDevices() async {
    final oldSelectedDeviceId = _selectedAudioDevice?.id;
    _audioDevices = await _audioRecorder.listInputDevices();

    // Try to re-select the previously selected device
    if (oldSelectedDeviceId != null) {
      try {
        _selectedAudioDevice = _audioDevices.firstWhere(
          (d) => d.id == oldSelectedDeviceId,
        );
      } catch (e) {
        // If the old device is no longer available, select the first one.
        _selectedAudioDevice = _audioDevices.isNotEmpty ? _audioDevices.first : null;
      }
    } else {
      // If no device was previously selected, select the first one.
      _selectedAudioDevice = _audioDevices.isNotEmpty ? _audioDevices.first : null;
    }

    notifyListeners();
  }

  Future<void> changeAudioDevice(InputDevice device) async {
    final wasListening = _isListening;
    if (wasListening) {
      await stopListening();
    }
    _selectedAudioDevice = device;
    notifyListeners();
    if (wasListening) {
      await startListening();
    }
  }

  Future<void> startListening() async {
    if (_isListening || _selectedAudioDevice == null) return;

    if (await Permission.microphone.request().isGranted) {
      try {
        final stream = await _audioRecorder.startStream(const RecordConfig(
          encoder: AudioEncoder.pcm16bits,
          sampleRate: 44100,
          numChannels: 1,
        ));

        _audioSubscription = stream.listen(
          (data) {
            _processAudio(data);
          },
          onError: (error) {
            if (kDebugMode) {
              print('Error: $error');
            }
            _isListening = false;
            notifyListeners();
          },
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

  Future<void> stopListening() async {
    await _audioRecorder.stop();
    _audioSubscription?.cancel();
    _audioSubscription = null;
    _isListening = false;
    // Reset to a silent baseline instead of an empty list
    _latestFft = List<double>.filled(_numBands, _dbMin);
    notifyListeners();
  }


  void _processAudio(Uint8List data) {
    if (data.isEmpty) return;

    final pcm = Int16List.sublistView(data);
    final samples = pcm.map((s) => s.toDouble()).toList();

    if (samples.isEmpty) return;

    final windowedSamples = _applyHannWindow(samples);

    final fft = FFT(windowedSamples.length);
    final fftResult = fft.realFft(windowedSamples);

    final magnitudes = fftResult.magnitudes();
    final half = magnitudes.length ~/ 2;
    final halfMagnitudes = magnitudes.sublist(0, half);

    final dbValues = halfMagnitudes.map((mag) {
      final safeMag = mag.clamp(1e-10, double.infinity);
      final db = 20 * _log10(safeMag);
      return db.clamp(_dbMin, 0.0);
    }).toList();

    _latestFft = _groupIntoBands(dbValues, _numBands);
    notifyListeners();
  }

  List<double> _groupIntoBands(List<double> data, int numBands) {
    if (data.isEmpty) return [];
    final List<double> bands = List<double>.filled(numBands, _dbMin);
    final int groupSize = data.length ~/ numBands;
    if (groupSize == 0) {
      return List<double>.filled(numBands, _dbMin);
    }

    for (int i = 0; i < numBands; i++) {
      final int start = i * groupSize;
      final int end = start + groupSize;

      double maxVal = _dbMin;
      for (int j = start; j < end; j++) {
        if (j < data.length && data[j] > maxVal) {
          maxVal = data[j];
        }
      }
      bands[i] = maxVal;
    }
    return bands;
  }

  List<double> _applyHannWindow(List<double> samples) {
    final int N = samples.length;
    if (N <= 1) return List<double>.from(samples);

    final List<double> out = List<double>.filled(N, 0.0);
    for (int n = 0; n < N; n++) {
      final double w = 0.5 * (1 - cos(2 * pi * n / (N - 1)));
      out[n] = samples[n] * w;
    }
    return out;
  }
}

double _log10(double x) => log(x) / ln10;
