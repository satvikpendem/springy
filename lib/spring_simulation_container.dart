import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';

import 'spring.dart';

/// Container that can use [SpringSimulation]s for [Transform]s
class SpringSimulationContainer extends StatefulWidget {
  /// Basic constructor with a [Key]
  const SpringSimulationContainer({
    @required this.spring,
    Key key,
  }) : super(key: key);

  /// The [Spring] to use for the [Transform]s
  final Spring spring;

  @override
  _SpringSimulationContainerState createState() =>
      _SpringSimulationContainerState();
}

class _SpringSimulationContainerState extends State<SpringSimulationContainer>
    with TickerProviderStateMixin {
  AnimationController controller;

  /// Used to calculate intermediate values for the next animation run
  /// when the current animation is canceled or otherwise changed
  double intermediateValue = 0;

  SpringSimulation simulation;

  @override
  void initState() {
    super.initState();
    simulation = widget.spring.simulation;

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
          /// The intermediate value is used to figure out where the animation will start and end on the next iteration
          /// if it's stopped in the middle of the animation. For example, if the user cancels the [Gesture],
          /// then we must know where the animation stopped in order to interpolate from the `intermediateValue`
          /// to the new value.
          intermediateValue = controller.value;
        });
      });

    /// Controller automatically starts at lowerBound, which is negative infinity.
    /// Therefore, we must set the value to be 0 for the [Transform]s to render correctly in the [Container]
    ///
    /// We also can't cascade setting the controller's value to 0 because the controller is still null
    /// and we will get an error on the command line, even though it works fine in the UI.
    // ignore: cascade_invocations
    controller.value = 0;
  }

  void runAnimation(double start, double end) {
    simulation = SpringSimulation(
      widget.spring.description,
      start,
      end,
      widget.spring.velocity,
    );
    controller.animateWith(simulation);
  }

  void onTapUp(TapUpDetails details) =>
      runAnimation(intermediateValue, widget.spring.start);

  void onTapDown(TapDownDetails details) =>
      runAnimation(intermediateValue, widget.spring.end);

  void onTapCancel() => runAnimation(intermediateValue, widget.spring.end);

  @override
  Widget build(BuildContext context) {
    final double scale = 1 + controller.value;

    return GestureDetector(
      onTapDown: onTapDown,
      onTapUp: onTapUp,
      onTapCancel: onTapCancel,
      child: Transform(
        transform: Matrix4.identity()
          ..scale(
            scale,
            scale,
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
            'Spring Simulation',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
      ),
    );
  }
}
