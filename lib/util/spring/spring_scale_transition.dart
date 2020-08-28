import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:functional_widget_annotation/functional_widget_annotation.dart';

import 'spring.dart';
import 'spring_animation_hook.dart';

part 'spring_scale_transition.g.dart';

/// Container that can use [SpringSimulation]s for [Transform]s
///
/// [spring]: An optional [Spring] can be passed in
/// [initialValue]: Value to start the scale at, generally set to 1
/// [finalValue]: Value to finish scaling at. This can be less than the [initialValue] if desired
/// [child]: The child to scale
///
/// The gesture functions can be passed in for whichever gestures are desired to have the scale property on
@hwidget
Widget springScaleTransition({
  @required Widget child,
  Spring spring,
  double initialValue = 1,
  double finalValue = 1.25,
  void Function(TapDownDetails) onTapDown,
  void Function(TapUpDetails) onTapUp,
  void Function() onTapCancel,
  void Function(DragStartDetails) onDragStart,
  void Function(DragUpdateDetails) onDragUpdate,
  void Function(DragEndDetails) onDragEnd,
  void Function() onDragCancel,
}) {
  /// Initialize [spring] to a default [Spring] if not provided
  spring ??= Spring();
  assert(spring.description.mass > 0, 'Mass must be greater than 0');

  /// The scale value to keep track of, starting at [initialValue]
  final ValueNotifier<double> scale = useState<double>(initialValue);

  return GestureDetector(
    onTapDown: (TapDownDetails details) {
      (onTapDown ??= (TapDownDetails _) {})(details);
      scale.value = finalValue;
    },
    onTapUp: (TapUpDetails details) {
      (onTapUp ??= (TapUpDetails _) {})(details);
      scale.value = initialValue;
    },
    onTapCancel: () {
      (onTapCancel ??= () {})();
      scale.value = initialValue;
    },
    onVerticalDragStart: (DragStartDetails details) {
      (onDragStart ?? (DragStartDetails _) {})(details);
      scale.value = finalValue;
    },
    onVerticalDragUpdate: (DragUpdateDetails details) {
      (onDragUpdate ?? (DragUpdateDetails _) {})(details);
      scale.value = finalValue;
    },
    onVerticalDragEnd: (DragEndDetails details) {
      (onDragEnd ?? (DragEndDetails _) {})(details);
      scale.value = initialValue;
    },
    onVerticalDragCancel: () {
      (onDragCancel ?? () {})();
      scale.value = initialValue;
    },
    child: _SpringScale(
      scale: scale.value,
      child: child,
    ),
  );

  /// If Drag GestureDetectorCallbacks are not specified, defaults are made
  // TODO(satvikpendem): Remove duplicate functions
  // final void Function(DragStartDetails p1) _onDragStart =
  //     onDragStart ?? (DragStartDetails _) {};
  // final void Function(DragUpdateDetails p1) _onDragUpdate =
  //     onDragUpdate ?? (DragUpdateDetails _) {};
  // final void Function(DragEndDetails p1) _onDragEnd =
  //     onDragEnd ?? (DragEndDetails _) {};
  // final void Function() _onDragCancel = onDragCancel ?? () {};

  // final AnimationController animationController = useSpringAnimation(value);

  // /// Scale must be at least 1, but clamping will stop the controller.value
  // /// from progressing, causing the visual perception of jankiness
  // // final double scale = 1 + (springAnimation.controller.value * maxScaleFactor);

  // return GestureDetector(
  //   onTapDown: (_) {
  //     // return springAnimation.run(springAnimation.intermediateValue, _spring.end);
  //     isActive.value = true;
  //   },
  //   onTapUp: (_) {
  //     // return springAnimation.run(springAnimation.intermediateValue, _spring.start);
  //     isActive.value = false;
  //   },
  //   onTapCancel: () {
  //     // return springAnimation.run(springAnimation.intermediateValue, _spring.start);
  //     isActive.value = false;
  //   },
  //   // onVerticalDragStart: (DragStartDetails details) {
  //   //   _onDragStart(details);
  //   //   springAnimation.run(springAnimation.intermediateValue, _spring.end);
  //   // },
  //   // onVerticalDragUpdate: _onDragUpdate,
  //   // onVerticalDragEnd: (DragEndDetails details) {
  //   //   _onDragEnd(details);
  //   //   springAnimation.run(springAnimation.intermediateValue, _spring.start);
  //   // },
  //   // onVerticalDragCancel: () {
  //   //   _onDragCancel();
  //   //   springAnimation.run(springAnimation.intermediateValue, _spring.start);
  //   // },
  //   child: Transform(
  //     transform: Matrix4.identity()..scale(animationController.value),
  //     alignment: Alignment.center,
  //     child: child,
  //   ),
  // );
}

@hwidget
Widget _springScale({
  @required double scale,
  @required Widget child,
  Alignment alignment = Alignment.center,
}) {
  final AnimationController animationController = useSpringAnimation(scale);

  return Transform(
    transform: Matrix4.identity()..scale(animationController.value),
    alignment: alignment,
    child: child,
  );
}
