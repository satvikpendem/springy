import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import 'spring.dart';

class SpringAnimationController {
  final AnimationController controller;
  final void Function(double start, double end) run;

  SpringAnimationController(this.controller, this.run);
}

/// Hook for creating [Spring] animations that handle initializing the controller, disposing it, and running animations
SpringAnimationController useSpringAnimationControllerClass({Spring spring}) =>
    use(_SpringAnimationHook(spring ?? Spring()));

class _SpringAnimationHook extends Hook<SpringAnimationController> {
  const _SpringAnimationHook(this.spring);

  final Spring spring;

  @override
  HookState<SpringAnimationController, Hook<SpringAnimationController>>
      createState() => _SpringAnimationHookState();
}

class _SpringAnimationHookState
    extends HookState<SpringAnimationController, _SpringAnimationHook> {
  AnimationController controller;

  /// Used to calculate intermediate values for the next animation run
  /// when the current animation is canceled or otherwise changed
  double intermediateValue = 0;

  @override
  void initHook() {
    controller = AnimationController(
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
    /// to render correctly in the [Container].
    ///
    /// We also can't cascade setting the controller's value to 0 because the
    /// controller is still null and we will get an error on the command line,
    /// even if it works fine in the UI.
    // ignore: cascade_invocations
    controller.value = 0;
  }

  @override
  void dispose() => controller.dispose();

  void runAnimation(double start, double end) => controller.animateWith(
        SpringSimulation(
          hook.spring.description,
          start,
          end,
          hook.spring.velocity,
        ),
      );

  @override
  SpringAnimationController build(BuildContext context) =>
      SpringAnimationController(controller, runAnimation);
}

class Example extends HookWidget {
  @override
  Widget build(BuildContext context) {
    final SpringAnimationController springAnimation =
        useSpringAnimationControllerClass();
    return Container();
  }
}

SpringAnimationController useSpringAnimationControllerFunction(
    [Spring spring]) {
  final ValueNotifier<double> intermediateValue = useState<double>(0);
  AnimationController controller;
  final Spring _spring = spring ?? Spring();

  controller = useAnimationController(
    /// Set the bounds to be infinite both positively and negatively.
    /// The defaults are 1 and -1 for `upperBound` and `lowerBound`
    /// respectively, so the spring animation / will not be visible as it
    /// generally goes past 1 and -1. If the bounds remain at 1 and -1,
    /// therefore, the controller will simply stop animating the animated
    /// Widget past these bounds.
    upperBound: double.infinity,
    lowerBound: double.negativeInfinity,
  )
    ..addListener(() {
      /// The intermediate value is used to figure out where the animation
      /// will start and end on the next iteration if it's stopped in the
      /// middle of the animation. For example, if the user cancels the
      /// [Gesture], then we must know where the animation stopped in order
      /// to interpolate from the `intermediateValue` to the new value.
      intermediateValue.value = controller.value;
    })

    /// Controller automatically starts at lowerBound, which is negative
    /// infinity. Therefore, we must set the value to be 0 for the [Transform]s
    /// to render correctly in the [Container].
    ..value = 0;

  void runAnimation(double start, double end) => controller.animateWith(
        SpringSimulation(
          _spring.description,
          start,
          end,
          _spring.velocity,
        ),
      );

  return SpringAnimationController(controller, runAnimation);
}
