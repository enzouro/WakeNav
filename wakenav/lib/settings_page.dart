import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'dart:convert';

class SettingsPage extends StatefulWidget {
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  String? selectedSound;
  double volume = 0.50;
  List<String> soundFiles = [];

  @override
  void initState() {
    super.initState();
    _loadSoundFiles();
  }

  Future<void> _loadSoundFiles() async {
    final manifestContent = await rootBundle.loadString('AssetManifest.json');
    final Map<String, dynamic> manifestMap = json.decode(manifestContent);
    final soundPaths = manifestMap.keys
        .where((String key) => key.contains('assets/sounds/'))
        .toList();
    setState(() {
      soundFiles = soundPaths;
      if (soundFiles.isNotEmpty) {
        selectedSound = soundFiles.first;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            SizedBox(width: 33), // This adds a space of 33 pixels
            Text('Settings', style: TextStyle(color: Colors.white)),
          ],
        ),
        backgroundColor: Color(0xFF008080),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text('Ringtone', style: TextStyle(fontSize: 18)),
            SizedBox(height: 10),
            DropdownButtonFormField<String>(
              value: selectedSound,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              style: TextStyle(color: Colors.teal),
              onChanged: (String? newValue) {
                setState(() {
                  selectedSound = newValue;
                });
              },
              items: soundFiles.map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value.split('/').last),
                );
              }).toList(),
            ),
            SizedBox(height: 20), // Added space between dropdown and volume section
            Divider(height: 32),
            Text('Volume', style: TextStyle(fontSize: 18)),
            SizedBox(height: 10),
            Slider(
              value: volume,
              onChanged: (double newValue) {
                setState(() {
                  volume = newValue;
                });
              },
              min: 0,
              max: 1,
              divisions: 100,
              label: '${(volume * 100).round()}%',
            ),
            Text('${(volume * 100).round()}%'),
          ],
        ),
      ),
    );
  }
}
