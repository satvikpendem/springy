import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';

import 'util/spring/spring.dart';
import 'util/spring/spring_curve.dart';
import 'util/spring/spring_curve_container.dart';
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

/// App start
class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) => MaterialApp(
        theme: ThemeData(
          primarySwatch: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        home: SafeArea(
          child: Scaffold(
            body: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: const <Widget>[
                SimulationDetails(),
                CurveDetails(),
              ],
            ),
          ),
        ),
      );
}

class SimulationDetails extends StatefulWidget {
  const SimulationDetails({
    Key key,
  }) : super(key: key);

  @override
  _SimulationDetailsState createState() => _SimulationDetailsState();
}

class _SimulationDetailsState extends State<SimulationDetails> {
  double mass = 5, stiffness = 50, damping = 0.5;

  List<Widget> get children => <Widget>[
        SpringSimulationContainer(
          spring: Spring(
            description: SpringDescription(
              mass: mass,
              stiffness: stiffness,
              damping: damping,
            ),
          ),
        ),
        Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  const Text('Mass'),
                  Slider(
                    label: '$mass',
                    min: 1,
                    max: 20,
                    value: mass,
                    onChanged: (double value) {
                      setState(() {
                        mass = value;
                      });
                    },
                    divisions: 19,
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  const Text('Stiffness'),
                  Slider(
                    label: 'Stiffness: $stiffness',
                    max: 500,
                    value: stiffness,
                    onChanged: (double value) {
                      setState(() {
                        stiffness = value;
                      });
                    },
                    divisions: 500,
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  const Text('Damping'),
                  Slider(
                    label: 'Damping: $damping',
                    max: 10,
                    value: damping,
                    onChanged: (double value) {
                      setState(() {
                        damping = value;
                      });
                    },
                    divisions: 20,
                  ),
                ],
              ),
            ),
          ],
        ),
      ];

  @override
  Widget build(BuildContext context) =>
      MediaQuery.of(context).orientation == Orientation.landscape
          ? Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: children,
            )
          : Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: children,
            );
}

class CurveDetails extends StatefulWidget {
  const CurveDetails({
    Key key,
  }) : super(key: key);

  @override
  _CurveDetailsState createState() => _CurveDetailsState();
}

class _CurveDetailsState extends State<CurveDetails> {
  double amplitude = 0.2, wavelength = 11;

  List<Widget> get children => <Widget>[
        SpringCurveContainer(
          springCurve: SpringPeriodicCurve(
            amplitude: amplitude,
            wavelength: wavelength,
          ),
        ),
        Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  const Text('Amplitude'),
                  Slider(
                    activeColor: Colors.red,
                    inactiveColor: Colors.red.withOpacity(0.24),
                    label: 'Amplitude: $amplitude',
                    min: -10,
                    max: 10,
                    value: amplitude,
                    onChanged: (double value) {
                      setState(() {
                        amplitude = value;
                      });
                    },
                    divisions: 100,
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  const Text('Wavelength'),
                  Slider(
                    activeColor: Colors.red,
                    inactiveColor: Colors.red.withOpacity(0.24),
                    label: 'Wavelength: $wavelength',
                    max: 100,
                    value: wavelength,
                    onChanged: (double value) {
                      setState(() {
                        wavelength = value;
                      });
                    },
                    divisions: 20,
                  ),
                ],
              ),
            ),
          ],
        )
      ];

  @override
  Widget build(BuildContext context) =>
      MediaQuery.of(context).orientation == Orientation.landscape
          ? Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: children,
            )
          : Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: children,
            );
}
