import 'package:flutter/material.dart';

class AlarmPage extends StatefulWidget {
  @override
  _AlarmPageState createState() => _AlarmPageState();
}

class _AlarmPageState extends State<AlarmPage> {
  List<String> alarms = ['Alarm 1', 'Alarm 2', 'Alarm 3']; // Example list of alarms

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Alarm Page'),
        backgroundColor: Colors.pink,
      ),
      body: ListView.builder(
        itemCount: alarms.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(alarms[index]),
            trailing: IconButton(
              icon: Icon(Icons.delete),
              onPressed: () {
                setState(() {
                  alarms.removeAt(index);
                });
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Add new alarm functionality here
          setState(() {
            alarms.add('New Alarm');
          });
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
