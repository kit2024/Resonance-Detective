
//import 'dart:ui';

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

        // The "gooey" effect is achieved by applying a blur and then a color
        // filter that sharpens the alpha channel, creating a metaball effect.
        return ColorFiltered(
          colorFilter: const ColorFilter.matrix(<double>[
            1, 0, 0, 0, 0,
            0, 1, 0, 0, 0,
            0, 0, 1, 0, 0,
            0, 0, 0, 30, -10, // Increase alpha contrast
          ]),
          child: TweenAnimationBuilder<List<double>>(
            tween: Tween<List<double>>(
              begin: appState.latestFft,
              end: appState.latestFft,
            ),
            duration: const Duration(milliseconds: 200),
            builder: (context, value, child) {
              return CustomPaint(
                painter: SpectrumPainter(
                  fftData: value,
                  color: Colors.lightGreenAccent,
                ),
                size: Size.infinite,
              );
            },
          ),
        );
      },
    );
  }
}

class SpectrumPainter extends CustomPainter {
  final List<double> fftData;
  final Color color;

  SpectrumPainter({required this.fftData, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10.0); // Blur for the gooey effect

    final double barWidth = size.width / fftData.length;
    final double halfBarWidth = barWidth / 2;

    for (int i = 0; i < fftData.length; i++) {
      final double dbValue = fftData[i];

      const double minDb = -90.0;
      const double maxDb = 0.0;
      final double normalized =
          ((dbValue.clamp(minDb, maxDb) - minDb) / (maxDb - minDb));
      final double barHeight = normalized * size.height;

      if (barHeight > 0) {
        // Draw circles instead of rects for a more "bubbly" look
        canvas.drawCircle(
          Offset(
            i * barWidth + halfBarWidth,
            size.height - barHeight,
          ),
          halfBarWidth * 2.5, // Make circles overlap
          paint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant SpectrumPainter oldDelegate) {
    // Let the TweenAnimationBuilder handle the repaint decision.
    return true;
  }
}
