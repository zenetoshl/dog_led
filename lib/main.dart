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
      theme: ThemeData(primarySwatch: Colors.lightBlue),
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
    MapsHome(title: 'Mapas'),
    ColorsHome(title: 'Cores'),
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
          BottomNavigationBarItem(icon: Icon(Icons.map), title: Text("Mapa")),
          BottomNavigationBarItem(
              icon: Icon(Icons.color_lens), title: Text("Cores")),
          BottomNavigationBarItem(
              icon: Icon(Icons.settings), title: Text("Opções")),
        ],
        currentIndex: currentIndex,
        onTap: pageController.jumpToPage,
      ),
      body: PageView(
        physics: NeverScrollableScrollPhysics(),
        children: widgetOptions,
        controller: pageController,
        onPageChanged: onPageChanged,
      ),
    );
  }
}
