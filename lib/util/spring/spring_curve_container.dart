import 'package:flutter/material.dart';

import 'spring_curve.dart';

const Duration kDefaultDuration = Duration(milliseconds: 500);

/// Container that uses a [SpringCurve] for animations
class SpringCurveContainer extends StatefulWidget {
  /// Initializes a [SpringPeriodicCurve] by default if no [springCurve] is passed in
  SpringCurveContainer({
    this.springCurve,
  }) {
    springCurve ??= SpringPeriodicCurve();
  }

  /// The [SpringCurve] to use for the animations in the [Container]
  SpringCurve springCurve;

  @override
  _SpringCurveContainerState createState() => _SpringCurveContainerState();
}

class _SpringCurveContainerState extends State<SpringCurveContainer>
    with TickerProviderStateMixin {
  static const double kInitialScale = 1;
  static const double kScaleChange = 1;
  static const double kFinalScale = kInitialScale + kScaleChange;

  bool isTapped = false;

  AnimationController controller;
  Animation<double> animation;
  CurvedAnimation curvedAnimation;

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
      curve: widget.springCurve,
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

      /// change [curvedAnimation] as the widget may have been rebuilt, so a new `curve` will need to be passed in
      curvedAnimation = CurvedAnimation(
        parent: controller,
        curve: widget.springCurve,
      );

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

  void onTapDown(TapDownDetails details) => runAnimation(
        tapStatus: true,
        initialValue: kInitialScale,
        finalValue: kFinalScale,
      );

  void onTapUp(TapUpDetails details) => runAnimation(
        tapStatus: false,
        initialValue: kFinalScale,
        finalValue: kInitialScale,
      );

  void onTapCancel() => runAnimation(
        tapStatus: false,
        initialValue: kFinalScale,
        finalValue: kInitialScale,
      );

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
                color: Colors.red,
                borderRadius: BorderRadius.circular(10),
              ),
              padding: const EdgeInsets.all(10),
              alignment: Alignment.center,
              child: const Text(
                'Spring Curve',
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
