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

  return SpringAnimation(
    controller,
    runAnimation,
    intermediateValue.value,
  );
}

AnimationController useSpringAnimationClass(double value, {Spring spring}) {
  spring ??= Spring();
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
    hook.controller.value = hook.value;
  }

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
      run(hook.controller.value, hook.value);
    }
  }

  @override
  AnimationController build(BuildContext context) => hook.controller;
}

void main(List<String> args) => runApp(const AnimatedPositionedHookExample());

class AnimatedPositionedHookExample extends HookWidget {
  const AnimatedPositionedHookExample({Key key});

  @override
  Widget build(BuildContext context) {
    final ValueNotifier<bool> isDown = useState(false);
    final ValueNotifier<List<double>> targets = useState<List<double>>(
      <double>[
        100,
        200,
        300,
      ],
    );

    useEffect(() {
      targets.value = isDown.value ? [520, 410, 300] : [0, 110, 220];
      return;
    }, <bool>[isDown.value]);

    return MaterialApp(
      home: SafeArea(
        child: Scaffold(
          floatingActionButton: FloatingActionButton(
            onPressed: () => isDown.value = !isDown.value,
          ),
          body: Stack(
            children: List<Box>.generate(
              3,
              (int index) => Box(
                index: index,
                target: targets.value.elementAt(index),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class Box extends HookWidget {
  const Box({
    Key key,
    this.index,
    this.target,
  }) : super(key: key);

  final double target;
  final int index;

  @override
  Widget build(BuildContext context) {
    // final double position = useSpringAnimationClass(target);
    final AnimationController animationController =
        useSpringAnimationClass(target);

    final Container child = useMemoized(
      () => Container(
        width: 100,
        height: 100,
        color: Colors.blue,
      ),
    );

    return Positioned(
      top: animationController.value,
      left: (MediaQuery.of(context).size.width - 100) / 2,
      child: child,
    );
  }
}
