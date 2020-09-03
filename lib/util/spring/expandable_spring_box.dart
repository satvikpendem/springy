import 'package:flutter/foundation.dart'; // required for functional_widget_annotation to build
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart'; // required for @hwidget functional_widget_annotation
import 'package:functional_widget_annotation/functional_widget_annotation.dart';

import 'use_spring_animation.dart';

part 'expandable_spring_box.g.dart';

/// [Container] for testing [Animation]s
@hwidget
Widget expandableSpringBox({
  String description = 'Box',
  Color color = Colors.blue,
  Color descriptionColor = Colors.white,
  double width = 100,
  double height = 100,
}) {
  final AnimationController heightAnimation = useSpringAnimation(height);

  return Container(
    margin: const EdgeInsets.all(10),
    width: width,
    height: heightAnimation.value,
    decoration: BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(10),
    ),
    padding: const EdgeInsets.all(10),
    alignment: Alignment.center,
    child: Text(
      description,
      style: TextStyle(
        color: descriptionColor,
        fontWeight: FontWeight.w900,
      ),
    ),
  );
}
