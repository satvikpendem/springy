import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import 'spring.dart';

/// Class for holding return values of [useSpringAnimation] hook
class SpringAnimation {
  /// Default constructor
  const SpringAnimation(this.controller, this.run, this.intermediateValue);

  /// [AnimationController] for [SpringSimulation]
  final AnimationController controller;

  /// [runAnimation] function inside [useSpringAnimation]
  final void Function(double start, double end) run;

  /// Value for changing animation on cancelation
  final double intermediateValue;
}

/// Hook for creating [Spring] animations that handle initializing the controller, disposing it, and running animations
SpringAnimation useSpringAnimation([Spring spring]) {
  final ValueNotifier<double> intermediateValue = useState<double>(0);
  AnimationController controller;
  final Spring _spring = spring ?? Spring();

  controller = useAnimationController(
    /// Set the bounds to be infinite both positively and negatively. The defaults are 1 and -1 for `upperBound` and
    /// `lowerBound` respectively, so the spring animation will not be visible as it generally goes past 1 and -1.
    /// If the bounds remain at 1 and -1, / therefore, the controller will simply stop animating the animated / Widget
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

  return SpringAnimation(
    controller,
    runAnimation,
    intermediateValue.value,
  );
}
