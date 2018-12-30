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

  void _addRandomPoint() {
    setState(() {
      // Generates random double from 0.0 inclusive to 1.0 exclusive
      _randomPoints.add(new _RandomPoint());
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: ListView.builder(
            itemCount: _randomPoints.length,
            itemBuilder: (BuildContext ctxt, int index) => _randomPoints[index],
        )
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
  Point<double> randomPoint;

  double getRandomCoordinate() {
    double magnitude = Random.secure().nextDouble();
    bool isNegative = Random.secure().nextBool();
    return (isNegative) ? -magnitude : magnitude;
  }

  _RandomPoint() {
    randomPoint = new Point(getRandomCoordinate(), getRandomCoordinate());
  }

  @override
  Widget build(BuildContext context) {
    return new Text(randomPoint.toString());
  }
}
