//alarms_page.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'models/alarm.dart';

class AlarmsPage extends StatefulWidget {
  final Function(Alarm) onStartAlarm;
  final Function(Alarm) onStopAlarm;

  AlarmsPage({required this.onStartAlarm, required this.onStopAlarm});

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
    await prefs.setString(
        'alarms', jsonEncode(_alarms.map((e) => e.toJson()).toList()));
  }

  void _deleteAlarm(Alarm alarm) {
    setState(() {
      _alarms.removeWhere((a) => a.id == alarm.id);
    });
    _saveAlarms();
    widget.onStopAlarm(alarm);
  }

  void _confirmDeleteAlarm(BuildContext context, Alarm alarm) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Delete Alarm'),
          content: Text(
              'Are you sure you want to delete the alarm "${alarm.name}"?'),
          actions: [
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              child: Text('Delete'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
              ),
              onPressed: () {
                Navigator.of(context).pop();
                _deleteAlarm(alarm);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('${alarm.name} deleted')),
                );
              },
            ),
          ],
        );
      },
    );
  }

  void _toggleAlarmActive(Alarm alarm) {
    setState(() {
      alarm.toggleActive();
    });
    _saveAlarms();

    if (alarm.isActive) {
      widget.onStartAlarm(alarm);
    } else {
      widget.onStopAlarm(alarm);
    }
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
        title: Row(
          children: [
            SizedBox(width: 33), // This adds a space of 10 pixels
            Text('Saved Alarms', style: TextStyle(color: Colors.white)),
          ],
        ),
        backgroundColor: Color(0xFF008080),
      ),
      backgroundColor: Color.fromARGB(255, 0, 172, 172),
      body: _alarms.isEmpty
          ? Center(child: Text('No alarms saved yet.', style: TextStyle(color: Colors.white)))
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
                      color: Colors.white,
                      elevation: 5,
                      margin: EdgeInsets.only(left: 25, right: 25, top:30),
                      child: ListTile(
                        leading: Icon(
                          Icons.alarm,
                          color: alarm.isActive ? Color.fromARGB(255, 179, 37, 27) : Color(0xFF008080),
                        ),
                        title: Text(
                          alarm.name,
                          style: TextStyle(
                              color: Color.fromARGB(255, 61, 61, 61), fontWeight: FontWeight.w800),
                        ),
                        subtitle: Text(
                            'Distance: ${alarm.distance.toStringAsFixed(0)} m',
                            style: TextStyle(color: Color(0xFF008080))),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon:
                                  Icon(Icons.delete, color: Color(0xFF008080)),
                              onPressed: () =>
                                  _confirmDeleteAlarm(context, alarm),
                              
                            ),
                            ElevatedButton(
                              child: Text(
                                alarm.isActive ? 'Stop' : 'Start',
                                style: TextStyle(color: Colors.white),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: alarm.isActive
                                    ? Color.fromARGB(255, 179, 37, 27)
                                    : Color(0xFF008080),
                                shadowColor: Colors.white,
                                    
                                elevation:
                                    5, // Adjust elevation to match blur radius
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              onPressed: () => _toggleAlarmActive(alarm),
                            ),
                          ],
                        ),
                        onTap: () => _editAlarm(alarm),
                      )),
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
              max: 5000,
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
