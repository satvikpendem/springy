import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';

import 'spring.dart';

/// Container that can use [SpringSimulation]s for [Transform]s
// ignore: must_be_immutable
class SpringScaleTransition extends StatefulWidget {
  /// If the [spring] is not specified, a default one will be made
  SpringScaleTransition({
    @required this.child,
    this.spring,
    this.maxScaleFactor = 0.25,
    this.onDragStart,
    this.onDragUpdate,
    this.onDragEnd,
    this.onDragCancel,
    Key key,
  }) : super(key: key) {
    if (spring != null) {
      assert(spring.description.mass > 0, 'Mass must be greater than 0');
    }
    spring ??= Spring(
      description: const SpringDescription(
        mass: 3,
        stiffness: 200,
        damping: 3,
      ),
    );

    /// If Drag GestureDetectorCallbacks are not specified, defaults are made
    onDragStart ??= (DragStartDetails _) {};
    onDragUpdate ??= (DragUpdateDetails _) {};
    onDragEnd ??= (DragEndDetails _) {};
    onDragCancel ??= () {};
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

    /// Controller automatically starts at lowerBound, which is negative
    /// infinity. Therefore, we must set the value to be 0 for the [Transform]s
    /// to render correctly in the [Container] / / We also can't cascade setting
    /// the controller's value to 0 because the controller is still null and we
    /// will get an error on the command line, even if it works fine in the UI.
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
