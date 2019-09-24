import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsHome extends StatefulWidget {
  SettingsHome({this.title});

  final String title;

  SettingsHomeState createState() => SettingsHomeState();
}

class SettingsHomeState extends State<SettingsHome> {
  String newName;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'You are in the Settings section',
            ),
            Text(
              'Settings Only',
              style: Theme.of(context).textTheme.display1,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _save,
        tooltip: 'Increment',
        child: Icon(Icons.add),
      ),
    );
  }

  _save() async {
    final prefs = await SharedPreferences.getInstance();
    final key = 'my_int_key';
    final value = newName ?? null;
    if (value == null) prefs.setString(key, value);
  }
}
