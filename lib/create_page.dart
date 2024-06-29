import 'package:flutter/material.dart';

class CreatePage extends StatefulWidget {
  @override
  _CreatePageState createState() => _CreatePageState();
}

class _CreatePageState extends State<CreatePage> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this); // Define the number of tabs here
  }

  @override
  void dispose() {
    _tabController.dispose(); // Dispose of the tab controller properly
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Create Page'),
        backgroundColor: Colors.pink,
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(
              icon: Icon(Icons.alarm),
           
            ),
            Tab(
              icon: Icon(Icons.bookmark),
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Contents of Tab 1
          Center(
            child: Text('Alarm na this'), // Replace with your actual content
          ),
          // Contents of Tab 2
          Center(
            child: Text('This is it ticnap notnac'), // Replace with your actual content
          ),
        ],
      ),
    );
  }
}
