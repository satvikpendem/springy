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

/// [Curve] that uses parabolic equations rather than a [SpringDescription].
///
/// For a [Curve] that uses a [SpringDescription], see [SpringCurve].
class SpringCurvePeriodic extends Curve {
  /// Constructor with good default values
  const SpringCurvePeriodic({
    this.amplitude = 0.15,
    this.wavelength = 19.4,
  });

  /// Holds the amplitude of the wave being created
  final double amplitude;

  /// Holds the wavelength of the wave being created
  final double wavelength;

  /// [pow] returns a [num] but [Curve]'s [transformInternal] expects a [double] so must be cast
  @override
  double transformInternal(double t) =>
      -(pow(e, -t / amplitude) * cos(t * wavelength)) + 1 as double;
}
