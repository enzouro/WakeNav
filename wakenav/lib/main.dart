// main.dart
import 'package:flutter/material.dart';
import 'package:wakenav/alarms_page.dart';
import 'package:wakenav/splash_screen.dart';
import 'package:wakenav/track_page.dart';
import 'package:wakenav/navigate_page.dart';
import 'package:wakenav/models/alarm.dart';

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

final GlobalKey<_MainScreenState> mainScreenKey = GlobalKey<_MainScreenState>();

class MainScreen extends StatefulWidget {
  MainScreen({Key? key}) : super(key: mainScreenKey);

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;
  Alarm? _currentAlarm;

  void _updateRouteInfo(Alarm? alarm) {
    setState(() {
      _currentAlarm = alarm;
    });
  }
    void updateStateWithAlarm(Alarm alarm) {
    setState(() {
      _currentAlarm = alarm;
      _selectedIndex = 0;  // Switch to the TrackPage
    });
    _updatePages();  // Add this method to update the pages with the new alarm
  }

  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      TrackPage(alarm: _currentAlarm),
      NavigatePage(
        onRouteSet: _updateRouteInfo,
        initialAlarm: _currentAlarm,
      ),
      AlarmsPage(),
      Placeholder(), // SettingsPage placeholder
    ];
  }

  void _updatePages() {
    setState(() {
      _pages[0] = TrackPage(alarm: _currentAlarm);
      _pages[1] = NavigatePage(
        onRouteSet: _updateRouteInfo,
        initialAlarm: _currentAlarm,
      );
    });
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
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
              decoration: BoxDecoration(color: Colors.blue),
              child: Text('WakeNav', style: TextStyle(color: Colors.white, fontSize: 24)),
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