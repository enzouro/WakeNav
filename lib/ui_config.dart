import 'package:flutter/material.dart';

class UiConfigPage extends StatefulWidget {
  @override
  _UiConfigPageState createState() => _UiConfigPageState();
}

class _UiConfigPageState extends State<UiConfigPage> {
  final appTitle = 'IT 331: AppDev';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(appTitle),
        backgroundColor: Colors.pink[400],
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context); // Navigate back to the previous screen
          },
        ),
      ),
      body: OrientationList(
        title: appTitle,
      ),
    );
  }
}

class OrientationList extends StatelessWidget {
  final String title;

  const OrientationList({Key? key, required this.title}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return OrientationBuilder(
      builder: (context, orientation) {
        return GridView.count(
          crossAxisCount: orientation == Orientation.portrait ? 3 : 4,
          children: List.generate(100, (index) {
            return Center(
              child: Text(
                'A $index',
              ),
            );
          }),
        );
      },
    );
  }
}
