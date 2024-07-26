// track_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_map_cancellable_tile_provider/flutter_map_cancellable_tile_provider.dart';
import 'dart:async';
import '../models/alarm.dart';
import 'package:just_audio/just_audio.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TrackPage extends StatefulWidget {
  final List<Alarm> alarms;
  final Function(Alarm) updateAlarmStatus;
  final Function(int) updateSelectedIndex;  

  const TrackPage({
    Key? key, 
    required this.alarms,
    required this.updateAlarmStatus,
    required this.updateSelectedIndex,}) : super(key: key);

  @override
  _TrackPageState createState() => _TrackPageState();
}

class _TrackPageState extends State<TrackPage> {
  LatLng? _currentPosition;
  MapController _mapController = MapController();
  StreamSubscription<Position>? _positionStreamSubscription;
  final AudioPlayer _audioPlayer = AudioPlayer();
  Set<String> _triggeredAlarms = Set<String>();


  @override
  void initState() {
    super.initState();
    _startLocationTracking();
  }


  @override
  void dispose() {
    _positionStreamSubscription?.cancel();
    _audioPlayer.dispose();
    _triggeredAlarms.clear();
    super.dispose();
  }

void _startLocationTracking() {
  _positionStreamSubscription = Geolocator.getPositionStream(
    locationSettings: LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 10,
    ),
  ).listen((Position position) {
    setState(() {
      _currentPosition = LatLng(position.latitude, position.longitude);
    });
    _checkProximityToDestinations();
  });

  // Add a timer to check proximity regularly, in case the location doesn't update often
  Timer.periodic(Duration(seconds: 10), (_) {
    _checkProximityToDestinations();
  });
}

void _checkProximityToDestinations() {
  if (_currentPosition == null) return;

  for (var alarm in widget.alarms) {
    if (!alarm.isActive || _triggeredAlarms.contains(alarm.id)) continue;

    double distance = Geolocator.distanceBetween(
      _currentPosition!.latitude,
      _currentPosition!.longitude,
      alarm.latitude,
      alarm.longitude,
    );

    if (distance <= alarm.distance) {
      _triggeredAlarms.add(alarm.id);
      _showAlarmDialog(alarm);
      break; // Exit the loop after triggering the first alarm in range
    }
  }
}

void _showAlarmDialog(Alarm alarm) async {
  final prefs = await SharedPreferences.getInstance();
  final String? soundFile = prefs.getString('selectedSound');
  final double volume = prefs.getDouble('volume') ?? 0.5;
  final bool loopAudio = prefs.getBool('loopAudio') ?? true;

  // Show the dialog first
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('Destination Reached'),
        content: Text('You have reached your destination: ${alarm.name}!'),
        actions: <Widget>[
          TextButton(
            child: Text('Stop'),
            onPressed: () {
              _audioPlayer.stop();
              alarm.deactivate();
              _triggeredAlarms.remove(alarm.id);
              widget.updateAlarmStatus(alarm);
              Navigator.of(context).pop();
            },
          ),
          TextButton(
            child: Text('Snooze'),
            onPressed: () async {
              _audioPlayer.stop();
              final int snoozeLength = prefs.getInt('snoozeLength') ?? 5;
              Navigator.of(context).pop();
              Future.delayed(Duration(minutes: snoozeLength), () {
                if (alarm.isActive) {
                  _triggeredAlarms.remove(alarm.id);
                  _checkProximityToDestinations();
                }
              });
            },
          ),
        ],
      );
    },
  );

  // Play the audio after showing the dialog
  if (soundFile != null) {
    try {
      await _audioPlayer.setAsset(soundFile);
      _audioPlayer.setVolume(volume);
      _audioPlayer.setLoopMode(loopAudio ? LoopMode.all : LoopMode.off);
      await _audioPlayer.play();
    } catch (e) {
      print('Error playing audio: $e');
    }
  }
}
  @override
  void didUpdateWidget(TrackPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.alarms != oldWidget.alarms) {
      setState(() {
        // This will trigger a rebuild of the widget
      });
    }
  }

  void _centerOnUserLocation() {
    if (_currentPosition != null) {
      _mapController.move(_currentPosition!, 14.0);
    }
  }

  void activateAlarm(Alarm alarm) {
  alarm.isActive = true;
  _triggeredAlarms.remove(alarm.id);
  }

  @override
  Widget build(BuildContext context) {
    List<Alarm> activeAlarms =
        widget.alarms.where((alarm) => alarm.isActive).toList();
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF008080),
        title: Row(
          children: [
            SizedBox(width: 33), // This adds a space of 10 pixels
            Text('Tracking ${activeAlarms.length} Active Alarm${activeAlarms.length != 1 ? 's' : ''}', style: TextStyle(color: Colors.white))
          ],
        ),
      ),
      extendBodyBehindAppBar: true,
      body: _currentPosition == null
          ? Center(child: CircularProgressIndicator(
            color: Color.fromARGB(255, 0, 255, 255),
          ))
          : Stack(
              children: [
                FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    initialCenter: _currentPosition!,
                    initialZoom: 14.0,
                  ),
                  children: [
                    TileLayer(
                      urlTemplate:
                          'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.example.app',
                      tileProvider: CancellableNetworkTileProvider(),
                    ),
                    MarkerLayer(
                      markers: [
                        Marker(
                          width: 80.0,
                          height: 80.0,
                          point: _currentPosition!,
                          child: Icon(
                            Icons.my_location,
                            color: Color.fromARGB(255, 0, 172, 172),
                            size: 30.0,
                          ),
                        ),
                        ...widget.alarms
                            .where((alarm) => alarm.isActive)
                            .map((alarm) => Marker(
                                  width: 80.0,
                                  height: 80.0,
                                  point:
                                      LatLng(alarm.latitude, alarm.longitude),
                                  child: Icon(
                                    Icons.location_pin,
                                    color: Color.fromARGB(255, 243, 33, 33),
                                    size: 30.0,
                                  ),
                                ))
                            .toList(),
                      ],
                    ),
                    PolylineLayer(
                      polylines: widget.alarms
                          .where((alarm) => alarm.isActive)
                          .map((alarm) => Polyline(
                                points: [
                                  _currentPosition!,
                                  LatLng(alarm.latitude, alarm.longitude)
                                ],
                                strokeWidth: 4.0,
                                color: Color.fromARGB(255, 0, 172, 172),
                              ))
                          .toList(),
                    ),
                  ],
                ),
                Positioned(
                  top: 100,
                  left: 10,
                  right: 10,
                  child: Column(
                    children: widget.alarms
                        .where((alarm) => alarm.isActive)
                        .map((alarm) {
                      double distance = Geolocator.distanceBetween(
                        _currentPosition!.latitude,
                        _currentPosition!.longitude,
                        alarm.latitude,
                        alarm.longitude,
                      );
                      return Container(
                        margin: EdgeInsets.only(bottom: 10),
                        padding: EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.8),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                '${alarm.name}: ${distance.toStringAsFixed(2)} meters',
                                style: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                            ),
                            IconButton(
                              icon: Icon(Icons.cancel),
                              onPressed: () {
                                alarm.deactivate();
                                widget.updateAlarmStatus(alarm);
                              },
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            onPressed: () => widget.updateSelectedIndex(1),
            child: Icon(Icons.add_alarm, color: Colors.white),
            backgroundColor: Color(0xFF008080),
            heroTag: 'addAlarm',
          ),
          SizedBox(height: 16),  // Add some space between the buttons
          FloatingActionButton(
            onPressed: _centerOnUserLocation,
            child: Icon(Icons.my_location, color: Colors.white),
            backgroundColor: Color(0xFF008080),
            heroTag: 'myLocation',
          ),
        ],
      ),
    );
  }
}