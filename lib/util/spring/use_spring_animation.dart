import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import 'spring.dart';

/// Hook to implicitly animate [Widget]s with a [SpringSimulation]
///
/// [value]: Value to animate towards
///
/// [spring]: [Spring] to use for the animation
///
/// [suppressAnimation]: Whether to stop the default [Spring] animation and just use a zero [Duration] linear [Curve]
/// This can be useful when dragging a [Widget] that uses this hook, as without this, the user faces lag between
/// their interaction and the actual movement of the Widget on-screen.
AnimationController useSpringAnimation(
  double value, {
  Spring spring,
  bool suppressAnimation = false,
}) {
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
        value: value,
        spring: spring,
        controller: controller,
        suppressAnimation: suppressAnimation,
      ),
    ),
  );
}

class _SpringAnimationHook extends Hook<AnimationController> {
  const _SpringAnimationHook({
    this.value,
    this.spring,
    this.controller,
    this.suppressAnimation,
  });

  final double value;
  final Spring spring;
  final AnimationController controller;
  final bool suppressAnimation;

  @override
  _SpringAnimationHookState createState() => _SpringAnimationHookState();
}

class _SpringAnimationHookState
    extends HookState<AnimationController, _SpringAnimationHook> {
  @override
  void initHook() {
    super.initHook();

    /// Initialize the `controller` with the default `value` passed in
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
      if (hook.suppressAnimation) {
        /// When [suppressAnimation] is active, we don't want to run a [Spring] animation but instead one with
        /// zero Duration
        hook.controller.animateTo(
          hook.value,
          duration: const Duration(),
        );
      } else {
        /// Every time the `hook.value` changes, run the animation from wherever it was interrupted
        run(hook.controller.value, hook.value);
      }
    }
  }

  @override
  AnimationController build(BuildContext context) => hook.controller;
}
