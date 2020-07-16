import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';

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
  static const double kInitialSize = 100;
  static const double kSizeChange = 20;
  static const double kFinalSize = kInitialSize + kSizeChange;

  bool isTapped = false;

  AnimationController controller;
  Animation<double> animation;
  ReverseAnimation reverseAnimation;
  CurvedAnimation curvedAnimation;

  static const SpringCurvePeriodic periodicCurve = SpringCurvePeriodic(
    amplitude: 0.2,
    wavelength: 11,
  );

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
      begin: kInitialSize,
      end: kFinalSize,
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
      initialValue: kInitialSize,
      finalValue: kFinalSize,
    );
  }

  void onTapUp(TapUpDetails details) {
    runAnimation(
      tapStatus: true,
      initialValue: kFinalSize,
      finalValue: kInitialSize,
    );
  }

  void onTapCancel() {
    runAnimation(
      tapStatus: true,
      initialValue: kFinalSize,
      finalValue: kInitialSize,
    );
  }

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTapDown: onTapDown,
        onTapUp: onTapUp,
        onTapCancel: onTapCancel,
        child: AnimatedBuilder(
          animation: animation,
          builder: (_, __) => Container(
            margin: const EdgeInsets.all(10),
            width: animation.value,
            height: animation.value,
            decoration: BoxDecoration(
              color: Colors.blue,
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
      );
}
