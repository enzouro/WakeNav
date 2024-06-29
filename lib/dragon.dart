import 'package:flutter/material.dart';
void main() => runApp(const MyApp());
class MyApp extends StatelessWidget {
const MyApp({Key? key}) : super(key: key);
@override
Widget build(BuildContext context) {
return MaterialApp(
home: MyHomePage(),
);

}
}
class MyHomePage extends StatefulWidget {
const MyHomePage({Key? key}) : super(key: key);
@override
_MyHomePageState createState() => _MyHomePageState();
}
class _MyHomePageState extends State<MyHomePage> {
int _currentIndex = 0;
final List<Widget> _pages = [
Center(child: Text('Home Page', style: TextStyle(fontSize: 24))),
Center(child: Text('Search Page', style: TextStyle(fontSize: 24))),
Center(child: Text('Profile Page', style: TextStyle(fontSize: 24))),
];
@override
Widget build(BuildContext context) {
return Scaffold(
appBar: AppBar(
backgroundColor: Colors.amber,
title: const Text('Bonjour!'),
),
body: _pages[_currentIndex],
drawer: Drawer(
child: ListView(
padding: EdgeInsets.zero,
children: const <Widget>[
DrawerHeader(
decoration: BoxDecoration(
color: Color.fromARGB(255, 248, 126, 177),
),
child: Text(
'Hello world!',
style: TextStyle(
color: Colors.white,
fontSize: 24,
),
),
),
ListTile(


title: Text('1st Item'),
),
ListTile(
title: Text('2nd Item'),
),
],
),
),
bottomNavigationBar: BottomNavigationBar(
currentIndex: _currentIndex,
fixedColor: Colors.pink,
items: const [
BottomNavigationBarItem(
label: "Home",
icon: Icon(Icons.home),
),
BottomNavigationBarItem(
label: "Search",
icon: Icon(Icons.search),
),
BottomNavigationBarItem(
label: "Profile",
icon: Icon(Icons.account_circle),
),
],
onTap: (int index) {
setState(() {
_currentIndex = index;
});
},
),
);
}
}