// main.dart

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
  List<Alarm> _activeAlarms = [];

  void _updateRouteInfo(Alarm alarm) {
    setState(() {
      if (!_activeAlarms.contains(alarm)) {
        _activeAlarms.add(alarm);
      }
    });
  }

  void updateStateWithAlarm(Alarm alarm) {
    setState(() {
      if (!_activeAlarms.contains(alarm)) {
        _activeAlarms.add(alarm);
      }
      _selectedIndex = 0; // Switch to the TrackPage
    });
    _updatePages();
  }

  void removeActiveAlarm(Alarm alarm) {
    setState(() {
      _activeAlarms.removeWhere((a) => a.id == alarm.id);
    });
    _updatePages();
  }

  void updateAlarmStatus(Alarm alarm) {
    setState(() {
      int index = _activeAlarms.indexWhere((a) => a.id == alarm.id);
      if (index != -1) {
        if (alarm.isActive) {
          _activeAlarms[index] = alarm;
        } else {
          _activeAlarms.removeAt(index);
        }
      } else if (alarm.isActive) {
        _activeAlarms.add(alarm);
      }
    });
    _updateAlarmInStorage(alarm);
    _updatePages();
  }

  Future<void> _updateAlarmInStorage(Alarm alarm) async {
    final prefs = await SharedPreferences.getInstance();
    final String? alarmsJson = prefs.getString('alarms');
    if (alarmsJson != null) {
      List<Alarm> alarms = (jsonDecode(alarmsJson) as List)
          .map((e) => Alarm.fromJson(e))
          .toList();
      int index = alarms.indexWhere((a) => a.id == alarm.id);
      if (index != -1) {
        alarms[index] = alarm;
        await prefs.setString('alarms', jsonEncode(alarms));
      }
    }
  }

  void _startAlarm(Alarm alarm) {
    setState(() {
      if (!_activeAlarms.contains(alarm)) {
        _activeAlarms.add(alarm);
      }
      _selectedIndex = 0; // Switch to the TrackPage
    });
    _updatePages();
  }

  void _stopAlarm(Alarm alarm) {
    setState(() {
      _activeAlarms.removeWhere((a) => a.id == alarm.id);
      alarm.deactivate();
    });
    updateAlarmStatus(alarm);
    _updatePages();
  }

  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      TrackPage(
        alarms: _activeAlarms,
        updateAlarmStatus: updateAlarmStatus,
      ),
      NavigatePage(
        onRouteSet: _updateRouteInfo,
        activeAlarms: _activeAlarms,
        updateAlarmStatus: updateAlarmStatus,
      ),
      AlarmsPage(
        onStartAlarm: _startAlarm,
        onStopAlarm: _stopAlarm,
      ),
      Placeholder(), // SettingsPage placeholder
    ];
  }

  void _updatePages() {
    setState(() {
      _pages[0] = TrackPage(
        alarms: _activeAlarms,
        updateAlarmStatus: updateAlarmStatus,
      );
      _pages[1] = NavigatePage(
        onRouteSet: _updateRouteInfo,
        activeAlarms: _activeAlarms,
        updateAlarmStatus: updateAlarmStatus,
      );
      _pages[2] = AlarmsPage(
        onStartAlarm: _startAlarm,
        onStopAlarm: _stopAlarm,
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
            const DrawerHeader(
              decoration: BoxDecoration(color: Color(0xFF008080)),
              child: Text('WakeNav',
                  style: TextStyle(color: Colors.white, fontSize: 24)),
            ),
            Padding(
              padding: EdgeInsets.all(10),
              child: Container(
                decoration: BoxDecoration(
                  color: _selectedIndex == 0
                      ? Color.fromARGB(255, 94, 204, 193)
                      : Color(0xFF008080),
                  borderRadius: BorderRadius.circular(15), // Set the curve
                ),
                child: ListTile(
                  leading: Icon(Icons.map, color: Colors.white),
                  title: Text('Track', style: TextStyle(color: Colors.white)),
                  selected: _selectedIndex == 0,
                  onTap: () {
                    _onItemTapped(0);
                    Navigator.pop(context);
                  },
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(10),
              child: Container(
                decoration: BoxDecoration(
                  color: _selectedIndex == 1
                      ? Color.fromARGB(255, 57, 185, 173)
                      : Color(0xFF008080),
                  borderRadius: BorderRadius.circular(15), // Set the curve
                ),
                child: ListTile(
                  leading: Icon(Icons.add_location, color: Colors.white),
                  title: Text('Navigate', style: TextStyle(color: Colors.white)),
                  selected: _selectedIndex == 1,
                  onTap: () {
                    _onItemTapped(1);
                    Navigator.pop(context);
                  },
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(10),
              child: Container(
                decoration: BoxDecoration(
                  color: _selectedIndex == 2
                      ? Color.fromARGB(255, 57, 185, 173)
                      : Color(0xFF008080),
                  borderRadius: BorderRadius.circular(15), // Set the curve
                ),
                child: ListTile(
                  leading: Icon(Icons.alarm, color: Colors.white),
                  title: Text('Alarms', style: TextStyle(color: Colors.white)),
                  selected: _selectedIndex == 2,
                  onTap: () {
                    _onItemTapped(2);
                    Navigator.pop(context);
                  },
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(10),
              child: Container(
                decoration: BoxDecoration(
                  color: _selectedIndex == 3
                      ? Color.fromARGB(255, 57, 185, 173)
                      : Color(0xFF008080),
                  borderRadius: BorderRadius.circular(15), // Set the curve
                ),
                child: ListTile(
                  leading: Icon(Icons.settings, color: Colors.white),
                  title:
                      Text('Settings', style: TextStyle(color: Colors.white)),
                  selected: _selectedIndex == 3,
                  onTap: () {
                    _onItemTapped(3);
                    Navigator.pop(context);
                  },
                ),
              ),
            ),
            Divider(),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Container(
                decoration: BoxDecoration(
                  color: Color.fromARGB(255, 209, 209, 209),
                  borderRadius: BorderRadius.circular(15),
                ), // Set the curve
                child: ListTile(
                  leading: Icon(Icons.exit_to_app),
                  title: Text('Exit'),
                  onTap: () {
                    SystemNavigator.pop();},
                ),
              ),
            ),
          ],
        ),
      ),
      body: Stack(
        children: [
          _pages[_selectedIndex],
          Positioned(
            top: 8,
            left: 10,
            child: Builder(
              builder: (context) => IconButton(
                icon: Icon(Icons.menu),
                onPressed: () => Scaffold.of(context).openDrawer(),
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
