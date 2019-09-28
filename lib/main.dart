import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
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
  static BluetoothDevice device;
  static BluetoothCharacteristic writeChar, readChar;

  static List<Widget> widgetOptions = <Widget>[
    MapsHome(title: 'Mapas'),
    ColorsHome(
      title: 'Cores',
      device: device,
      write: writeChar,
      read: readChar,
    ),
    SettingsHome(
      title: 'Settings',
      device: device,
      write: writeChar,
      read: readChar,
    ),
  ];

  int currentIndex = 0;
  
  void initScan() async {
    FlutterBlue.instance
        .startScan(scanMode: ScanMode.balanced, timeout: Duration(seconds: 10));
  }




  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    initScan();
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
      ),
    );
  }
}
