import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:functional_widget_annotation/functional_widget_annotation.dart';

import 'spring.dart';
import 'spring_animation_hook.dart';

part 'spring_scale_hook.g.dart';

/// Container that can use [SpringSimulation]s for [Transform]s
// ignore: must_be_immutable
// class SpringScaleTransitionHook extends HookWidget {
//   /// If the [spring] is not specified, a default one will be made
//   SpringScaleTransitionHook({
//     @required this.child,
//     Spring spring,
//     this.maxScaleFactor = 0.25,
//     void Function(DragStartDetails) onDragStart,
//     void Function(DragUpdateDetails) onDragUpdate,
//     void Function(DragEndDetails) onDragEnd,
//     void Function() onDragCancel,
//     Key key,
//   }) : super(key: key) {
//     this.spring = spring ?? Spring();
//     assert(this.spring.description.mass > 0, 'Mass must be greater than 0');

//     /// If Drag GestureDetectorCallbacks are not specified, defaults are made
//     this.onDragStart = onDragStart ?? (DragStartDetails _) {};
//     this.onDragUpdate = onDragUpdate ?? (DragUpdateDetails _) {};
//     this.onDragEnd = onDragEnd ?? (DragEndDetails _) {};
//     this.onDragCancel = onDragCancel ?? () {};
//   }

//   /// The [Spring] to use for the [Transform]s. Cannot be final as we use null
//   /// coalescing assignment in the constructor.
//   Spring spring;

//   /// [Widget] to create the transition for
//   final Widget child;

//   /// The maximum scale that the [child] should grow
//   final double maxScaleFactor;

//   void Function(DragStartDetails details) onDragStart;
//   void Function(DragUpdateDetails details) onDragUpdate;
//   void Function(DragEndDetails details) onDragEnd;
//   void Function() onDragCancel;

//   @override
//   Widget build(BuildContext context) {
//     final SpringAnimationController springAnimationController =
//         useSpringAnimationControllerFunction();

//     /// Scale must be at least 1, but clamping will stop the controller.value
//     /// from progressing, causing the visual perception of jankiness
//     final double scale =
//         1 + (springAnimationController.controller.value * maxScaleFactor);

//     return GestureDetector(
//       // onTapDown: onTapDown,
//       // onTapUp: onTapUp,
//       // onTapCancel: onTapCancel,
//       onVerticalDragStart: (DragStartDetails details) {
//         onDragStart(details);
//         springAnimationController.run(
//             springAnimationController.intermediateValue, spring.end);
//       },
//       onVerticalDragUpdate: onDragUpdate,
//       onVerticalDragEnd: (DragEndDetails details) {
//         onDragEnd(details);
//         springAnimationController.run(
//             springAnimationController.intermediateValue, spring.start);
//       },
//       onVerticalDragCancel: () {
//         onDragCancel();
//         springAnimationController.run(
//             springAnimationController.intermediateValue, spring.start);
//       },
//       child: Transform(
//         transform: Matrix4.identity()..scale(scale),
//         alignment: Alignment.center,
//         child: child,
//       ),
//     );
//   }
// }

/// Container that can use [SpringSimulation]s for [Transform]s
@hwidget
Widget springScaleHook({
  @required Widget child,
  Spring spring,
  double maxScaleFactor = 0.25,
  void Function(DragStartDetails) onDragStart,
  void Function(DragUpdateDetails) onDragUpdate,
  void Function(DragEndDetails) onDragEnd,
  void Function() onDragCancel,
}) {
  final Spring _spring = spring ?? Spring();
  assert(_spring.description.mass > 0, 'Mass must be greater than 0');

  /// If Drag GestureDetectorCallbacks are not specified, defaults are made
  final void Function(DragStartDetails p1) _onDragStart =
      onDragStart ?? (DragStartDetails _) {};
  final void Function(DragUpdateDetails p1) _onDragUpdate =
      onDragUpdate ?? (DragUpdateDetails _) {};
  final void Function(DragEndDetails p1) _onDragEnd =
      onDragEnd ?? (DragEndDetails _) {};
  final void Function() _onDragCancel = onDragCancel ?? () {};

  final SpringAnimationController springAnimationController =
      useSpringAnimationControllerFunction();

  /// Scale must be at least 1, but clamping will stop the controller.value
  /// from progressing, causing the visual perception of jankiness
  final double scale =
      1 + (springAnimationController.controller.value * maxScaleFactor);

  return GestureDetector(
    onVerticalDragStart: (DragStartDetails details) {
      _onDragStart(details);
      springAnimationController.run(
          springAnimationController.intermediateValue, _spring.end);
    },
    onVerticalDragUpdate: _onDragUpdate,
    onVerticalDragEnd: (DragEndDetails details) {
      _onDragEnd(details);
      springAnimationController.run(
          springAnimationController.intermediateValue, _spring.start);
    },
    onVerticalDragCancel: () {
      _onDragCancel();
      springAnimationController.run(
          springAnimationController.intermediateValue, _spring.start);
    },
    child: Transform(
      transform: Matrix4.identity()..scale(scale),
      alignment: Alignment.center,
      child: child,
    ),
  );
}
