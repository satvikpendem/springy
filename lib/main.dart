import 'package:flutter/material.dart';

import './util/spring_curve.dart';

void main() {
  WidgetsApp.debugAllowBannerOverride = false;
  runApp(MyApp());
}

const Duration kDefaultDuration = Duration(milliseconds: 500);

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
  static const double kInitialScale = 1;
  static const double kScaleChange = 1;
  static const double kFinalScale = kInitialScale + kScaleChange;

  bool isTapped = false;

  AnimationController controller;
  Animation<double> animation;
  CurvedAnimation curvedAnimation;

  static const SpringCurvePeriodic periodicCurve = SpringCurvePeriodic();

  @override
  void initState() {
    super.initState();

    /// Set up the [controller]
    controller = AnimationController(
      vsync: this,
      duration: kDefaultDuration,
    );

    /// Prepare the [curvedAnimation] with the `periodicCurve`
    curvedAnimation = CurvedAnimation(
      parent: controller,
      curve: periodicCurve,
    );

    /// Use the [curvedAnimation] to create the [animation]
    animation = Tween<double>(
      begin: kInitialScale,
      end: kFinalScale,
    ).animate(curvedAnimation);
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  /// Changes the [isTapped] value and changes the [animation] to accept new `begin` and `end` values
  void runAnimation({
    bool tapStatus,
    double initialValue,
    double finalValue,
  }) {
    setState(() {
      isTapped = tapStatus;

      animation = Tween<double>(
        begin: initialValue,
        end: finalValue,
      ).animate(curvedAnimation);
    });

    /// Reset the controller so that the controller thinks it will still need to drive forward
    controller
      ..reset()
      ..forward();
  }

  void onTapDown(TapDownDetails details) {
    runAnimation(
      tapStatus: true,
      initialValue: kInitialScale,
      finalValue: kFinalScale,
    );
  }

  void onTapUp(TapUpDetails details) {
    runAnimation(
      tapStatus: true,
      initialValue: kFinalScale,
      finalValue: kInitialScale,
    );
  }

  void onTapCancel() {
    runAnimation(
      tapStatus: true,
      initialValue: kFinalScale,
      finalValue: kInitialScale,
    );
  }

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTapDown: onTapDown,
        onTapUp: onTapUp,
        onTapCancel: onTapCancel,
        child: AnimatedBuilder(
          animation: animation,
          builder: (_, __) => Transform(
            transform: Matrix4.identity()
              ..scale(
                animation.value,
                animation.value,
              ),
            alignment: Alignment.center,
            child: Container(
              margin: const EdgeInsets.all(10),
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: Colors.blue,
                borderRadius: BorderRadius.circular(10),
              ),
              padding: const EdgeInsets.all(10),
              alignment: Alignment.center,
              child: const Text(
                'Task 1',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ),
        ),
      );
}
