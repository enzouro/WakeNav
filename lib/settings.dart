import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

// List of Cards with size
List<StaggeredTile> _cardTile = <StaggeredTile>[
  StaggeredTile.count(2, 3),
  StaggeredTile.count(2, 2),
  StaggeredTile.count(2, 3),
  StaggeredTile.count(2, 2),
  StaggeredTile.count(2, 3),
  StaggeredTile.count(2, 2),
  StaggeredTile.count(2, 3),
  StaggeredTile.count(2, 2),
  StaggeredTile.count(2, 3),
  StaggeredTile.count(2, 2),
];

// List of Cards with color and icon
List<Widget> _listTile = <Widget>[
  BackGroundTile(backgroundColor: Colors.pink, icondata: Icons.favorite),
  BackGroundTile(backgroundColor: Colors.orange, icondata: Icons.ac_unit),
  BackGroundTile(backgroundColor: Colors.purple, icondata: Icons.landscape),
  BackGroundTile(backgroundColor: Colors.redAccent, icondata: Icons.portrait),
  BackGroundTile(backgroundColor: Colors.deepPurpleAccent, icondata: Icons.music_note),
  BackGroundTile(backgroundColor: Colors.blue, icondata: Icons.access_alarms),
  BackGroundTile(backgroundColor: Colors.indigo, icondata: Icons.satellite_outlined),
  BackGroundTile(backgroundColor: Colors.cyan, icondata: Icons.search_sharp),
  BackGroundTile(backgroundColor: Colors.amber, icondata: Icons.adjust_rounded),
  BackGroundTile(backgroundColor: Colors.black, icondata: Icons.attach_money),
];

class SettingsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Settings Page"),
        backgroundColor: Colors.amber, // Set AppBar background color to amber
      ),
      body: Container(
        padding: EdgeInsets.all(8.0),
        // Staggered Grid View starts here
        child: StaggeredGridView.countBuilder(
          crossAxisCount: 4, // Number of columns in the grid
          mainAxisSpacing: 4.0,
          crossAxisSpacing: 4.0,
          itemCount: _listTile.length,
          itemBuilder: (BuildContext context, int index) => _listTile[index],
          staggeredTileBuilder: (int index) => _cardTile[index],
        ),
      ),
    );
  }
}

class BackGroundTile extends StatelessWidget {
  final Color backgroundColor;
  final IconData icondata;

  BackGroundTile({required this.backgroundColor, required this.icondata});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: backgroundColor,
      child: Center(
        child: Icon(icondata, color: Colors.white),
      ),
    );
  }
}
