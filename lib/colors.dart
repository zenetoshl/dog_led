import 'package:flutter/material.dart';

enum LedColors { red, green, blue }

class ColorsHome extends StatefulWidget {
  ColorsHome({this.title});

  final String title;

  ColorsHomeState createState() => ColorsHomeState();
}

class ColorsHomeState extends State<ColorsHome> {
  LedColors color = LedColors.red; //receber da placa
  bool isOn = false; //tambem receber da placa
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            SizedBox(
              height: 30,
            ),
            Text(
              '   Ligar Led',
              style: Theme.of(context).textTheme.title,
            ),
            SizedBox(
              height: 10,
            ),
            ListTile(
              title: Text(isOn ? 'Ligado!' : 'Desligado!'),
              leading: new Switch(
                activeColor: Colors.teal,
                value: isOn,
                onChanged: (bool value) {
                  setState(() {
                    isOn = value;
                  });
                },
              ),
            ),
            SizedBox(
              height: 20,
            ),
            Divider(
              color: Colors.grey,
              indent: 30,
              endIndent: 30,
              thickness: 1,
            ),
            SizedBox(
              height: 20,
            ),
            Text(
              '   Cores',
              style: Theme.of(context).textTheme.title,
            ),
            SizedBox(
              height: 10,
            ),
            ListTile(
              title: Text(
                'Vermelho',
                style: Theme.of(context).textTheme.subtitle,
              ),
              leading: new Radio(
                activeColor: Colors.red,
                value: LedColors.red,
                groupValue: color,
                onChanged: (LedColors value) {
                  //mandar para a placa
                  setState(() {
                    color = value;
                  });
                },
              ),
            ),
            ListTile(
              title: Text(
                'Verde',
                style: Theme.of(context).textTheme.subtitle,
              ),
              leading: new Radio(
                activeColor: Colors.green,
                value: LedColors.green,
                groupValue: color,
                onChanged: (LedColors value) {
                  //mandar para a placa
                  setState(() {
                    color = value;
                  });
                },
              ),
            ),
            ListTile(
              title: Text(
                'Azul',
                style: Theme.of(context).textTheme.subtitle,
              ),
              leading: new Radio(
                activeColor: Colors.blue,
                value: LedColors.blue,
                groupValue: color,
                onChanged: (LedColors value) {
                  //mandar para a placa
                  setState(() {
                    color = value;
                  });
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
