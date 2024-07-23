// main.dart
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:wakenav/alarms_page.dart';
import 'package:wakenav/track_page.dart';
import 'package:wakenav/navigate_page.dart';
import 'package:wakenav/splash_screen.dart';

void main() {
  runApp(WakeNavApp());
}

class WakeNavApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'WakeNav',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: SplashScreen(),
    );
  }
}

class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;
  LatLng? _destination;
  List<LatLng>? _routePoints;

  void _updateRouteInfo(LatLng? destination, List<LatLng>? routePoints) {
    setState(() {
      _destination = destination;
      _routePoints = routePoints;
    });
  }

  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      TrackPage(destination: _destination, routePoints: _routePoints),
      NavigatePage(
        onRouteSet: _updateRouteInfo,
        initialDestination: _destination,
        initialRoute: _routePoints,
      ),
      AlarmsPage(),
      Placeholder(), // SettingsPage placeholder
    ];
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      // Update both pages when switching
      _pages[0] = TrackPage(destination: _destination, routePoints: _routePoints);
      _pages[1] = NavigatePage(
        onRouteSet: _updateRouteInfo,
        initialDestination: _destination,
        initialRoute: _routePoints,
      );
      _pages[2] = AlarmsPage();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'WakeNav',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                    ),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: Icon(Icons.map),
              title: Text('Track'),
              selected: _selectedIndex == 0,
              onTap: () {
                _onItemTapped(0);
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(Icons.add_location),
              title: Text('Create'),
              selected: _selectedIndex == 1,
              onTap: () {
                _onItemTapped(1);
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(Icons.alarm),
              title: Text('Alarms'),
              selected: _selectedIndex == 2,
              onTap: () {
                _onItemTapped(2);
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(Icons.settings),
              title: Text('Settings'),
              selected: _selectedIndex == 3,
              onTap: () {
                _onItemTapped(3);
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
      body: Stack(
        children: [
          _pages[_selectedIndex],
          Positioned(
            top: 40,
            left: 10,
            child: Builder(
              builder: (context) => IconButton(
                icon: Icon(Icons.menu),
                onPressed: () => Scaffold.of(context).openDrawer(),
                color: Colors.black54,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
