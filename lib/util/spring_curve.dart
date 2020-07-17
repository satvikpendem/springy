import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';

import '../spring.dart';

/// [Curve] that has spring-like properties, used mainly for being extended by
/// [SpringSimulationCurve] and [SpringPeriodicCurve]
abstract class SpringCurve extends Curve {}

/// [Curve] that can use a [SpringDescription] for a spring-like animation.
class SpringSimulationCurve extends SpringCurve {
  /// Constructor that takes in the various parameters for a [SpringSimulation] and initializes it
  ///
  /// [Curve]s expect that the values be between 0 and 1, so [spring.start] and [spring.end] should also be 0 to 1
  /// which they are by default.
  /// [spring.velocity] can be changed if wanted, but generally 0 works as springs start with no velocity normally.
  SpringSimulationCurve({
    @required this.spring,
  });

  /// [Spring] to be used to drive the animation
  final Spring spring;

  /// Use the outputted position (from [spring.start] to [spring.end]) from the
  /// [SpringSimulation] [spring.simulation] to drive the curve
  @override
  double transformInternal(double t) => spring.simulation.x(t);
}

/// [Curve] that uses parabolic equations rather than a [SpringDescription].
///
/// For a [Curve] that uses a [SpringDescription], see [SpringCurve].
class SpringPeriodicCurve extends SpringCurve {
  /// Constructor with good default values
  SpringPeriodicCurve({
    this.amplitude = 0.15,
    this.wavelength = 19.4,
  });

  /// Holds the amplitude of the wave being created
  final double amplitude;

  /// Holds the wavelength of the wave being created
  final double wavelength;

  /// [pow] returns a [num] but [Curve]'s [transformInternal] expects a [double] so must be cast
  /// Equation is -(e^(-t / amplitude) * cos(t * wavelength)) + 1
  @override
  double transformInternal(double t) =>
      // ignore: avoid_as
      -(pow(e, -t / amplitude) * cos(t * wavelength)) + 1 as double;
}
