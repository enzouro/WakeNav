import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:open_route_service/open_route_service.dart';
import 'package:flutter_map_cancellable_tile_provider/flutter_map_cancellable_tile_provider.dart';

class CreatePage extends StatefulWidget {
  const CreatePage({super.key});

  @override
  State<CreatePage> createState() => _CreatePageState();
}

class _CreatePageState extends State<CreatePage> {
  late MapController mapController;
  LatLng? currentLocation;
  LatLng? destinationLocation;
  List<LatLng> routePoints = [];
  double? routeDistance;

  @override
  void initState() {
    super.initState();
    mapController = MapController();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      setState(() {
        currentLocation = LatLng(position.latitude, position.longitude);
      });
    } catch (e) {
      print("Error getting current location: $e");
    }
  }

  Future<void> _setDestination(LatLng destination) async {
    setState(() {
      destinationLocation = destination;
    });

    if (currentLocation != null && destinationLocation != null) {
      await _calculateRoute();
    }
  }

  Future<void> _calculateRoute() async {
    try {
      final OpenRouteService client = OpenRouteService(apiKey: '5b3ce3597851110001cf62486c73e559cfcf4359b409b8c79fa7faa1');
      final List<ORSCoordinate> routeCoordinates = await client.directionsRouteCoordsGet(
        startCoordinate: ORSCoordinate(
            latitude: currentLocation!.latitude,
            longitude: currentLocation!.longitude),
        endCoordinate: ORSCoordinate(
            latitude: destinationLocation!.latitude,
            longitude: destinationLocation!.longitude),
      );

      setState(() {
        routePoints = routeCoordinates
            .map((coord) => LatLng(coord.latitude, coord.longitude))
            .toList();

      });
    } catch (e) {
      print("Error calculating route: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Map Page'),
      ),
      body: currentLocation == null
          ? Center(child: CircularProgressIndicator())
          : FlutterMap(
              mapController: mapController,
              options: MapOptions(
                initialCenter: currentLocation!,
                initialZoom: 15.0,
                onTap: (tapPosition, point) async {
                  await _setDestination(point);
                },
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
                      point: currentLocation!,
                      child: Icon(
                        Icons.my_location,
                        color: Colors.blue,
                        size: 30.0,
                      ),
                    ),
                    if (destinationLocation != null)
                      Marker(
                        point: destinationLocation!,
                        child: Icon(
                          Icons.location_on,
                          color: Colors.red,
                          size: 30.0,
                        ),
                      ),
                  ],
                ),
                if (routePoints.isNotEmpty)
                  PolylineLayer(
                    polylines: [
                      Polyline(
                        points: routePoints,
                        strokeWidth: 4.0,
                        color: Colors.blue,
                      ),
                    ],
                  ),
              ],
            ),
            bottomSheet: routeDistance != null
                ? Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text('Distance: ${routeDistance!.toStringAsFixed(2)} km'),
                  )
                : null,
          );
  }
    @override
  void dispose() {
    setState(() {
    });
    super.dispose();
  }
}