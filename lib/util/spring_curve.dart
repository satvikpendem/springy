import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';

/// [Curve] that can use a [SpringDescription] for a spring-like animation.
class SpringCurve extends Curve {
  /// Constructor that takes in the various parameters for a [SpringSimulation] and initializes it
  ///
  /// [Curve]s expect that the values to be between 0 and 1, so [start] and [end] should also be 0 to 1.
  /// [velocity] can be changed if wanted, but generally 1 should be a good enough value.
  SpringCurve({
    @required this.spring,
    this.start = 0,
    this.end = 1,
    this.velocity = 1,
  }) : sim = SpringSimulation(spring, start, end, velocity);

  /// The [SpringDescription] used to model the [Curve].
  final SpringDescription spring;

  /// Parameters for the [SpringSimulation], check that class for more information.
  ///
  /// These should not be changed generally as they are customized for [Animation]s.
  /// More is explained in the constructor.
  final double start, end, velocity;

  /// The [SpringSimulation] used to calculate the actual tween values.
  final SpringSimulation sim;

  /// Use the outputted position (from [start] to [end]) from the [SpringSimulation] [sim] to drive the curve
  @override
  double transformInternal(double t) => sim.x(t);
}

class SpringCurveParabolic extends Curve {
  const SpringCurveParabolic({
    this.a = 0.15,
    this.w = 19.4,
  });
  final double a;
  final double w;

  @override
  double transformInternal(double t) {
    return -(pow(e, -t / a) * cos(t * w)) + 1 as double;
  }
}
