import 'package:flutter/material.dart';
import 'dart:math';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Random Pi Estimation',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Random Pi Estimation'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<_RandomPoint> _randomPoints = new List();

  int _numInCircle = 0;

  void _addRandomPoint() {
    setState(() {
      _randomPoints.add(new _RandomPoint());
      if (_randomPoints.last.isInCircle()) {
        _numInCircle++;
      }
    });
  }

  // Use the random points so far to estimate the value of pi
  double estimatePi() {
    return (_numInCircle / _randomPoints.length) * 4.0;
  }

  // Use the random points so far to estimate the value of tau
  double estimateTau() {
    return 2.0 * (_numInCircle / _randomPoints.length) * 4.0;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Text("$_numInCircle / ${_randomPoints.length} = " +
            "${_numInCircle / _randomPoints.length}\n" +
            "π = ${estimatePi()}"),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addRandomPoint,
        tooltip: 'Add new random point',
        child: Icon(Icons.add),
      ),
    );
  }
}

class _RandomPoint extends StatelessWidget {
  final Point<double> randomPoint = Point(_getCoordinate(), _getCoordinate());

  double getX() {
    return randomPoint.x;
  }

  double getY() {
    return randomPoint.y;
  }

  // Generates a random double from -1.0 to 1.0, both exclusive
  static double _getCoordinate() {
    double magnitude = Random.secure().nextDouble();
    bool isNegative = Random.secure().nextBool();
    return (isNegative) ? -magnitude : magnitude;
  }

  // Calculates if the point is within the bounds of a circle with radius 1
  bool isInCircle() {
    return 1 > randomPoint.distanceTo(Point(0, 0));
  }

  @override
  Widget build(BuildContext context) {
    return new Text(isInCircle().toString() + " " + randomPoint.toString());
  }
}
