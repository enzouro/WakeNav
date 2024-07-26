//settings.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:alarm/alarm.dart' as AlarmPlugin;
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
  bool vibrate = true;
  int snoozeLength = 5; // in minutes
  bool loopAudio = true;

  @override
  void initState() {
    super.initState();
    _loadSoundFiles();
    _loadSettings();
    _initializeAlarm();
  }

  Future<void> _initializeAlarm() async {
    await AlarmPlugin.Alarm.init();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      selectedSound = prefs.getString('selectedSound');
      volume = prefs.getDouble('volume') ?? 0.5;
      vibrate = prefs.getBool('vibrate') ?? true;
      snoozeLength = prefs.getInt('snoozeLength') ?? 5;
      loopAudio = prefs.getBool('loopAudio') ?? true;
    });
  }

  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('selectedSound', selectedSound!);
    await prefs.setDouble('volume', volume);
    await prefs.setBool('vibrate', vibrate);
    await prefs.setInt('snoozeLength', snoozeLength);
    await prefs.setBool('loopAudio', loopAudio);
  }

  Future<void> _loadSoundFiles() async {
    // This assumes you have alarm sounds in your assets folder
    final manifestContent = await DefaultAssetBundle.of(context).loadString('AssetManifest.json');
    final Map<String, dynamic> manifestMap = json.decode(manifestContent);
    final soundPaths = manifestMap.keys
        .where((String key) => key.contains('assets/sounds/'))
        .toList();
    setState(() {
      soundFiles = soundPaths;
      if (soundFiles.isNotEmpty && selectedSound == null) {
        selectedSound = soundFiles.first;
      }
    });
  }

Future<void> _playSelectedSound() async {
    if (selectedSound != null) {
      final alarmSettings = AlarmPlugin.AlarmSettings(
        id: 42,
        dateTime: DateTime.now().add(Duration(seconds: 1)),
        assetAudioPath: selectedSound!,
        loopAudio: loopAudio,
        vibrate: vibrate,
        volume: volume,
        notificationTitle: 'Test Alarm',
        notificationBody: 'This is a test',
      );
      await AlarmPlugin.Alarm.set(alarmSettings: alarmSettings);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            SizedBox(width: 33),
            Text('Settings', style: TextStyle(color: Colors.white)),
          ],
        ),
        backgroundColor: Color(0xFF008080),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
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
              _saveSettings();
            },
            items: soundFiles.map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value.split('/').last),
              );
            }).toList(),
          ),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: _playSelectedSound,
            child: Text('Test Alarm Sound'),
          ),
          Divider(height: 32),
          Text('Volume', style: TextStyle(fontSize: 18)),
          Slider(
            value: volume,
            onChanged: (double newValue) {
              setState(() {
                volume = newValue;
              });
              _saveSettings();
            },
            min: 0,
            max: 1,
            divisions: 100,
            label: '${(volume * 100).round()}%',
          ),
          Text('${(volume * 100).round()}%'),
          Divider(height: 32),
          SwitchListTile(
            title: Text('Vibrate'),
            value: vibrate,
            onChanged: (bool value) {
              setState(() {
                vibrate = value;
              });
              _saveSettings();
            },
          ),
          ListTile(
            title: Text('Snooze Length'),
            subtitle: Text('$snoozeLength minutes'),
            trailing: DropdownButton<int>(
              value: snoozeLength,
              items: [1, 5, 10, 15, 20].map((int value) {
                return DropdownMenuItem<int>(
                  value: value,
                  child: Text('$value min'),
                );
              }).toList(),
              onChanged: (int? newValue) {
                if (newValue != null) {
                  setState(() {
                    snoozeLength = newValue;
                  });
                  _saveSettings();
                }
              },
            ),
          ),
          SwitchListTile(
            title: Text('Loop Audio'),
            value: loopAudio,
            onChanged: (bool value) {
              setState(() {
                loopAudio = value;
              });
              _saveSettings();
            },
          ),
        ],
      ),
    );
  }
}