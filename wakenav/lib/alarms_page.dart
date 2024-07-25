import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'models/alarm.dart';

class AlarmsPage extends StatefulWidget {
  @override
  _AlarmsPageState createState() => _AlarmsPageState();
}

class _AlarmsPageState extends State<AlarmsPage> {
  List<Alarm> _alarms = [];

  @override
  void initState() {
    super.initState();
    _loadAlarms();
  }

  Future<void> _loadAlarms() async {
    final prefs = await SharedPreferences.getInstance();
    final String? alarmsJson = prefs.getString('alarms');
    if (alarmsJson != null) {
      final List<dynamic> decodedAlarms = jsonDecode(alarmsJson);
      setState(() {
        _alarms = decodedAlarms.map((e) => Alarm.fromJson(e)).toList();
      });
    }
  }

  Future<void> _saveAlarms() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('alarms', jsonEncode(_alarms.map((e) => e.toJson()).toList()));
  }

  void _deleteAlarm(Alarm alarm) {
    setState(() {
      _alarms.removeWhere((a) => a.id == alarm.id);
    });
    _saveAlarms();
  }

  void _toggleAlarmActive(Alarm alarm) {
    setState(() {
      alarm.isActive = !alarm.isActive;
    });
    _saveAlarms();
  }

  void _editAlarm(Alarm alarm) {
    showDialog(
      context: context,
      builder: (context) => AlarmEditDialog(
        alarm: alarm,
        onSave: (updatedAlarm) {
          setState(() {
            final index = _alarms.indexWhere((a) => a.id == updatedAlarm.id);
            if (index != -1) {
              _alarms[index] = updatedAlarm;
            }
          });
          _saveAlarms();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Saved Alarms'),
        backgroundColor: Colors.blue,
      ),
      body: _alarms.isEmpty
          ? Center(child: Text('No alarms saved yet.'))
          : ListView.builder(
              itemCount: _alarms.length,
              itemBuilder: (context, index) {
                final alarm = _alarms[index];
                return Dismissible(
                  key: Key(alarm.id),
                  background: Container(
                    color: Colors.red,
                    alignment: Alignment.centerRight,
                    padding: EdgeInsets.only(right: 20),
                    child: Icon(Icons.delete, color: Colors.white),
                  ),
                  direction: DismissDirection.endToStart,
                  onDismissed: (direction) {
                    _deleteAlarm(alarm);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('${alarm.name} Deleted')),
                    );
                  },
                  child: Card(
                    elevation: 2,
                    margin: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    child: ListTile(
                      leading: Icon(
                        Icons.alarm,
                        color: alarm.isActive ? Colors.blue : Colors.grey,
                      ),
                      title: Text(
                        alarm.name,
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text('Distance: ${alarm.distance.toStringAsFixed(0)} m'),
                      trailing: Switch(
                        value: alarm.isActive,
                        onChanged: (value) => _toggleAlarmActive(alarm),
                      ),
                      onTap: () => _editAlarm(alarm),
                    ),
                  ),
                );
              },
            ),
    );
  }
}

class AlarmEditDialog extends StatefulWidget {
  final Alarm alarm;
  final Function(Alarm) onSave;

  AlarmEditDialog({required this.alarm, required this.onSave});

  @override
  _AlarmEditDialogState createState() => _AlarmEditDialogState();
}

class _AlarmEditDialogState extends State<AlarmEditDialog> {
  late TextEditingController _nameController;
  late TextEditingController _noteController;
  late double _distance;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.alarm.name);
    _noteController = TextEditingController(text: widget.alarm.note);
    _distance = widget.alarm.distance;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Edit Alarm'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _nameController,
              decoration: InputDecoration(labelText: 'Alarm Name'),
            ),
            SizedBox(height: 16),
            Text('Distance: ${_distance.toStringAsFixed(0)} m'),
            Slider(
              value: _distance,
              min: 50,
              max: 1000,
              divisions: 19,
              onChanged: (value) {
                setState(() {
                  _distance = value;
                });
              },
            ),
            TextField(
              controller: _noteController,
              decoration: InputDecoration(labelText: 'Note'),
              maxLines: 3,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          child: Text('Cancel'),
          onPressed: () => Navigator.of(context).pop(),
        ),
        ElevatedButton(
          child: Text('Save'),
          onPressed: () {
            final updatedAlarm = Alarm(
              id: widget.alarm.id,
              name: _nameController.text,
              distance: _distance,
              note: _noteController.text,
              latitude: widget.alarm.latitude,
              longitude: widget.alarm.longitude,
              isActive: widget.alarm.isActive,
            );
            widget.onSave(updatedAlarm);
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }
}