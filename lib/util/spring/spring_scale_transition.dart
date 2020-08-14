import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:functional_widget_annotation/functional_widget_annotation.dart';

import 'spring.dart';
import 'spring_animation_hook.dart';

part 'spring_scale_transition.g.dart';

/// Container that can use [SpringSimulation]s for [Transform]s
@hwidget
Widget springScaleTransition({
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

  final SpringAnimation springAnimation = useSpringAnimation();

  /// Scale must be at least 1, but clamping will stop the controller.value
  /// from progressing, causing the visual perception of jankiness
  final double scale = 1 + (springAnimation.controller.value * maxScaleFactor);

  return GestureDetector(
    onVerticalDragStart: (DragStartDetails details) {
      _onDragStart(details);
      springAnimation.run(springAnimation.intermediateValue, _spring.end);
    },
    onVerticalDragUpdate: _onDragUpdate,
    onVerticalDragEnd: (DragEndDetails details) {
      _onDragEnd(details);
      springAnimation.run(springAnimation.intermediateValue, _spring.start);
    },
    onVerticalDragCancel: () {
      _onDragCancel();
      springAnimation.run(springAnimation.intermediateValue, _spring.start);
    },
    child: Transform(
      transform: Matrix4.identity()..scale(scale),
      alignment: Alignment.center,
      child: child,
    ),
  );
}
