//track_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_map_cancellable_tile_provider/flutter_map_cancellable_tile_provider.dart';

class TrackPage extends StatefulWidget {
  final LatLng? destination;
  final List<LatLng>? routePoints;

  const TrackPage({Key? key, this.destination, this.routePoints}) : super(key: key);

  @override
  _TrackPageState createState() => _TrackPageState();
}

class _TrackPageState extends State<TrackPage> {
  LatLng? _currentPosition;
  LatLng? _destination;
  List<LatLng>? _routePoints;
  MapController _mapController = MapController();

  @override
  void initState() {
    super.initState();
    _destination = widget.destination;
    _routePoints = widget.routePoints;
    _getCurrentLocation();
  }

  @override
  void didUpdateWidget(TrackPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.destination != oldWidget.destination || widget.routePoints != oldWidget.routePoints) {
      setState(() {
        _destination = widget.destination;
        _routePoints = widget.routePoints;
      });
    }
  }

  void _getCurrentLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.bestForNavigation);
      setState(() {
        _currentPosition = LatLng(position.latitude, position.longitude);
      });
    } catch (e) {
      print("Error getting location: $e");
    }
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
        title: Text('Track'),
        backgroundColor: Colors.transparent,
      ),
      extendBodyBehindAppBar: true,
      body: _currentPosition == null
          ? Center(child: CircularProgressIndicator())
          : FlutterMap(
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
                if (_routePoints != null && _routePoints!.isNotEmpty)
                  PolylineLayer(
                    polylines: [
                      Polyline(
                        points: _routePoints!,
                        strokeWidth: 4.0,
                        color: Colors.blue,
                      ),
                    ],
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