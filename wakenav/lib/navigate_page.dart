//navigate_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_map_cancellable_tile_provider/flutter_map_cancellable_tile_provider.dart';
import 'package:http/http.dart' as http;
import 'package:wakenav/models/alarm.dart';
import 'dart:convert';
import 'dart:async';
import 'widget/alarm_drawer.dart';


class NavigatePage extends StatefulWidget {
  final Function(Alarm?) onRouteSet;
  final Alarm? initialAlarm;
  final Function(Alarm) updateAlarmStatus;

  const NavigatePage({
    Key? key, 
    required this.onRouteSet, 
    this.initialAlarm,
    required this.updateAlarmStatus,
  }) : super(key: key);

  @override
  _NavigatePageState createState() => _NavigatePageState();
}

class _NavigatePageState extends State<NavigatePage> {
  LatLng? _currentPosition;
  LatLng? _destinationPosition;
  MapController _mapController = MapController();
  TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _searchResults = [];
  Timer? _debounce;
  bool _showAlarmDrawer = false;
  bool _isDestinationSet = false;


@override
void initState() {
  super.initState();
  _destinationPosition = widget.initialAlarm != null 
      ? LatLng(widget.initialAlarm!.latitude, widget.initialAlarm!.longitude)
      : null;
  _getCurrentLocation();
  _searchController.addListener(_onSearchChanged);
}
  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      if (_searchController.text.isNotEmpty) {
        _searchLocation(_searchController.text);
      } else {
        setState(() {
          _searchResults = [];
        });
      }
    });
  }

  void _getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      _showErrorMessage('Location services are disabled.');
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        _showErrorMessage('Location permissions are denied');
        return;
      }
    }
    
    if (permission == LocationPermission.deniedForever) {
      _showErrorMessage('Location permissions are permanently denied, we cannot request permissions.');
      return;
    } 

    try {
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      setState(() {
        _currentPosition = LatLng(position.latitude, position.longitude);
      });
    } catch (e) {
      _showErrorMessage("Error getting location: $e");
    }
  }

void _handleLongPress(TapPosition _, LatLng tappedPoint) {
  setState(() {
    _destinationPosition = tappedPoint;
    _isDestinationSet = true;
    _showAlarmDrawer = true;
  });
  _setDestination(tappedPoint);
  _panToDestination();
}

  Future<List<Map<String, dynamic>>> searchLocation(String query) async {
    final String url = 'https://nominatim.openstreetmap.org/search?format=json&q=$query';
    
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        return data.map((item) => {
          'name': item['display_name'],
          'lat': double.parse(item['lat']),
          'lon': double.parse(item['lon'])
        }).toList();
      } else {
        print('Error: HTTP ${response.statusCode}');
      }
    } catch (e) {
      print('Error searching location: $e');
    }
    return [];
  }

  void _searchLocation(String query) async {
    try {
      List<Map<String, dynamic>> results = await searchLocation(query);
      setState(() {
        _searchResults = results;
      });
    } catch (e) {
      print('Error in search handling: $e');
      _showErrorMessage("Error searching for location");
    }
  }

void _selectLocation(Map<String, dynamic> location) {
  LatLng destination = LatLng(location['lat'], location['lon']);
  setState(() {
    _destinationPosition = destination;
    _isDestinationSet = true;
    _showAlarmDrawer = true;
  });
  _setDestination(destination);
  _panToDestination();
  _searchController.clear();
  setState(() {
    _searchResults = [];
  });
}
// Inside NavigatePage
void _setDestination([LatLng? destination]) {
  if (destination == null && _searchResults.isNotEmpty) {
    _selectLocation(_searchResults.first);
  } else if (destination != null) {
    Alarm newAlarm = Alarm(
      id: DateTime.now().toString(), // You might want to use a proper UUID here
      name: "New Alarm",
      distance: 100, // Default distance, you might want to make this configurable
      latitude: destination.latitude,
      longitude: destination.longitude,
    );
    widget.onRouteSet(newAlarm);
  }
}
void _closeAlarmDrawer() {
  setState(() {
    _showAlarmDrawer = false;
    _isDestinationSet = false;
    _destinationPosition = null;
  });
  widget.onRouteSet(null);
}

  void _saveAlarm() {
    // Implement saving alarm logic
    print('Saving alarm');
  }

  void _startAlarm() {
    // Implement starting alarm logic
    print('Starting alarm');
  }

  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  void _panToDestination() {
    if (_destinationPosition != null) {
      final offset = -0.006;
      final newCenter = LatLng(_destinationPosition!.latitude + offset, _destinationPosition!.longitude);
      _mapController.move(newCenter, 15.0);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Navigate'),
        backgroundColor: Colors.transparent,
      ),
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          _currentPosition == null
              ? Center(child: CircularProgressIndicator())
              : FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    initialCenter: _currentPosition!,
                    initialZoom: 13.0,
                    onLongPress: _handleLongPress,
                  ),
                  children: [
                    TileLayer(
                      urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.example.app',
                      tileProvider: CancellableNetworkTileProvider(),
                    ),
                    MarkerLayer(
                      markers: [
                        if (_currentPosition != null)
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
                        if (_destinationPosition != null)
                          Marker(
                            width: 80.0,
                            height: 80.0,
                            point: _destinationPosition!,
                            child: Icon(
                              Icons.location_pin,
                              color: Color.fromARGB(255, 243, 33, 33),
                              size: 40.0,
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
          if (!_isDestinationSet)
            Positioned(
              top: 100,
              left: 20,
              right: 20,
              child: Column(
                children: [
                  Container(
                    color: Colors.white,
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _searchController,
                            decoration: InputDecoration(
                              hintText: 'Search for a location',
                              contentPadding: EdgeInsets.symmetric(horizontal: 10),
                            ),
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.search),
                          onPressed: _setDestination,
                        ),
                      ],
                    ),
                  ),
                  if (_searchResults.isNotEmpty)
                    Container(
                      color: Colors.white,
                      child: Column(
                        children: _searchResults.map((location) => ListTile(
                          title: Text(location['name']),
                          onTap: () => _selectLocation(location),
                        )).toList(),
                      ),
                    ),
                ],
              ),
            ),
          if (_showAlarmDrawer)
          AlarmDrawer(
            onCancel: _closeAlarmDrawer,
            onSave: (Alarm alarm) {
              print('Alarm saved: ${alarm.name}');
              widget.onRouteSet(alarm);
            },
            onStart: (Alarm alarm) {
              print('Alarm started: ${alarm.name}');
              widget.onRouteSet(alarm);
            },
            latitude: _destinationPosition!.latitude,
            longitude: _destinationPosition!.longitude,
          ),
        ],
      ),
    );
  }
}