// track_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_map_cancellable_tile_provider/flutter_map_cancellable_tile_provider.dart';
import 'dart:async';
import '../models/alarm.dart';

class TrackPage extends StatefulWidget {
  final List<Alarm> alarms;
  final Function(Alarm) updateAlarmStatus;

  const TrackPage(
      {Key? key, required this.alarms, required this.updateAlarmStatus})
      : super(key: key);

  @override
  _TrackPageState createState() => _TrackPageState();
}

class _TrackPageState extends State<TrackPage> {
  LatLng? _currentPosition;
  MapController _mapController = MapController();
  StreamSubscription<Position>? _positionStreamSubscription;

  @override
  void initState() {
    super.initState();
    _startLocationTracking();
  }

  @override
  void dispose() {
    _positionStreamSubscription?.cancel();
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
  }

  void _checkProximityToDestinations() {
    if (_currentPosition == null) return;

    for (var alarm in widget.alarms) {
      if (!alarm.isActive) continue;

      double distance = Geolocator.distanceBetween(
        _currentPosition!.latitude,
        _currentPosition!.longitude,
        alarm.latitude,
        alarm.longitude,
      );

      if (distance <= alarm.distance) {
        _showAlarmDialog(alarm);
        break; // You might want to handle multiple triggered alarms differently
      }
    }
  }

  void _showAlarmDialog(Alarm alarm) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Alarm'),
          content: Text('You have reached your destination: ${alarm.name}!'),
          actions: <Widget>[
            TextButton(
              child: Text('Stop'),
              onPressed: () {
                alarm.deactivate();
                widget.updateAlarmStatus(alarm);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
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
          ? Center(child: CircularProgressIndicator())
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
      floatingActionButton: FloatingActionButton(
        onPressed: _centerOnUserLocation,
        child: Icon(Icons.my_location, color: Colors.white,),
        backgroundColor: Color(0xFF008080),
      ),
    );
  }
}
