// track_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_map_cancellable_tile_provider/flutter_map_cancellable_tile_provider.dart';
import 'dart:async';
import '../models/alarm.dart';

class TrackPage extends StatefulWidget {
  final Alarm? alarm;

  const TrackPage({Key? key, this.alarm}) : super(key: key);

  @override
  _TrackPageState createState() => _TrackPageState();
}

class _TrackPageState extends State<TrackPage> {
  LatLng? _currentPosition;
  LatLng? _destination;
  MapController _mapController = MapController();
  StreamSubscription<Position>? _positionStreamSubscription;
  double _distanceToDestination = 0;

  @override
  void initState() {
    super.initState();
    if (widget.alarm != null) {
      _destination = LatLng(widget.alarm!.latitude, widget.alarm!.longitude);
    }
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
        _updateDistanceToDestination();
      });
      if (widget.alarm != null) {
        _checkProximityToDestination();
      }
    });
  }

  void _updateDistanceToDestination() {
    if (_currentPosition != null && _destination != null) {
      _distanceToDestination = Geolocator.distanceBetween(
        _currentPosition!.latitude,
        _currentPosition!.longitude,
        _destination!.latitude,
        _destination!.longitude,
      );
    }
  }

  void _checkProximityToDestination() {
    if (widget.alarm != null && _distanceToDestination <= widget.alarm!.distance) {
      _positionStreamSubscription?.cancel();
      _showAlarmDialog();
    }
  }

  void _showAlarmDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Alarm'),
          content: Text('You have reached your destination!'),
          actions: <Widget>[
            TextButton(
              child: Text('Stop'),
              onPressed: () {

                // Return to the previous page
              },
            ),
          ],
        );
      },
    );
  }

  void _centerOnUserLocation() {
    if (_currentPosition != null) {
      _mapController.move(_currentPosition!, 14.0);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.alarm != null ? 'Tracking: ${widget.alarm!.name}' : 'Current Location'),
        backgroundColor: Colors.transparent,
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
                      urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
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
                            color: Colors.blue,
                            size: 30.0,
                          ),
                        ),
                        if (_destination != null)
                          Marker(
                            width: 80.0,
                            height: 80.0,
                            point: _destination!,
                            child: Icon(
                              Icons.location_pin,
                              color: Color.fromARGB(255, 243, 33, 33),
                              size: 30.0,
                            ),
                          ),
                      ],
                    ),
                    if (_destination != null)
                      PolylineLayer(
                        polylines: [
                          Polyline(
                            points: [_currentPosition!, _destination!],
                            strokeWidth: 4.0,
                            color: Colors.blue,
                          ),
                        ],
                      ),
                  ],
                ),
                if (_destination != null)
                  Positioned(
                    top: 100,
                    left: 10,
                    right: 10,
                    child: Container(
                      padding: EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.8),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        'Distance to destination: ${_distanceToDestination.toStringAsFixed(2)} meters',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _centerOnUserLocation,
        child: Icon(Icons.my_location),
        backgroundColor: Colors.blue,
      ),
    );
  }
}