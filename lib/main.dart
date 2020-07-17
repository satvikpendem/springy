import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';

import 'spring.dart';
import 'spring_simulation_container.dart';

void main() {
  WidgetsApp.debugAllowBannerOverride = false;
  runApp(App());
}

const SpringDescription springDescription = SpringDescription(
  mass: 1,
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
          body: Center(
            child: SpringSimulationContainer(
              spring: Spring(
                description: springDescription,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
