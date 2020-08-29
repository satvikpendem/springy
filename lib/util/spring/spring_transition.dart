import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:functional_widget_annotation/functional_widget_annotation.dart';

import 'spring.dart';
import 'use_spring_animation.dart';

part 'spring_transition.g.dart';

/// Container that can use [SpringSimulation]s for [Transform]s
///
/// [spring]: An optional [Spring] can be passed in
///
/// [scaleInitialValue]: Value to start the scale at, generally set to 1
///
/// [scaleFinalValue]: Value to finish scaling at. This can be less than the [scaleInitialValue] if desired
///
/// [child]: The child to scale
///
/// The gesture functions can be passed in for whichever gestures are desired to have the scale property on
@hwidget
Widget springTransition({
  @required Widget child,
  Spring spring,
  double scaleInitialValue = 1,
  double scaleFinalValue = 1.25,
  double toX = 0,
  double toY = 0,
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
  final ValueNotifier<double> scale = useState<double>(scaleInitialValue);

  final AnimationController x = useSpringAnimation(toX);
  final AnimationController y = useSpringAnimation(toY);

  return Positioned(
    left: x.value,
    top: y.value,
    child: GestureDetector(
      onTapDown: (TapDownDetails details) {
        (onTapDown ??= (TapDownDetails _) {})(details);
        scale.value = scaleFinalValue;
      },
      onTapUp: (TapUpDetails details) {
        (onTapUp ??= (TapUpDetails _) {})(details);
        scale.value = scaleInitialValue;
      },
      onTapCancel: () {
        (onTapCancel ??= () {})();
        scale.value = scaleInitialValue;
      },
      onVerticalDragStart: (DragStartDetails details) {
        (onDragStart ?? (DragStartDetails _) {})(details);
        scale.value = scaleFinalValue;
      },
      onVerticalDragUpdate: (DragUpdateDetails details) {
        (onDragUpdate ?? (DragUpdateDetails _) {})(details);
        scale.value = scaleFinalValue;
      },
      onVerticalDragEnd: (DragEndDetails details) {
        (onDragEnd ?? (DragEndDetails _) {})(details);
        scale.value = scaleInitialValue;
      },
      onVerticalDragCancel: () {
        (onDragCancel ?? () {})();
        scale.value = scaleInitialValue;
      },
      child: _SpringScale(
        scale: scale.value,
        // translateX: toX,
        // translateY: toY,
        child: child,
      ),
    ),
  );
}

@hwidget
Widget _springScale({
  @required double scale,
  // @required double translateX,
  // @required double translateY,
  @required Widget child,
  Alignment alignment = Alignment.center,
}) {
  /// [useSpringAnimation] hook must be inside the [Widget] being rebuilt,
  /// as it uses `didUpdateHook` to understand when to rebuild and run the animation
  final AnimationController scaleController = useSpringAnimation(scale);

  return Transform(
    transform: Matrix4.identity()..scale(scaleController.value),
    alignment: alignment,
    child: child,
  );
}
