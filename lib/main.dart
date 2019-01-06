import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:vibrate/vibrate.dart';
import 'package:lamp/lamp.dart';
import 'dart:async';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: new VibrateHomePage(),
    );
  }
}

class VibrateHomePage extends StatefulWidget {
  @override
  _VibrateHomePageState createState() => new _VibrateHomePageState();
}

class _VibrateHomePageState extends State<VibrateHomePage> {
  bool _canVibrate = true;
  final Iterable<Duration> pauses = [
    const Duration(milliseconds: 500),
    const Duration(milliseconds: 1000),
    const Duration(milliseconds: 500),
  ];
  bool _hasFlash = false;
  bool _isOn = false;
  double _intensity = 1.0;

  @override
  initState() {
    super.initState();
    init();
  }

  init() async {
    bool canVibrate = await Vibrate.canVibrate;
    setState(() {
      _canVibrate = canVibrate;
      _canVibrate
          ? print("This device can vibrate")
          : print("This device cannot vibrate");
    });
    bool hasFlash = await Lamp.hasLamp;
    setState(() { _hasFlash = hasFlash; });
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text('Alarm System')
      ),

      body: new Center(
        child: new Column(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
          new StreamBuilder(
            initialData: AsyncSnapshot.nothing(),
            stream: Firestore.instance.collection('vibratedata').snapshots(),
            builder: (context, snapshot) {
              if(!snapshot.hasData)
                return Text('Loading data... Please wait...');
                
              bool vibrateBool = snapshot.data.documents[0]['vibrate'];
              if (vibrateBool = true) {
                Vibrate.vibrateWithPauses(pauses);
                print("Yes it's gonna vibrate.");
              }

              return Container();
            }
          ),

          new ListTile(
            title: new Text("Test if vibration works!"),
            leading: new Icon(Icons.vibration, color: Colors.teal),
            onTap: !_canVibrate
              ? () {}
              : () {
                  Vibrate.vibrateWithPauses(pauses);
              },
          ),

          new Slider(value: _intensity, onChanged: _isOn ? _intensityChanged : null),
          new RaisedButton(onPressed: () async => await Lamp.flash(new Duration(seconds: 2)), child:  new Text("Flash for 2 seconds"))
        ]),
      ),
      floatingActionButton: new FloatingActionButton(
        child: new Icon(_isOn ? Icons.flash_off : Icons.flash_on),
        onPressed: _turnFlash),
    );
  }

  Future _turnFlash() async {
    _isOn ? Lamp.turnOff() : Lamp.turnOn(intensity: _intensity);
    var f = await Lamp.hasLamp;
    setState((){
      _hasFlash = f;
      _isOn = !_isOn;
    });
  }

  _intensityChanged(double intensity) {
    Lamp.turnOn(intensity : intensity);
    setState((){
      _intensity = intensity;
    });
  }
}