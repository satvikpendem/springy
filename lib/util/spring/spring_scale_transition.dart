import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';

import 'spring.dart';

/// Container that can use [SpringSimulation]s for [Transform]s
// ignore: must_be_immutable
class SpringScaleTransition extends StatefulWidget {
  /// If the [spring] is not specified, a default one will be made
  SpringScaleTransition({
    @required this.child,
    Spring spring,
    this.maxScaleFactor = 0.25,
    void Function(DragStartDetails) onDragStart,
    void Function(DragUpdateDetails) onDragUpdate,
    void Function(DragEndDetails) onDragEnd,
    void Function() onDragCancel,
    Key key,
  }) : super(key: key) {
    this.spring = spring ?? Spring();
    assert(this.spring.description.mass > 0, 'Mass must be greater than 0');

    /// If Drag GestureDetectorCallbacks are not specified, defaults are made
    this.onDragStart = onDragStart ?? (DragStartDetails _) {};
    this.onDragUpdate = onDragUpdate ?? (DragUpdateDetails _) {};
    this.onDragEnd = onDragEnd ?? (DragEndDetails _) {};
    this.onDragCancel = onDragCancel ?? () {};
  }

  /// The [Spring] to use for the [Transform]s. Cannot be final as we use null
  /// coalescing assignment in the constructor.
  Spring spring;

  /// [Widget] to create the transition for
  final Widget child;

  /// The maximum scale that the [child] should grow
  final double maxScaleFactor;

  void Function(DragStartDetails details) onDragStart;
  void Function(DragUpdateDetails details) onDragUpdate;
  void Function(DragEndDetails details) onDragEnd;
  void Function() onDragCancel;

  @override
  _SpringScaleTransitionState createState() => _SpringScaleTransitionState();
}

class _SpringScaleTransitionState extends State<SpringScaleTransition>
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
      /// The defaults are 1 and -1 for `upperBound` and `lowerBound`
      /// respectively, so the spring animation / will not be visible as it
      /// generally goes past 1 and -1. If the bounds remain at 1 and -1,
      /// therefore, the controller will simply stop animating the animated
      /// Widget past these bounds.
      upperBound: double.infinity,
      lowerBound: double.negativeInfinity,

      /// Controller automatically starts at lowerBound, which is negative
      /// infinity. Therefore, we must set the value to be 0 for the [Transform]s
      /// to render correctly in the [Container].
      value: 0,
    )..addListener(() {
        /// We must `setState` in order to update the animation
        /// and also to record the intermediate value.
        /// This will rebuild the whole UI which is not ideal but is usable.
        setState(() {
          /// The intermediate value is used to figure out where the animation
          /// will start and end on the next iteration if it's stopped in the
          /// middle of the animation. For example, if the user cancels the
          /// [Gesture], then we must know where the animation stopped in order
          /// to interpolate from the `intermediateValue` to the new value.
          intermediateValue = controller.value;
        });
      });
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

  // void onTapUp(TapUpDetails details) =>
  //     runAnimation(intermediateValue, widget.spring.start);

  // void onTapDown(TapDownDetails details) =>
  //     runAnimation(intermediateValue, widget.spring.end);

  // void onTapCancel() => runAnimation(intermediateValue, widget.spring.end);

  @override
  Widget build(BuildContext context) {
    /// Scale must be at least 1, but clamping will stop the controller.value
    /// from progressing, causing the visual perception of jankiness
    final double scale = 1 + (controller.value * widget.maxScaleFactor);

    return GestureDetector(
      // onTapDown: onTapDown,
      // onTapUp: onTapUp,
      // onTapCancel: onTapCancel,
      onVerticalDragStart: (DragStartDetails details) {
        widget.onDragStart(details);
        runAnimation(intermediateValue, widget.spring.end);
      },
      onVerticalDragUpdate: widget.onDragUpdate,
      onVerticalDragEnd: (DragEndDetails details) {
        widget.onDragEnd(details);
        runAnimation(intermediateValue, widget.spring.start);
      },
      onVerticalDragCancel: () {
        widget.onDragCancel();
        runAnimation(intermediateValue, widget.spring.start);
      },
      child: Transform(
        transform: Matrix4.identity()..scale(scale),
        alignment: Alignment.center,
        child: widget.child,
      ),
    );
  }
}
