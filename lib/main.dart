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

  bool _onVibrate = true;
  bool _onFlash = true;
  void _onChanged1(bool value) => setState(() => _onVibrate = value);
  void _onChanged2(bool value) => setState(() => _onFlash = value);

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
    MediaQueryData mediaQuery = MediaQuery.of(context);
    double screenWidth = mediaQuery.size.width;
    double screenHeight = mediaQuery.size.height;

    return new Scaffold(
      appBar: new AppBar(
        backgroundColor: Colors.blueAccent,
        title: new Text('Alarm System'),
        centerTitle: true,
      ),

      body: new Center(
        child: new Column(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
          new Container(
            color: Color.fromRGBO(80, 80, 80, 1),
            height: screenHeight/3,
            width: screenWidth - 80,
            child: new Center(            
              child: Card(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    new StreamBuilder(
                      initialData: AsyncSnapshot.nothing(),
                      stream: Firestore.instance.collection('vibratedata').snapshots(),
                      builder: (context, snapshot) {
                        if(!snapshot.hasData)
                          return Text('Loading data... Please wait...');

                        bool vibrateBool = snapshot.data.documents[0]['vibrate'];
                        if (vibrateBool == true) {
                          Vibrate.vibrateWithPauses(pauses);
                          Lamp.flash(new Duration(seconds: 10));
                          print("Yes it's gonna vibrate and flash.");
                          return Container(
                            child: 
                              new Image(image: AssetImage('assets/customerAlert.jpg'), fit: BoxFit.cover),
                          );
                        }
                        return Container(
                          child: 
                            new Image(image: AssetImage('assets/menu.jpg'), fit: BoxFit.cover),
                        );
                      }
                    ),
                  ]
                )
              )
            )
          ),
          new SwitchListTile(
            value: _onVibrate,
            onChanged: _onChanged1,
            title: new Text('On / Off Vibration', style: new TextStyle(fontWeight: FontWeight.bold, color: Colors.blueAccent)),
          ),
          new SwitchListTile(
            value: _onFlash,
            onChanged: _onChanged2,
            title: new Text('On / Off Flash', style: new TextStyle(fontWeight: FontWeight.bold, color: Colors.blueAccent)),
          ),
        ]),
      ),
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

