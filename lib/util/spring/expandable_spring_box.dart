import 'package:flutter/foundation.dart'; // required for functional_widget_annotation to build
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart'; // required for @hwidget functional_widget_annotation
import 'package:functional_widget_annotation/functional_widget_annotation.dart';
import 'package:flutter_color/flutter_color.dart';

import 'use_spring_animation.dart';

part 'expandable_spring_box.g.dart';

const double kExpandableHeight = 20;

/// [Container] for testing [Animation]s
@hwidget
Widget expandableSpringBox({
  @required void Function(DragUpdateDetails details) onDragUpdate,
  @required void Function(DragEndDetails details) onDragEnd,
  bool suppressAnimation = false,
  String description = 'Box',
  Color color = Colors.blue,
  Color descriptionColor = Colors.white,
  double width = 100,
  double height = 100,
}) {
  final AnimationController heightAnimation = useSpringAnimation(
    height,
    suppressAnimation: suppressAnimation,
  );

  return Column(
    children: <Widget>[
      Container(
        width: width,
        height: heightAnimation.value - kExpandableHeight,
        decoration: BoxDecoration(
          color: color,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(10),
            topRight: Radius.circular(10),
          ),
        ),
        alignment: Alignment.center,
        child: Text(
          description,
          style: TextStyle(
            color: descriptionColor,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
      SizedBox(
        height: kExpandableHeight,
        child: GestureDetector(
          onVerticalDragUpdate: onDragUpdate,
          onVerticalDragEnd: onDragEnd,
          child: Container(
            width: width,
            decoration: BoxDecoration(
              color: color.darker(10),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(10),
                bottomRight: Radius.circular(10),
              ),
            ),
          ),
        ),
      )
    ],
  );
}
