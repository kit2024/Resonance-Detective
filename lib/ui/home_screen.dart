import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:record/record.dart';

import '../app_state.dart';
import 'spectrum_visualizer.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // No longer listening to AppState changes at the top level of the build method.

    return Scaffold(
      appBar: AppBar(
        // Use a Consumer to rebuild only the title when the selected device changes.
        title: Consumer<AppState>(
          builder: (context, appState, child) {
            return Text(
              appState.selectedAudioDevice?.label ?? 'No Device Selected',
              style: const TextStyle(fontSize: 16),
            );
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              // Get the appState without listening for changes for the dialog.
              final appState = Provider.of<AppState>(context, listen: false);
              _showSettingsDialog(context, appState);
            },
          ),
        ],
      ),
      body: Column(
        children: [
          const Expanded(
            child: SpectrumVisualizer(),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            // Use a Consumer for the button to rebuild it when listening state changes.
            child: Consumer<AppState>(
              builder: (context, appState, child) {
                return FloatingActionButton(
                  onPressed: () {
                    if (appState.isListening) {
                      appState.stopListening();
                    } else {
                      appState.startListening();
                    }
                  },
                  child: Icon(appState.isListening ? Icons.stop : Icons.mic),
                );
              },
            ),
          ),
        ],
      ),
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
              content: _buildDeviceSelector(appState, context), // Pass context
              actions: <Widget>[
                TextButton(
                  child: const Text('Refresh'),
                  onPressed: () {
                    // No need to pop, consumer will rebuild the dialog content
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

  Widget _buildDeviceSelector(AppState appState, BuildContext context) {
    if (appState.audioDevices.isEmpty) {
      return const Text(
        'No input devices found. Please grant microphone permissions and click Refresh.',
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
            groupValue: appState.selectedAudioDevice,
            onChanged: (InputDevice? value) {
              if (value != null) {
                // Get appState without listening to prevent closing the dialog
                Provider.of<AppState>(context, listen: false).changeAudioDevice(value);
              }
            },
          );
        },
      ),
    );
  }
}
