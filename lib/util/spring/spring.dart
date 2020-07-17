import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';

/// Wrapper class around [SpringDescription] with defaults and public members for spring-like animation
class Spring {
  /// Constructor that takes in the various parameters for a [SpringSimulation] and initializes it
  ///
  /// If using with [SpringCurve], [Curve]s expect that the values be between 0 and 1, so [start] and [end] should also be 0 to 1.
  /// [velocity] can be changed if wanted, but generally 0 works as springs start with no velocity normally.
  Spring({
    @required this.description,
    this.start = 0,
    this.end = 1,
    this.velocity = 0,
  }) : simulation = SpringSimulation(description, start, end, velocity);

  /// The [SpringDescription] to use for the [SpringSimulation]
  final SpringDescription description;

  /// Parameters for the [SpringSimulation], read that class for more information
  final double start, end, velocity;

  /// The [SpringSimulation] itself
  final SpringSimulation simulation;
}
