import 'package:flutter/material.dart';

import 'examples/spring_scale_example.dart';
import 'util/spring/spring_scale_transition.dart';

void main() {
  WidgetsApp.debugAllowBannerOverride = false;
  runApp(const App());
}

/// App start
class App extends StatelessWidget {
  /// Constructor
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
                  description: 'Test',
                ),
              ),
            ),
          ),
        ),
      );
}
