import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';

void main() {
  WidgetsApp.debugAllowBannerOverride = false;
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
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
            child: Box(),
          ),
        ),
      ),
    );
  }
}

/// Basic container
class Box extends StatefulWidget {
  @override
  _BoxState createState() => _BoxState();
}

class _BoxState extends State<Box> with TickerProviderStateMixin {
  AnimationController controller;

  double intermediateValue = 0;

  SpringDescription springDescription = const SpringDescription(
    mass: 1,
    stiffness: 100,
    damping: 1,
  );

  SpringSimulation simulation;
  @override
  void initState() {
    super.initState();
    simulation = SpringSimulation(
      springDescription,
      0,
      1,
      0,
    );

    controller = AnimationController(
      vsync: this,

      /// Set the bounds to be infinite both positively and negatively.
      /// The defaults are 1 and -1 for `upperBound` and `lowerBound` respectively, so the spring animation
      /// will not be visible as it generally goes past 1 and -1. If the bounds remain at 1 and -1, therefore,
      /// the controller will simply stop animating the animated Widget past these bounds.
      upperBound: double.infinity,
      lowerBound: double.negativeInfinity,
    )..addListener(() {
        /// We must `setState` in order to update the animation and also to record the intermediate value.
        /// This will rebuild the whole UI which is not ideal but is usable.
        setState(() {
          /// The intermediate value is used to figure out where the animation starts and ends
          /// if we are in the middle of the animation. For example, if the user cancels the [Gesture],
          /// then we must know where the animation stopped in order to interpolate from the `intermediateValue`
          /// to the new value.
          intermediateValue = controller.value;
        });
      });

    /// Controller automatically starts at lowerBound, which is negative infinity.
    /// Therefore, we must set the value to be 0 for the `size` property to render correctly in the [Container]
    ///
    /// We also can't cascade setting the controller's value to 0 because the controller is still null
    /// and we will get an error on the command line, even though it works fine in the UI.
    // ignore: cascade_invocations
    controller.value = 0;
  }

  void onTapUp(TapUpDetails details) {
    simulation = SpringSimulation(
      springDescription,
      intermediateValue,
      0,
      0,
    );
    controller.animateWith(simulation);
  }

  void onTapDown(TapDownDetails details) {
    simulation = SpringSimulation(
      springDescription,
      intermediateValue,
      1,
      0,
    );
    controller.animateWith(simulation);
  }

  @override
  Widget build(BuildContext context) {
    final double size = 100 + controller.value * 10;

    return GestureDetector(
      onTapDown: onTapDown,
      onTapUp: onTapUp,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: Colors.blue,
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }
}
