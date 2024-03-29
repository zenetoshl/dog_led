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
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.light,
        colorScheme: ColorScheme.light(),
        primarySwatch: Colors.red,
        primaryColor: Colors.red[700],
        buttonColor: Colors.red[600],
        toggleableActiveColor: Colors.red[600],
        accentColor: Colors.redAccent[400],
        floatingActionButtonTheme: FloatingActionButtonThemeData(
          backgroundColor: Colors.red[300],
        ),
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        colorScheme: ColorScheme.dark(),
        primarySwatch: Colors.pink,
        primaryColor: Colors.pink[900],
        buttonColor: Colors.pink[900],
        toggleableActiveColor: Colors.pink[600],
        accentColor: Colors.pinkAccent[400],
        floatingActionButtonTheme: FloatingActionButtonThemeData(
          backgroundColor: Colors.pink[700],
        ),
      ),
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
    ColorsHome(
      title: 'Cores',
    ),
    SettingsHome(
      title: 'Settings',
    ),
  ];

  int currentIndex = 0;

  @override
  void initState() {
    super.initState();
  }

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
      )
    );
  }
}
