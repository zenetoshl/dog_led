import 'package:flutter/material.dart';
import 'maps.dart';
import 'colors.dart';
import 'settings.dart';

void main() => runApp(NavigationMain());

class NavigationMain extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Dog Led',
      theme: ThemeData(primarySwatch: Colors.blueGrey),
      home: CustomNavigationTab(),
    );
  }
}

class CustomNavigationTab extends StatefulWidget {
  CustomNavigationTab();
  CustomNavigationTabState createState() => CustomNavigationTabState();
}

class CustomNavigationTabState extends State<CustomNavigationTab> {
  static List<Widget> widgetOptions = <Widget>[
    MapsHome(title: 'Maps'),
    ColorsHome(title: 'Colors'),
    SettingsHome(title: 'Settings'),
  ];

  int currentIndex = 0;

  final pageController = PageController();
  void onPageChanged(int index) {
    setState(() {
      currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        bottomNavigationBar: BottomNavigationBar(
          items: <BottomNavigationBarItem>[
            BottomNavigationBarItem(icon: Icon(Icons.map), title: Text("Maps")),
            BottomNavigationBarItem(
                icon: Icon(Icons.color_lens), title: Text("Colors")),
            BottomNavigationBarItem(
                icon: Icon(Icons.settings), title: Text("Settings")),
          ],
          currentIndex: currentIndex,
          onTap: pageController.jumpToPage,
        ),
        body: PageView(
          children: widgetOptions,
          controller: pageController,
          onPageChanged: onPageChanged,
        ));
  }
}
