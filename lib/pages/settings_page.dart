import 'package:flutter/material.dart';
import '../backend_service.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key, required this.service, required this.onThemeChanged, required this.darkMode, required this.temperature});

  final BackendService service;
  final void Function(bool) onThemeChanged;
  final bool darkMode;
  final double temperature;

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  late bool _dark;
  late double _temp;

  @override
  void initState() {
    super.initState();
    _dark = widget.darkMode;
    _temp = widget.temperature;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SwitchListTile(
              title: const Text('Dark Mode'),
              value: _dark,
              onChanged: (v) {
                setState(() => _dark = v);
                widget.onThemeChanged(v);
              },
            ),
            const SizedBox(height: 16),
            Text('LLM Temperature: ${_temp.toStringAsFixed(1)}'),
            Slider(
              value: _temp,
              min: 0,
              max: 1,
              divisions: 10,
              label: _temp.toStringAsFixed(1),
              onChanged: (v) => setState(() => _temp = v),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => widget.service.purgeCache(),
              child: const Text('Purge Chat Cache'),
            ),
          ],
        ),
      ),
    );
  }
}
