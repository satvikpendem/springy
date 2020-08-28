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
  double initialValue = 1,
  double maxScaleFactor = 0.25,
  void Function(DragStartDetails) onDragStart,
  void Function(DragUpdateDetails) onDragUpdate,
  void Function(DragEndDetails) onDragEnd,
  void Function() onDragCancel,
}) {
  final Spring _spring = spring ?? Spring();
  assert(_spring.description.mass > 0, 'Mass must be greater than 0');

  /// If Drag GestureDetectorCallbacks are not specified, defaults are made
  // TODO(satvikpendem): Remove duplicate functions
  // final void Function(DragStartDetails p1) _onDragStart =
  //     onDragStart ?? (DragStartDetails _) {};
  // final void Function(DragUpdateDetails p1) _onDragUpdate =
  //     onDragUpdate ?? (DragUpdateDetails _) {};
  // final void Function(DragEndDetails p1) _onDragEnd =
  //     onDragEnd ?? (DragEndDetails _) {};
  // final void Function() _onDragCancel = onDragCancel ?? () {};

  // final SpringAnimator springAnimation = useSpringAnimator();
  final AnimationController animation = useSpringAnimation(initialValue);

  final ValueNotifier<bool> isActive = useState<bool>(false);

  /// Initial scale value is just 1
  final ValueNotifier<double> scale = useState<double>(initialValue);

  useEffect(() {
    if (isActive.value) {
      scale.value = initialValue + (animation.value * maxScaleFactor);
    } else {
      scale.value = initialValue;
    }
    return;
  }, <bool>[isActive.value]);

  /// Scale must be at least 1, but clamping will stop the controller.value
  /// from progressing, causing the visual perception of jankiness
  // final double scale = 1 + (springAnimation.controller.value * maxScaleFactor);

  return GestureDetector(
    onTapDown: (_) {
      // return springAnimation.run(springAnimation.intermediateValue, _spring.end);
      isActive.value = true;
    },
    onTapUp: (_) {
      // return springAnimation.run(springAnimation.intermediateValue, _spring.start);
      isActive.value = false;
    },
    onTapCancel: () {
      // return springAnimation.run(springAnimation.intermediateValue, _spring.start);
      isActive.value = false;
    },
    // onVerticalDragStart: (DragStartDetails details) {
    //   _onDragStart(details);
    //   springAnimation.run(springAnimation.intermediateValue, _spring.end);
    // },
    // onVerticalDragUpdate: _onDragUpdate,
    // onVerticalDragEnd: (DragEndDetails details) {
    //   _onDragEnd(details);
    //   springAnimation.run(springAnimation.intermediateValue, _spring.start);
    // },
    // onVerticalDragCancel: () {
    //   _onDragCancel();
    //   springAnimation.run(springAnimation.intermediateValue, _spring.start);
    // },
    child: Transform(
      transform: Matrix4.identity()..scale(scale.value),
      alignment: Alignment.center,
      child: child,
    ),
  );
}
