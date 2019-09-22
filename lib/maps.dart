import 'package:flutter/material.dart';


class MapsHome extends StatefulWidget {
  MapsHome({ this.title});

  final String title;

  MapsHomeState createState() => MapsHomeState(); 
}

class MapsHomeState extends State<MapsHome> with AutomaticKeepAliveClientMixin<MapsHome> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      _counter++;
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
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'You are in the musics section',
            ),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.display1,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: Icon(Icons.add),
      ),
    );
  }
  @override
  bool get wantKeepAlive => true;
}