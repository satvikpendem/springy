import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:functional_widget_annotation/functional_widget_annotation.dart';

import 'spring.dart';
import 'spring_animation_hook.dart';

part 'spring_translation_transition.g.dart';

/// Container that can use [SpringSimulation]s for [Transform]s
@hwidget
Widget springTranslationTransition({
  @required Widget child,
  Spring spring,
  double toX,
  double toY,
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

  final ValueNotifier<double> x = useState<double>(toX);
  final ValueNotifier<double> y = useState<double>(toY);

  final SpringAnimator xAnimation = useSpringAnimator();
  final SpringAnimator yAnimation = useSpringAnimator();

  double xTranslation = x.value * (xAnimation.controller.value);
  double yTranslation = y.value * (yAnimation.controller.value);

  useEffect(() {
    x.value = toX;
    y.value = toY;

    xTranslation = x.value * (xAnimation.controller.value);
    yTranslation = y.value * (yAnimation.controller.value);

    xAnimation.run(xAnimation.intermediateValue, _spring.end);
    yAnimation.run(yAnimation.intermediateValue, _spring.end);

    return;
  }, <ValueNotifier<double>>[x, y]);

  // void run() => yAnimation.run(yAnimation.intermediateValue, _spring.end);

  return GestureDetector(
    onVerticalDragStart: (DragStartDetails details) {
      _onDragStart(details);
      xAnimation.run(xAnimation.intermediateValue, _spring.end);
      yAnimation.run(yAnimation.intermediateValue, _spring.end);
    },
    onVerticalDragUpdate: _onDragUpdate,
    onVerticalDragEnd: (DragEndDetails details) {
      _onDragEnd(details);
      xAnimation.run(xAnimation.intermediateValue, _spring.start);
      yAnimation.run(yAnimation.intermediateValue, _spring.start);
    },
    onVerticalDragCancel: () {
      _onDragCancel();
      xAnimation.run(xAnimation.intermediateValue, _spring.start);
      yAnimation.run(yAnimation.intermediateValue, _spring.start);
    },
    child: Transform(
      transform: Matrix4.identity()
        ..translate(
          xTranslation,
          yTranslation,
        ),
      alignment: Alignment.center,
      child: child,
    ),
  );
}
