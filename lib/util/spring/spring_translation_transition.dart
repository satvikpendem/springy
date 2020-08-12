import 'package:artemis/examples/spring_scale_example.dart';
import 'package:artemis/util/spring/spring_scale_transition.dart';
import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';

void main(List<String> args) {
  runApp(App());
}

const double kMaxSlide = 1000;

const SpringDescription springDescription = SpringDescription(
  mass: 3,
  stiffness: 200,
  damping: 3,
);

class App extends StatelessWidget {
  const App({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) => MaterialApp(
        theme: ThemeData(
          primarySwatch: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        home: SafeArea(
          child: Scaffold(
            body: Center(
              child: SpringScaleTransition(
                child: const SpringBox(
                  description: 'Box',
                ),
              ),
            ),
          ),
        ),
      );
}
