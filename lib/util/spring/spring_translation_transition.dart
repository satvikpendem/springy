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

  final ValueNotifier<double> xTranslation =
      useState<double>(x.value * (xAnimation.controller.value));
  final ValueNotifier<double> yTranslation =
      useState<double>(y.value * (xAnimation.controller.value));

  // useEffect(() {
  //   // xTranslation.value = x.value * (xAnimation.controller.value);
  //   // yTranslation.value = y.value * (yAnimation.controller.value);
  //   // print(yTranslation.value);

  //   // xAnimation.run(xAnimation.intermediateValue, _spring.end);
  //   // yAnimation.run(yAnimation.intermediateValue, _spring.end);
  //   x.value = toX;
  //   y.value = toY;

  //   xTranslation.value = x.value * (xAnimation.controller.value);
  //   yTranslation.value = y.value * (yAnimation.controller.value);

  //   // xAnimation.run()

  //   return;
  // }, <double>[toX, toY]);

  return GestureDetector(
    onVerticalDragStart: (DragStartDetails details) {
      _onDragStart(details);
      xAnimation.run(xAnimation.intermediateValue, _spring.end);
      yAnimation.run(yAnimation.intermediateValue, _spring.end);
      print(yAnimation.intermediateValue);
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

// class STT extends StatefulWidget {
//   /// If the [spring] is not specified, a default one will be made
//   STT({
//     @required this.child,
//     Spring spring,
//     this.maxScaleFactor = 0.25,
//     this.toX = 100,
//     void Function(DragStartDetails) onDragStart,
//     void Function(DragUpdateDetails) onDragUpdate,
//     void Function(DragEndDetails) onDragEnd,
//     void Function() onDragCancel,
//   }) {
//     this.spring = spring ?? Spring();
//     assert(this.spring.description.mass > 0, 'Mass must be greater than 0');

//     /// If Drag GestureDetectorCallbacks are not specified, defaults are made
//     this.onDragStart = onDragStart ?? ((DragStartDetails _) {});
//     this.onDragUpdate = onDragUpdate ?? ((DragUpdateDetails _) {});
//     this.onDragEnd = onDragEnd ?? ((DragEndDetails _) {});
//     this.onDragCancel = onDragCancel ?? (() {});
//   }
//   double toX;

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
//   _STTState createState() => _STTState();
// }

// class _STTState extends State<STT> with TickerProviderStateMixin {
//   AnimationController controller;

//   /// Used to calculate intermediate values for the next animation run
//   /// when the current animation is canceled or otherwise changed
//   double intermediateValue = 0;

//   SpringSimulation simulation;

//   double x;

//   @override
//   void initState() {
//     super.initState();
//     simulation = widget.spring.simulation;
//     x = widget.toX;

//     controller = AnimationController(
//       vsync: this,

//       /// Set the bounds to be infinite both positively and negatively.
//       /// The defaults are 1 and -1 for `upperBound` and `lowerBound`
//       /// respectively, so the spring animation / will not be visible as it
//       /// generally goes past 1 and -1. If the bounds remain at 1 and -1,
//       /// therefore, the controller will simply stop animating the animated
//       /// Widget past these bounds.
//       upperBound: double.infinity,
//       lowerBound: double.negativeInfinity,
//       value: 0,
//     )..addListener(() {
//         /// We must `setState` in order to update the animation
//         /// and also to record the intermediate value.
//         /// This will rebuild the whole UI which is not ideal but is usable.
//         setState(() {
//           /// The intermediate value is used to figure out where the animation
//           /// will start and end on the next iteration if it's stopped in the
//           /// middle of the animation. For example, if the user cancels the
//           /// [Gesture], then we must know where the animation stopped in order
//           /// to interpolate from the `intermediateValue` to the new value.
//           intermediateValue = controller.value;
//         });
//       });

//     /// Controller automatically starts at lowerBound, which is negative
//     /// infinity. Therefore, we must set the value to be 0 for the [Transform]s
//     /// to render correctly in the [Container].
//     ///
//     /// We also can't cascade setting the controller's value to 0 because the
//     /// controller is still null and we will get an error on the command line,
//     /// even if it works fine in the UI.
//     // ignore: cascade_invocations
//     // controller.value = 0;
//   }

//   @override
//   void dispose() {
//     controller.dispose();
//     super.dispose();
//   }

//   @override
//   void didUpdateWidget(STT oldWidget) {
//     setState(() {
//       x = oldWidget.toX;
//     });
//     runAnimation(intermediateValue, widget.spring.end);
//     print("running");
//     super.didUpdateWidget(oldWidget);
//   }

//   void runAnimation(double start, double end) {
//     simulation = SpringSimulation(
//       widget.spring.description,
//       start,
//       end,
//       widget.spring.velocity,
//     );
//     controller.animateWith(simulation);
//   }

//   // void onTapUp(TapUpDetails details) =>
//   //     runAnimation(intermediateValue, widget.spring.start);

//   // void onTapDown(TapDownDetails details) =>
//   //     runAnimation(intermediateValue, widget.spring.end);

//   // void onTapCancel() => runAnimation(intermediateValue, widget.spring.end);

//   @override
//   Widget build(BuildContext context) {
//     /// Scale must be at least 1, but clamping will stop the controller.value
//     /// from progressing, causing the visual perception of jankiness
//     final double translation = widget.toX * controller.value;

//     return GestureDetector(
//       // onTapDown: onTapDown,
//       // onTapUp: onTapUp,
//       // onTapCancel: onTapCancel,
//       onVerticalDragStart: (DragStartDetails details) {
//         widget.onDragStart(details);
//         runAnimation(intermediateValue, widget.spring.end);
//       },
//       onVerticalDragUpdate: widget.onDragUpdate,
//       onVerticalDragEnd: (DragEndDetails details) {
//         widget.onDragEnd(details);
//         runAnimation(intermediateValue, widget.spring.start);
//       },
//       onVerticalDragCancel: () {
//         widget.onDragCancel();
//         runAnimation(intermediateValue, widget.spring.start);
//       },
//       child: Transform(
//         transform: Matrix4.identity()..translate(translation),
//         alignment: Alignment.center,
//         child: widget.child,
//       ),
//     );
//   }
// }
