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
  double toX = 0,
  double toY = 0,
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

  final SpringAnimation xAnimation = useSpringAnimation();
  final SpringAnimation yAnimation = useSpringAnimation();

  /// Scale must be at least 1, but clamping will stop the controller.value
  /// from progressing, causing the visual perception of jankiness
  final ValueNotifier<double> xTranslation =
      useState<double>(x.value * (xAnimation.controller.value));
  final ValueNotifier<double> yTranslation =
      useState<double>(y.value * (xAnimation.controller.value));

  useEffect(() {
    xTranslation.value = x.value * (xAnimation.controller.value);
    yTranslation.value = y.value * (yAnimation.controller.value);

    xAnimation.run(xAnimation.intermediateValue, _spring.end);
    yAnimation.run(yAnimation.intermediateValue, _spring.end);

    return;
  }, <double>[toX, toY]);

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
          xTranslation.value,
          yTranslation.value,
        ),
      alignment: Alignment.center,
      child: child,
    ),
  );
}

// class STT extends StatefulHookWidget {
//   STT({
//     @required Widget child,
//     Spring spring,
//     double toX = 0,
//     double toY = 0,
//     void Function(DragStartDetails) onDragStart,
//     void Function(DragUpdateDetails) onDragUpdate,
//     void Function(DragEndDetails) onDragEnd,
//     void Function() onDragCancel,
//   }) {
//     final Spring widgetSpring = spring ?? Spring();
//     assert(widgetSpring.description.mass > 0, 'Mass must be greater than 0');

//     /// If Drag GestureDetectorCallbacks are not specified, defaults are made
//     final void Function(DragStartDetails p1) dragStart =
//         onDragStart ?? (DragStartDetails _) {};
//     final void Function(DragUpdateDetails p1) dragUpdate =
//         onDragUpdate ?? (DragUpdateDetails _) {};
//     final void Function(DragEndDetails p1) dragEnd =
//         onDragEnd ?? (DragEndDetails _) {};
//     final void Function() dragCancel = onDragCancel ?? () {};
//   }

//   @override
//   _STTState createState() => _STTState();
// }

// class _STTState extends State<STT> {
//   @override
//   Widget build(BuildContext context) {
//     final SpringAnimation xAnimation = useSpringAnimation();
//     final SpringAnimation yAnimation = useSpringAnimation();
//     return GestureDetector(
//       onVerticalDragStart: (DragStartDetails details) {
//         widget.dragStart(details);
//         xAnimation.run(xAnimation.intermediateValue, _spring.end);
//         yAnimation.run(yAnimation.intermediateValue, _spring.end);
//       },
//       onVerticalDragUpdate: _onDragUpdate,
//       onVerticalDragEnd: (DragEndDetails details) {
//         _onDragEnd(details);
//         xAnimation.run(xAnimation.intermediateValue, _spring.start);
//         yAnimation.run(yAnimation.intermediateValue, _spring.start);
//       },
//       onVerticalDragCancel: () {
//         _onDragCancel();
//         xAnimation.run(xAnimation.intermediateValue, _spring.start);
//         yAnimation.run(yAnimation.intermediateValue, _spring.start);
//       },
//       child: Transform(
//         transform: Matrix4.identity()
//           ..translate(
//             xTranslation,
//             yTranslation,
//           ),
//         alignment: Alignment.center,
//         child: child,
//       ),
//     );
//   }
// }
