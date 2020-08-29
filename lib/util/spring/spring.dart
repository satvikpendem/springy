import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';

/// Default spring description with moderate bounce behavior
const SpringDescription kDefaultSpringDescription = SpringDescription(
  mass: 3,
  stiffness: 200,
  damping: 3,
);

/// Wrapper class around [SpringDescription] with defaults and public members for spring-like animation
class Spring {
  /// Constructor that takes in the various parameters for a [SpringSimulation] and initializes it
  ///
  /// If using with SpringCurve, [Curve]s expect that the values be between 0 and 1, so [start] and [end] should also be 0 to 1.
  /// [velocity] can be changed if wanted, but generally 0 works as springs start with no velocity normally.
  Spring({
    SpringDescription description,
    this.start = 0,
    this.end = 1,
    this.velocity = 0,
  }) : description = description ?? kDefaultSpringDescription {
    simulation = SpringSimulation(this.description, start, end, velocity);
  }

  /// The [SpringDescription] to use for the [SpringSimulation]
  final SpringDescription description;

  /// Parameters for the [SpringSimulation], read that class for more information
  final double start, end, velocity;

  /// The [SpringSimulation] itself
  SpringSimulation simulation;
}
