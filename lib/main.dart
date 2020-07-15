import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';

void main() {
  WidgetsApp.debugAllowBannerOverride = false;
  runApp(MyApp());
}

const Duration kDefaultDuration = Duration(milliseconds: 250);

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
  static const double kSizeChange = 200;
  static const double kFinalSize = kInitialSize + kSizeChange;

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
    animation = controller.drive(
      Tween<double>(
        begin: kInitialSize,
        end: kFinalSize,
      ),
    );
  }

  void runScale(double initialSize, double finalSize) {
    animation = controller.drive(
      Tween<double>(
        begin: initialSize,
        end: finalSize,
      ),
    );

    controller.animateWith(
      SpringSimulation(
        const SpringDescription(
          mass: 20,
          stiffness: 2,
          damping: 1,
        ),
        0,
        1,
        0,
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }

  void onTapDown(TapDownDetails details) {
    setState(() {
      isTapped = true;
    });
    runScale(kInitialSize, kFinalSize);
    // controller.forward();
  }

  void onTapUp(TapUpDetails details) {
    setState(() {
      isTapped = false;
    });
    runScale(kFinalSize, kInitialSize);
    // controller.reverse();
  }

  void onTapCancel() {
    setState(() {
      isTapped = false;
    });
    runScale(kFinalSize, kInitialSize);
    // controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
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
}
