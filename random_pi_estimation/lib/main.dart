import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:redux/redux.dart';

double graphWidth;

@immutable
class AppState {
  final List<RandomPoint> randomPoints;
  final int numInCircle;
  final int numTotalRandom;

  AppState(
      {this.randomPoints = const[],
        this.numInCircle = 0,
        this.numTotalRandom = 0});
}

// The estimator only ever adds new random points or clears all present ones
enum Actions {
  AddRandomPoint,
  ClearPointGraph
}

AppState estimatorReducer(AppState state, dynamic action) {
  if (action == Actions.AddRandomPoint) {
    RandomPoint newPoint = new RandomPoint();
    List<RandomPoint> newPointList =
      new List<RandomPoint>
          .from(state.randomPoints)
        ..add(newPoint);

    return AppState(
      randomPoints: newPointList,
      numInCircle: (newPoint.isInCircle())
          ? state.numInCircle + 1 : state.numInCircle,
      numTotalRandom: state.numTotalRandom + 1
    );
  } else if (action == Actions.ClearPointGraph){
    return AppState(
      randomPoints: const[],
      numInCircle: 0,
      numTotalRandom: 0
    );
  } else {
    return state;
  }
}

void main() {
  final store = new Store<AppState>(
      estimatorReducer,
      initialState: AppState()
  );

  runApp(RandomPiEstimator(title: 'Random Pi Estimation', store: store));
}

class RandomPiEstimator extends StatelessWidget {
  final Store<AppState> store;
  final String title;

  RandomPiEstimator({Key key, this.store, this.title}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return new StoreProvider<AppState>(
        store: store,
        child: MaterialApp(
          title: title,
          theme: ThemeData(
            primarySwatch: Colors.blue,
          ),
          home: HomePage(title: 'Random Pi Estimation'),
        )
    );
  }
}

class HomePage extends StatefulWidget {
  HomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  double pointsPerMinute = 0;
  Timer runningTimer;

  @override
  void dispose() {
    runningTimer?.cancel();
    super.dispose();
  }

  void _newDuration(double newDuration, Function addFunction) {
    setState(() {pointsPerMinute = newDuration;});
    if (pointsPerMinute == 0) {
      runningTimer?.cancel();
    } else {
      runningTimer = Timer.periodic(
          Duration(milliseconds: ((60*1000) ~/ pointsPerMinute)),
              (Timer t) {
                if (runningTimer.isActive) {
                  addFunction();
                }});
    }
  }

  StoreConnector<AppState, AppState> generatePiEstimation() {
    return new StoreConnector<AppState, AppState>(
        converter: (store) => store.state,
        builder: (context, state) =>
            new SizedBox(
              width: MediaQuery.of(context).size.width * 0.8,
              child: Text(
                "π ≈ ${((state.numInCircle / state.numTotalRandom) * 4.0)}",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 50,),
                overflow: TextOverflow.fade,
                maxLines: 1,
                softWrap: false,
                textAlign: TextAlign.center,
              ),
            ),
    );
  }

  StoreConnector<AppState, AppState> generateTauEstimation() {
    return new StoreConnector<AppState, AppState>(
        converter: (store) => store.state,
        builder: (context, state) =>
        new SizedBox(
          width: MediaQuery.of(context).size.width * 0.8,
          child: Text(
            "𝜏 ≈ ${((state.numInCircle / state.numTotalRandom) * 4.0 * 2.0)}",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 50,),
            overflow: TextOverflow.fade,
            maxLines: 1,
            softWrap: false,
            textAlign: TextAlign.center,
          ),
        ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Column(
        children: <Widget>[
          new CircleGraph(),
          new Row(
            children: <Widget>[
              new Text("(# in the circle) / (total #) * 100"),
              new Text(" = "),
              new Text("(percentage in the circle)"),
            ],
            mainAxisAlignment: MainAxisAlignment.center,
          ),
          new StoreConnector<AppState, AppState>(
              converter: (store) => store.state,
              builder: (context, state) =>
                  Text("\n(${state.numInCircle} / ${state.numTotalRandom})"
                      + " * 100 = "
                      + "${state.numInCircle / state.numTotalRandom * 100}%"
                      + "\n")
          ),
          generatePiEstimation(),
          new StoreConnector<AppState, VoidCallback>(
              converter: (store) {
                return () => store.dispatch( Actions.AddRandomPoint );
              },
              builder: (context, callback) =>
                  Column(
                    children: <Widget>[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          RaisedButton(
                            child: Text("Add 1"),
                            onPressed: () => setState(() {callback();}),
                          ),
                          RaisedButton(
                            child: Text("Add 10"),
                            onPressed: () {for(int i=0; i<10; i++){
                              setState(() {callback();});
                            }},
                          ),
                          RaisedButton(
                            child: Text("Add 100"),
                            onPressed: () {for(int i=0; i<100; i++){
                              setState(() {callback();});
                            }},
                          ),
                          new StoreConnector<AppState, VoidCallback>(
                            converter: (store) {
                              return () => store.dispatch( Actions.ClearPointGraph );
                            },
                            builder: (context, callback) =>
                                RaisedButton(
                                  child: Text("Clear"),
                                  onPressed: () => setState(() {callback();}),
                                ),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Text("Add ${pointsPerMinute.toInt()} a minute:"),
                          Slider(
                            value: pointsPerMinute,
                            min: 0,
                            max: 100,
                            divisions: 100,
                            onChanged: (double value) =>
                                _newDuration(value, callback),
                          ),
                          RaisedButton(
                            child: Text("Stop"),
                            onPressed: () => setState(() {
                              _newDuration(0, callback);
                            }),
                          )
                        ],
                      ),
                    ],
                  )
          ),
        ],
      ),
    );
  }
}

class RandomPoint extends StatelessWidget {
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

  Color _getRandomColor() {
    return Color((Random.secure().nextDouble() * 0xFFFFFF).toInt() << 0)
        .withOpacity(1.0);
  }

  @override
  Widget build(BuildContext context) {
    return new Container(
      margin: EdgeInsets.only(
        left: (0.5 + (getX() / 2)) * graphWidth,
        top:  (0.5 + (getY() / 2)) * graphWidth,),
      width: 0.05 * graphWidth,
      height: 0.05 * graphWidth,
      decoration: new BoxDecoration(
        shape: BoxShape.circle,
        color: _getRandomColor(),
        border: Border.all(width: 0),
      ),
    );
  }
}

class CircleGraph extends StatefulWidget {
  const CircleGraph();

  final double width = 0;

  @override
  CircleGraphState createState() => CircleGraphState();
}

class CircleGraphState extends State<CircleGraph> {
  @override
  Widget build(BuildContext context) {
    graphWidth = MediaQuery.of(context).size.width;

    return new StoreConnector<AppState, List<RandomPoint>>(
        converter: (store) => store.state.randomPoints,
        builder: (context, randomPoints) =>
            AspectRatio(
                aspectRatio: 1.0,
                child: new Container(
                  margin: EdgeInsets.all(0.1 * graphWidth),
                  child: Stack(
                    children: <Widget>[
                      new Container(
                        width: 0.8 * graphWidth,
                        height: 0.8 * graphWidth,
                        decoration: new BoxDecoration(
                          shape: BoxShape.rectangle,
                          color: Colors.white,
                          border: Border.all(),
                          boxShadow: [
                            new BoxShadow(
                              offset: new Offset(0.0, 5.0),
                              blurRadius: 5.0,
                            )
                          ],
                        ),
                      ),
                    ]..addAll(randomPoints)
                      ..add(
                        new Container(
                          width: 0.8 * graphWidth,
                          height: 0.8 * graphWidth,
                          decoration: new BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.transparent,
                            border: Border.all(),
                          ),
                        ),
                      ),
                  ),
                )
            )
    );
  }
}
