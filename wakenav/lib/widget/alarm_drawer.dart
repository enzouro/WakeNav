// alarm_drawer.dart

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wakenav/main.dart';
import 'dart:convert';
import '../models/alarm.dart';
import 'package:uuid/uuid.dart';

class AlarmDrawer extends StatefulWidget {
  final Function onCancel;
  final Function(Alarm) onSave;
  final Function(Alarm) onStart; // Change this to accept an Alarm
  final double latitude;
  final double longitude;

  const AlarmDrawer({
    Key? key,
    required this.onCancel,
    required this.onSave,
    required this.onStart,
    required this.latitude,
    required this.longitude,
  }) : super(key: key);

  @override
  _AlarmDrawerState createState() => _AlarmDrawerState();
}

class _AlarmDrawerState extends State<AlarmDrawer> {
  bool _isExpanded = false;
  double _distance = 100.0;
  TextEditingController _alarmNameController = TextEditingController();
  TextEditingController _noteController = TextEditingController();
  DraggableScrollableController _draggableController =
      DraggableScrollableController();

  final double _collapsedSize = 0.32;
  final double _expandedSize = 0.45;

  @override
  void initState() {
    super.initState();
    _draggableController.addListener(_onDraggableChange);
  }

  @override
  void dispose() {
    _draggableController.removeListener(_onDraggableChange);
    _draggableController.dispose();
    super.dispose();
  }

  void _onDraggableChange() {
    final size = _draggableController.size;
    setState(() {
      _isExpanded = size > (_collapsedSize + _expandedSize) / 2;
    });
  }

  void _toggleExpansion() {
    final targetSize = _isExpanded ? _collapsedSize : _expandedSize;
    _draggableController.animateTo(
      targetSize,
      duration: Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
    setState(() {
      _isExpanded = !_isExpanded;
    });
  }

  Future<void> _saveAlarm({bool setActive = false}) async {
    final prefs = await SharedPreferences.getInstance();
    final alarm = Alarm(
      id: Uuid().v4(),
      name: _alarmNameController.text,
      distance: _distance,
      note: _noteController.text,
      latitude: widget.latitude,
      longitude: widget.longitude,
      isActive: setActive,
    );

    // Get existing alarms
    final String? alarmsJson = prefs.getString('alarms');
    List<Alarm> alarms = [];
    if (alarmsJson != null) {
      final List<dynamic> decodedAlarms = jsonDecode(alarmsJson);
      alarms = decodedAlarms.map((e) => Alarm.fromJson(e)).toList();
    }

    // Add new alarm
    alarms.add(alarm);

    // Save updated alarms list
    await prefs.setString(
        'alarms', jsonEncode(alarms.map((e) => e.toJson()).toList()));

    // Close the drawer
    widget.onCancel();

    if (setActive) {
      mainScreenKey.currentState?.updateStateWithAlarm(alarm);
      Navigator.of(context).popUntil((route) => route.isFirst);
    } else {
      widget.onSave(alarm);
    }
    widget.onCancel();
  }

  _startAlarm() {
    _saveAlarm(setActive: true);
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      controller: _draggableController,
      initialChildSize: _collapsedSize,
      minChildSize: _collapsedSize,
      maxChildSize: _expandedSize,
      builder: (_, controller) {
        return Container(
          decoration: BoxDecoration(
            color: Color(0xFF008080),
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.5),
                spreadRadius: 5,
                blurRadius: 7,
                offset: Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(15.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Set Alarm',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w500)),
                    Row(
                      children: [
                        IconButton(
                          icon: Icon(
                              _isExpanded
                                  ? Icons.expand_more
                                  : Icons.expand_less,
                              color: Colors.white),
                          onPressed:
                              _toggleExpansion, // Use the new _toggleExpansion method
                        ),
                        IconButton(
                          icon: Icon(Icons.close, color: Colors.white),
                          onPressed: () => widget.onCancel(),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView(
                  controller: controller,
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  children: [
                    TextFormField(
                      controller: _alarmNameController,
                      decoration: InputDecoration(
                          contentPadding: EdgeInsets.all(20),
                          border: OutlineInputBorder(),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                            borderSide: BorderSide(
                              color: (Colors.grey[400])!,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                            borderSide: BorderSide(
                              color: (Colors.grey[200])!,
                              width: 2.0,
                            ),
                          ),
                          filled: true,
                          fillColor: Colors.grey[100],
                          // label: Text("Alarm Name"),
                          hintText: "Set Alarm Name"),
                    ),
                    SizedBox(height: 15),
                    Row(
                      children: [
                        Text('Distance: ',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.w500)),
                        Text('${_distance.toStringAsFixed(0)} m',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.normal)),
                      ],
                    ),
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
                    SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Container(
                          width: 180,
                          child: Row(
                            children: [
                              ElevatedButton(
                                onPressed: _saveAlarm,
                                style: ElevatedButton.styleFrom(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                child: Text('Save',
                                    style: TextStyle(color: Color(0xFF008080))),
                              ),
                              SizedBox(width: 15),
                              ElevatedButton(
                                onPressed: _startAlarm,
                                style: ElevatedButton.styleFrom(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                child: Text('Start',
                                    style: TextStyle(color: Color(0xFF008080))),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 15),
                    if (_isExpanded) ...[
                      SizedBox(height: 15),
                      TextFormField(
                        controller: _noteController,
                        decoration: InputDecoration(
                            contentPadding: EdgeInsets.all(20),
                            border: OutlineInputBorder(),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                              borderSide: BorderSide(
                                color: (Colors.grey[400])!,
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                              borderSide: BorderSide(
                                color: (Colors.grey[200])!,
                                width: 2.0,
                              ),
                            ),
                            filled: true,
                            fillColor: Colors.grey[100],
                            // label: Text("Alarm Name"),
                            hintText: "Details"),
                        maxLines: 3,
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
