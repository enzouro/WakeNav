import 'package:flutter/material.dart';
import 'package:flutter_application_1/themes.dart';
import 'track_page.dart';
import 'create_page.dart'; // Import the create_page.dart file
import 'alarm_page.dart'; // Import the alarm_page.dart file
import 'schedule_page.dart';
import 'settings.dart'; // Import the settings_page.dart file
import 'ui_config.dart';


void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  final appTitle = 'WakeNav';

  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: appTitle,
      theme: ThemeData(
        fontFamily: 'Nunito',
      ),
      home: MyHomePage(title: appTitle),
    );
  }
}

class MyHomePage extends StatelessWidget {
  final String title;

  const MyHomePage({Key? key, required this.title}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        backgroundColor: Colors.pink,
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            'assets/map.png', // Adjust path as per your setup
            fit: BoxFit.cover, // Cover the whole stack
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Alvarez, Irish Jane \nManigbas, Queenie Angelou \nMayo, John Lorenz',
                  style: TextStyle(fontSize: 20.0, color: Colors.black),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 20), // Adjust the height as needed
                ElevatedButton(
                  onPressed: () {
                    // Button action
                  },
                  child: Text('Set Alarm'),
                ),
              ],
            ),
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.pink,
              ),
              child: UserAccountsDrawerHeader(
                decoration: BoxDecoration(color: Colors.pink),
                accountName: Text(
                  "WakeNav",
                  style: TextStyle(fontSize: 18),
                ),
                accountEmail: Text("your partner in travelling"),
                currentAccountPictureSize: Size.square(50),
                currentAccountPicture: CircleAvatar(
                  backgroundColor: Color.fromARGB(255, 255, 234, 254),
                  child: Text(
                    "WN",
                    style: TextStyle(
                      fontSize: 30.0,
                      color: Color.fromARGB(255, 243, 33, 131),
                    ),
                  ),
                ),
              ),
            ),
            ListTile(
              leading: Icon(Icons.location_on),
              title: Text(' Track '),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => TrackPage()), // Navigate to TrackPage
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.create),
              title: Text(' Create '),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => CreatePage()), // Navigate to CreatePage
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.alarm),
              title: Text(' Alarms '),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AlarmPage()), // Navigate to AlarmPage
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.lock_clock),
              title: Text(' Schedules '),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => SchedulePage()),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.settings),
              title: Text(' Settings '),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => SettingsPage()),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.color_lens),
              title: Text(' Themes '),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ThemePage()),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.screen_lock_rotation_rounded),
              title: Text(' UI Config '),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => UiConfigPage()),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.logout),
              title: Text('Close'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}
