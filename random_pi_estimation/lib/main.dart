import 'package:flutter/material.dart';
import 'package:redux/redux.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'dart:math';

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
  StoreConnector<AppState, AppState> generatePiEstimation() {
    return new StoreConnector<AppState, AppState>(
        converter: (store) => store.state,
        builder: (context, state) =>
            Text(((state.numInCircle / state.numTotalRandom) * 4.0).toString())
    );
  }

  StoreConnector<AppState, AppState> generateTauEstimation() {
    return new StoreConnector<AppState, AppState>(
        converter: (store) => store.state,
        builder: (context, state) =>
            Text(((state.numInCircle / state.numTotalRandom) * 4.0 * 2.0).toString())
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          children: <Widget>[
            new CircleGraph(),
            new StoreConnector<AppState, AppState>(
                converter: (store) => store.state,
                builder: (context, state) =>
                    Text("${state.numInCircle} / ${state.numTotalRandom}"
                        + " = ${state.numInCircle / state.numTotalRandom}")
            ),
            generatePiEstimation(),
          ],
        ),
      ),
      floatingActionButton: new StoreConnector<AppState, VoidCallback>(
        converter: (store) {
          return () => store.dispatch(Actions.AddRandomPoint);
        },
        builder: (context, callback) =>
            FloatingActionButton(
              onPressed: () => setState(() {callback();}),
              tooltip: 'Add new random point',
              child: Icon(Icons.add),
          )
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

  double _getGraphLeftMargin() {
    return (0.5 + (getX() / 2)) * graphWidth;
  }

  double _getGraphTopMargin() {
    return (0.5 + (getY() / 2)) * graphWidth;
  }

  Color _getRandomColor() {
    return Color((Random.secure().nextDouble() * 0xFFFFFF).toInt() << 0)
        .withOpacity(1.0);
  }

  @override
  Widget build(BuildContext context) {
    return new Container(
      margin: EdgeInsets.only(
        left: _getGraphLeftMargin(),
        top: _getGraphTopMargin(),),
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
                      new Container(
                        width: 0.8 * graphWidth,
                        height: 0.8 * graphWidth,
                        decoration: new BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                          border: Border.all(),
                        ),
                      ),
                    ]..addAll(randomPoints),
                  ),
                )
            )
    );
  }
}
