import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:record/record.dart';

import '../app_state.dart';
import 'spectrum_visualizer.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          appState.selectedAudioDevice?.label ?? 'No Device Selected',
          style: const TextStyle(fontSize: 16),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => _showSettingsDialog(context, appState),
          ),
        ],
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

  void _showSettingsDialog(BuildContext context, AppState appState) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // Use a Consumer here to ensure the dialog rebuilds when the device list changes
        return Consumer<AppState>(
          builder: (context, appState, child) {
            return AlertDialog(
              title: const Text('Select Input Device'),
              content: _buildDeviceSelector(appState),
              actions: <Widget>[
                TextButton(
                  child: const Text('Refresh'),
                  onPressed: () {
                    appState.refreshAudioDevices();
                  },
                ),
                TextButton(
                  child: const Text('Close'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildDeviceSelector(AppState appState) {
    if (appState.audioDevices.isEmpty) {
      return const Text(
        'No input devices found. Please grant microphone permissions in your browser and click Refresh.',
        style: TextStyle(fontSize: 14),
      );
    }

    return SizedBox(
      width: double.maxFinite,
      child: ListView.builder(
        shrinkWrap: true,
        itemCount: appState.audioDevices.length,
        itemBuilder: (context, index) {
          final device = appState.audioDevices[index];
          return RadioListTile<InputDevice>(
            title: Text(device.label),
            value: device,
            // ignore: deprecated_member_use
            groupValue: appState.selectedAudioDevice,
            // ignore: deprecated_member_use
            onChanged: (InputDevice? value) {
              if (value != null) {
                appState.changeAudioDevice(value);
                // Do not pop here, so the user can see the change
              }
            },
          );
        },
      ),
    );
  }
}
