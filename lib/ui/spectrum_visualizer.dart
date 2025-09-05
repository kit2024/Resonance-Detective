import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../app_state.dart';

class SpectrumVisualizer extends StatelessWidget {
  const SpectrumVisualizer({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, appState, child) {
        if (appState.latestFft.isEmpty) {
          return const Center(
            child: Text(
              'Start listening to see the spectrum',
              style: TextStyle(color: Colors.grey, fontSize: 18),
            ),
          );
        }

        return CustomPaint(
          painter: SpectrumPainter(appState.latestFft),
          size: Size.infinite,
        );
      },
    );
  }
}

class SpectrumPainter extends CustomPainter {
  final List<double> fftData;

  SpectrumPainter(this.fftData);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.lightGreenAccent;
    final double barWidth = size.width / fftData.length;

    for (int i = 0; i < fftData.length; i++) {
      // The data is in dB, ranging roughly from 0 down to -120 or lower
      final double dbValue = fftData[i];

      // Map the dB value to a height. We'll map a range, e.g., -90dB to 0dB.
      const double minDb = -90.0;
      const double maxDb = 0.0;
      final double normalized =
          ((dbValue.clamp(minDb, maxDb) - minDb) / (maxDb - minDb));
      final double barHeight = normalized * size.height;

      if (barHeight > 0) {
        canvas.drawRect(
          Rect.fromLTWH(
            i * barWidth,
            size.height - barHeight,
            barWidth - 1, // Subtract 1 for spacing between bars
            barHeight,
          ),
          paint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant SpectrumPainter oldDelegate) {
    return true; // For simplicity, always repaint. Could be optimized.
  }
}
