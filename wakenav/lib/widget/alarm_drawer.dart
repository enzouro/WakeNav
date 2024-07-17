// alarm_drawer.dart

import 'package:flutter/material.dart';

class AlarmDrawer extends StatefulWidget {
  final Function onCancel;
  final Function onSave;
  final Function onStart;

  const AlarmDrawer({
    Key? key,
    required this.onCancel,
    required this.onSave,
    required this.onStart,
  }) : super(key: key);

  @override
  _AlarmDrawerState createState() => _AlarmDrawerState();
}

class _AlarmDrawerState extends State<AlarmDrawer> {
  bool _isExpanded = false;
  bool _onEntry = true;
  bool _onExit = false;
  double _radius = 100.0;
  TextEditingController _alarmNameController = TextEditingController();
  TextEditingController _noteController = TextEditingController();
  DraggableScrollableController _draggableController = DraggableScrollableController();

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
      _isExpanded = size > 0.55; // Expanded when over 55% of the screen
    });
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      controller: _draggableController,
      initialChildSize: 0.5,
      minChildSize: 0.5,
      maxChildSize: 0.6,
      builder: (_, controller) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
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
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Set Alarm', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    Row(
                      children: [
                        IconButton(
                          icon: Icon(_isExpanded ? Icons.expand_more : Icons.expand_less),
                          onPressed: () {
                            if (_isExpanded) {
                              _draggableController.animateTo(0.5, duration: Duration(milliseconds: 300), curve: Curves.easeInOut);
                            } else {
                              _draggableController.animateTo(0.6, duration: Duration(milliseconds: 300), curve: Curves.easeInOut);
                            }
                          },
                        ),
                        IconButton(
                          icon: Icon(Icons.close),
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
                    TextField(
                      controller: _alarmNameController,
                      decoration: InputDecoration(
                        labelText: 'Alarm Name',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    SizedBox(height: 16),
                    Text('Trigger', style: TextStyle(fontSize: 16)),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            setState(() {
                              _onEntry = true;
                              _onExit = false;
                            });
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _onEntry ? Colors.blue : Colors.grey,
                          ),
                          child: Text('On Entry'),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            setState(() {
                              _onEntry = false;
                              _onExit = true;
                            });
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _onExit ? Colors.blue : Colors.grey,
                          ),
                          child: Text('On Exit'),
                        ),
                      ],
                    ),
                    SizedBox(height: 16),
                    Text('Radius: ${_radius.toStringAsFixed(0)} m', style: TextStyle(fontSize: 16)),
                    Slider(
                      value: _radius,
                      min: 50,
                      max: 1000,
                      divisions: 19,
                      onChanged: (value) {
                        setState(() {
                          _radius = value;
                        });
                      },
                    ),
                    SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton(
                          onPressed: () => widget.onSave(),
                          child: Text('Save'),
                        ),
                        ElevatedButton(
                          onPressed: () => widget.onStart(),
                          child: Text('Start'),
                        ),
                      ],
                    ),
                    if (_isExpanded) ...[
                      SizedBox(height: 16),
                      TextField(
                        controller: _noteController,
                        decoration: InputDecoration(
                          labelText: 'Note',
                          border: OutlineInputBorder(),
                        ),
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