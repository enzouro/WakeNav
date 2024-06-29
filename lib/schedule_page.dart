import 'package:flutter/material.dart';

class SchedulePage extends StatefulWidget {
  @override
  _SchedulePageState createState() => _SchedulePageState();
}

class _SchedulePageState extends State<SchedulePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Schedule Page'),
        backgroundColor: Colors.pink,
      ),
      body: Container(
        margin: EdgeInsets.symmetric(vertical: 20.0),
        height: 200.0, // Adjust height as needed
        child: ListView(
          scrollDirection: Axis.horizontal, // Ensure horizontal scrolling
          children: <Widget>[
            _buildImageCard('https://images.unsplash.com/photo-1718585708744-573c54a2c38c?q=80&w=1974&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D'), // Updated image URL 1
            _buildImageCard('https://images.unsplash.com/photo-1719567225847-ddd4fde6102a?q=80&w=1974&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D'), // Updated image URL 2
            _buildImageCard('https://images.unsplash.com/photo-1718930928057-09072e3b511d?q=80&w=1932&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D'), // Updated image URL 3
          ],
        ),
      ),
    );
  }

  Widget _buildImageCard(String imageUrl) {
    return Container(
      width: 300.0, // Fixed width for each image card
      margin: EdgeInsets.symmetric(horizontal: 5.0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10.0),
        child: Image.network(
          imageUrl,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Center(
              child: Text('Failed to load image'),
            );
          },
        ),
      ),
    );
  }
}
