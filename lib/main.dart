import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';

import './util/spring_curve.dart';

void main() {
  WidgetsApp.debugAllowBannerOverride = false;
  runApp(MyApp());
}

const Duration kDefaultDuration = Duration(milliseconds: 1250);

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

class Box extends StatefulWidget {
  @override
  _BoxState createState() => _BoxState();
}

class _BoxState extends State<Box> with TickerProviderStateMixin {
  static const double kInitialSize = 100;
  static const double kSizeChange = 20;
  static const double kFinalSize = kInitialSize + kSizeChange;

  static SpringCurve springCurve = SpringCurve(
    spring: const SpringDescription(
      mass: 30,
      stiffness: 10,
      damping: 1,
    ),
  );

  bool isTapped = false;

  AnimationController controller;
  Animation<double> animation;

  @override
  void initState() {
    super.initState();
    controller = AnimationController(
      vsync: this,
      duration: kDefaultDuration,
    );

    final CurvedAnimation curve = CurvedAnimation(
      parent: controller,
      curve: springCurve,
    );

    animation = Tween<double>(
      begin: kInitialSize,
      end: kFinalSize,
    ).animate(curve);
  }

  void runAnimation(bool tapStatus, AnimationController controller) =>
      tapStatus ? controller.reverse() : controller.forward();

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void onTapDown(TapDownDetails details) {
    setState(() {
      isTapped = true;
    });
    controller.forward();
  }

  void onTapUp(TapUpDetails details) {
    setState(() {
      isTapped = false;
    });
    controller.reverse();
  }

  void onTapCancel() {
    setState(() {
      isTapped = false;
    });
    controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: onTapDown,
      onTapUp: onTapUp,
      onTapCancel: onTapCancel,
      // onTap: () {
      //   setState(() {
      //     isTapped = !isTapped;
      //     runAnimation(isTapped, controller);
      //   });
      // },
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
}
