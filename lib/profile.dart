import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';

class ProfileScreen extends StatefulWidget {
  ProfileScreen({this.title});

  final String title;

  ProfileScreenState createState() => ProfileScreenState();
}

class ProfileScreenState extends State<ProfileScreen> {
  String newName = '';
  bool editable = false;

  void toggleEditable() {
    setState(() {
      editable = editable ? false : true;
    });
  }

  @mustCallSuper
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          children: <Widget>[
            SizedBox(
              height: 20,
            ),
            Row(
              children: <Widget>[
                SizedBox(
                  width: 20,
                ),
                SizedBox(
                  width: 200,
                  height: 35,
                  child: TextField(
                    onChanged: (text) {
                      setState(() {
                        newName = text;
                      });
                    },
                    enabled: editable,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(gapPadding: 6.0),
                      focusColor: Colors.green,
                      labelText: 'Novo Nome',
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(editable ? Icons.cancel : Icons.edit),
                  onPressed: toggleEditable,
                ),
                IconButton(
                  icon: Icon(Icons.save),
                  onPressed: editable
                      ? () {
                          _save();
                          toggleEditable();
                        }
                      : () {},
                  color: editable ? Colors.blue : Colors.grey,
                )
              ],
            ),
          ],
        ),
      ),
    );
  }

  _save() async {
    final prefs = await SharedPreferences.getInstance();
    final key = 'saved_name';
    final value = newName ?? null;
    if (value != null) prefs.setString(key, value);
  }
}
