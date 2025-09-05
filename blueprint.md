# Spectrum Analyzer App Blueprint

## Overview

This document outlines the architecture, features, and design of the Spectrum Analyzer application. The application listens to the microphone input and displays the real-time frequency spectrum of the audio.

## Implemented Style, Design, and Features

### Architecture
- **State Management:** The application uses the `provider` package for state management. The core application state is managed in the `AppState` class, which is a `ChangeNotifier`.
- **Audio Processing:** The `record` package is used to capture audio from the microphone. The captured audio data is then processed using the `fftea` package to perform a Fast Fourier Transform (FFT) and calculate the frequency spectrum.
- **UI:** The UI is built with Flutter and consists of a main screen that displays the spectrum visualizer and a button to start/stop the audio capture.

### Features
- **Real-time Spectrum Analysis:** The application captures audio from the microphone and displays the frequency spectrum in real-time.
- **Start/Stop Control:** A floating action button allows the user to start and stop the audio capture.
- **Microphone Selection:** The user can select the desired audio input device from a list of available microphones.
- **Device List Refresh:** A "Refresh" button in the settings dialog allows the user to re-scan for audio devices, which is crucial for handling web browser permissions.

### Design
- **Theme:** The application uses a dark theme.
- **Debug Banner Removal:** The debug banner in the top-right corner has been removed for a cleaner user interface.
- **Dynamic "Gooey" Visualizer:** The frequency spectrum is visualized with a dynamic, liquid-like effect. Bars animate smoothly and merge into each other, creating an engaging and modern aesthetic.

## Current Task: Implement Dynamic Visualizer

### Plan
1.  **Problem Identification:** The previous visualizer was a static bar graph that didn't provide an engaging user experience.
2.  **UI Enhancement (`lib/ui/spectrum_visualizer.dart`):**
    *   Replaced the static `CustomPaint` with a `TweenAnimationBuilder` to animate the spectrum data, creating smooth transitions.
    *   Implemented a "gooey" or "metaball" effect by applying a `MaskFilter.blur` to the `Paint` object and wrapping the visualizer in a `ColorFiltered` widget with a high-contrast matrix for the alpha channel.
    *   Modified the `SpectrumPainter` to draw overlapping circles instead of rectangles, enhancing the fluid, bubbly appearance.
3.  **Update Blueprint:** Updated this document to reflect the implementation of the new dynamic visualizer.
