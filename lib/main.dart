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
              Center(
                child: SpringSimulationContainer(),
              ),
              Center(
                child: SpringCurveContainer(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
