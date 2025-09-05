
# Spectrum Analyzer App Blueprint

## Overview

This document outlines the architecture, features, and design of the Spectrum Analyzer application. The application listens to the microphone input and displays the real-time frequency spectrum of the audio.

## Implemented Style, Design, and Features

### Architecture
- **State Management:** The application uses the `provider` package for state management. The core application state is managed in the `AppState` class, which is a `ChangeNotifier`.
- **Audio Processing:** The `flutter_audio_capture` package is used to capture audio from the microphone. The captured audio data is then processed using the `scidart` package to perform a Fast Fourier Transform (FFT) and calculate the frequency spectrum.
- **UI:** The UI is built with Flutter and consists of a main screen that displays the spectrum visualizer and a button to start/stop the audio capture.

### Features
- **Real-time Spectrum Analysis:** The application captures audio from the microphone and displays the frequency spectrum in real-time.
- **Start/Stop Control:** A floating action button allows the user to start and stop the audio capture.

### Design
- **Theme:** The application uses a dark theme.
- **Spectrum Visualizer:** The frequency spectrum is visualized as a bar graph, where each bar represents a frequency bin and the height of the bar represents the magnitude of the frequency in decibels (dB).

## Current Task: Error Fix and Code Cleanup

### Plan
1. **Fix `fft` function call:** The `fft` function from the `scidart` package was being called with incorrect arguments. This was fixed by creating a `ComplexArray` from the real and imaginary parts of the audio signal and passing that to the `fft` function.
2. **Remove unused files:** The following empty and unused files were deleted:
    - `lib/audio_capture/audio_capture_service.dart`
    - `lib/dsp/feedback_detector.dart`
    - `lib/dsp/spectrum_analyzer.dart`
    - `lib/ui/spectrum_painter.dart`
3. **Code Review:** The rest of the codebase was reviewed to ensure correctness and consistency.
4. **Correct `_processAudio` method:** The `_processAudio` method in `lib/app_state.dart` was rewritten to correctly perform the FFT, handle padding for performance, and calculate the decibel values safely. This new version uses the proper `scidart` functions (`Signal.hann`, `Fft.nextPow2`, `fft`, `Array`, `.abs()`).
5. **Final `_processAudio` correction:** The `_processAudio` method in `lib/app_state.dart` was corrected to fix import and function call errors related to the `scidart` library. The `hann`, `nextpow2`, and `fft` functions are now called correctly.
