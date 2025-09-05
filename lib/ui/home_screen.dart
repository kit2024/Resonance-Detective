import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../app_state.dart';
import 'spectrum_visualizer.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Spectrum Analyzer'),
      ),
      body: Consumer<AppState>(
        builder: (context, appState, child) {
          return buildAnalyzerView(appState, context);
        },
      ),
    );
  }

  Widget buildAnalyzerView(AppState appState, BuildContext context) {
    return Column(
      children: [
        const Expanded(
          child: SpectrumVisualizer(),
        ),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: FloatingActionButton(
            onPressed: () {
              if (appState.isListening) {
                appState.stopListening();
              } else {
                appState.startListening();
              }
            },
            child: Icon(appState.isListening ? Icons.stop : Icons.mic),
          ),
        ),
      ],
    );
  }
}
