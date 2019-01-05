import 'package:flutter/material.dart';
import 'package:redux/redux.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'dart:math';

@immutable
class AppState {
  final List<RandomPoint> randomPoints;
  final CircleGraph graph;
  final int numInCircle;

  AppState(
      {this.randomPoints = const[],
        this.graph = const CircleGraph(),
        this.numInCircle = 0});
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
      graph: state.graph,
      numInCircle: (newPoint.isInCircle())
          ? state.numInCircle + 1 : state.numInCircle,
    );
  } else if (action == Actions.ClearPointGraph){
    return AppState(
      randomPoints: const[],
      graph: const CircleGraph(),
      numInCircle: 0,
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
            Text(((state.numInCircle / state.randomPoints.length) * 4.0).toString())
    );
  }

  StoreConnector<AppState, AppState> generateTauEstimation() {
    return new StoreConnector<AppState, AppState>(
        converter: (store) => store.state,
        builder: (context, state) =>
            Text(((state.numInCircle / state.randomPoints.length) * 4.0 * 2.0).toString())
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
            new StoreConnector<AppState, CircleGraph>(
              converter: (store) => store.state.graph,
                builder: (context, graph) => graph
            ),
            new StoreConnector<AppState, AppState>(
                converter: (store) => store.state,
                builder: (context, state) =>
                    Text("${state.numInCircle} / ${state.randomPoints.length}"
                        + " = ${state.numInCircle / state.randomPoints.length}")
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

  @override
  Widget build(BuildContext context) {
    return new Text(isInCircle().toString() + " " + randomPoint.toString());
  }
}

class CircleGraph extends StatefulWidget {
  const CircleGraph();

  @override
  CircleGraphState createState() => CircleGraphState();
}

class CircleGraphState extends State<CircleGraph> {
  List<Widget> plottedPoints = <Widget>[];

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;

    return new AspectRatio(
      aspectRatio: 1.0,
      child: new Container(
        margin: EdgeInsets.all(0.1 * width),
        child: Stack(
          children: <Widget>[
            new Container(
              width: 0.8 * width,
              height: 0.8 * width,
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
              width: 0.8 * width,
              height: 0.8 * width,
              decoration: new BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
                border: Border.all(),
              ),
            ),
          ]..addAll(plottedPoints),
        ),
      )
    );
  }
}
