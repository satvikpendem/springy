import 'package:artemis/util/spring/spring_curve_container.dart';
import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';

import 'util/spring/spring.dart';
import 'util/spring/spring_simulation_container.dart';

void main() {
  WidgetsApp.debugAllowBannerOverride = false;
  runApp(App());
}

/// [SpringDescription] used for [SpringSimulationContainer]
const SpringDescription springDescription = SpringDescription(
  mass: 5,
  stiffness: 100,
  damping: 10,
);

/// Main app to run
class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: SafeArea(
        child: Scaffold(
          body: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              SimulationDetails(),
              CurveDetails(),
            ],
          ),
        ),
      ),
    );
  }
}

class CurveDetails extends StatelessWidget {
  const CurveDetails({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Center(
          child: SpringCurveContainer(),
        ),
      ],
    );
  }
}

class SimulationDetails extends StatefulWidget {
  const SimulationDetails({
    Key key,
  }) : super(key: key);

  @override
  _SimulationDetailsState createState() => _SimulationDetailsState();
}

class _SimulationDetailsState extends State<SimulationDetails> {
  double mass = 5, stiffness = 100, damping = 0.5;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Center(
          child: SpringSimulationContainer(
            spring: Spring(
              description: SpringDescription(
                mass: mass,
                stiffness: stiffness,
                damping: damping,
              ),
            ),
          ),
        ),
        Column(
          children: [
            Slider(
              label: 'Mass: $mass',
              min: 1,
              max: 20,
              value: mass,
              onChanged: (double value) => setState(() {
                mass = value;
              }),
              divisions: 19,
            ),
            Slider(
              label: 'Stiffness: $stiffness',
              min: 1,
              max: 500,
              value: stiffness,
              onChanged: (double value) => setState(() {
                stiffness = value;
              }),
              divisions: 499,
            ),
            Slider(
              label: 'Damping: $damping',
              min: 0,
              max: 10,
              value: damping,
              onChanged: (double value) => setState(() {
                damping = value;
              }),
              divisions: 20,
            ),
          ],
        ),
      ],
    );
  }
}
