import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import 'spring.dart';

/// Class for holding return values of [useSpringAnimator] hook
class SpringAnimator {
  /// Default constructor
  const SpringAnimator(this.controller, this.run, this.intermediateValue);

  /// [AnimationController] for [SpringSimulation]
  final AnimationController controller;

  /// [runAnimation] function inside [useSpringAnimator]
  final void Function(double start, double end) run;

  /// Value for changing animation on cancelation
  final double intermediateValue;
}

/// Hook for creating [Spring] animations that handle initializing the controller, disposing it, and running animations
SpringAnimator useSpringAnimator([Spring spring]) {
  final ValueNotifier<double> intermediateValue = useState<double>(0);
  AnimationController controller;
  final Spring _spring = spring ?? Spring();

  controller = useAnimationController(
    /// Set the bounds to be infinite both positively and negatively. The defaults are 1 and -1 for `upperBound` and
    /// `lowerBound` respectively, so the spring animation will not be visible as it generally goes past 1 and -1.
    /// If the bounds remain at 1 and -1, therefore, the controller will simply stop animating the animated / Widget
    /// past these bounds.
    ///
    /// We could also use [AnimationController.unbounded] but [useAnimationController] is a hook which doesn't have
    /// that constructor.
    upperBound: double.infinity,
    lowerBound: double.negativeInfinity,
  )..addListener(() {
      /// The intermediate value is used to figure out where the animation will start and end on the next iteration
      /// if it's stopped in the middle of the animation. For example, if the user cancels the [Gesture], then we
      /// must know where the animation stopped in order to interpolate from the `intermediateValue` to the new value.
      intermediateValue.value = controller.value;
    });

  void runAnimation(double start, double end) => controller.animateWith(
        SpringSimulation(
          _spring.description,
          start,
          end,
          _spring.velocity,
        ),
      );

  return SpringAnimator(
    controller,
    runAnimation,
    intermediateValue.value,
  );
}

AnimationController useSpringAnimation(double value, {Spring spring}) {
  /// Initialize default spring if none is passed in
  spring ??= Spring();

  /// [AnimationController] to pass into the inner hook implementation
  final AnimationController controller = useAnimationController(
    lowerBound: double.negativeInfinity,
    upperBound: double.infinity,
    initialValue: value,
  );
  return useListenable(
    use(
      _SpringAnimationHook(
        value,
        spring,
        controller,
      ),
    ),
  );
}

class _SpringAnimationHook extends Hook<AnimationController> {
  const _SpringAnimationHook(
    this.value,
    this.spring,
    this.controller,
  );

  final double value;
  final Spring spring;
  final AnimationController controller;

  @override
  _SpringAnimationHookState createState() => _SpringAnimationHookState();
}

class _SpringAnimationHookState
    extends HookState<AnimationController, _SpringAnimationHook> {
  @override
  void initHook() {
    super.initHook();

    /// Initialize the `controller with the default value passed in
    hook.controller.value = hook.value;
  }

  /// Utility function to run the animation with given start and end values
  void run(double start, double end) => hook.controller.animateWith(
        SpringSimulation(
          hook.spring.description,
          start,
          end,
          hook.spring.velocity,
        ),
      );

  @override
  void didUpdateHook(_SpringAnimationHook oldHook) {
    if (oldHook.value != hook.value) {
      /// Every time the `hook.value` changes, run the animation from wherever it was interrupted
      run(hook.controller.value, hook.value);
    }
  }

  @override
  AnimationController build(BuildContext context) => hook.controller;
}
