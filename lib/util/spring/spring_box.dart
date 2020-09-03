import 'package:flutter/foundation.dart'; // required for functional_widget_annotation to build
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart'; // required for @hwidget functional_widget_annotation
import 'package:functional_widget_annotation/functional_widget_annotation.dart';

part 'spring_box.g.dart';

/// [Container] for testing [Animation]s
@hwidget
Widget springBox({
  String description = 'Box',
  Color color = Colors.blue,
  Color descriptionColor = Colors.white,
  double width = 100,
  double height = 100,
}) =>
    Container(
      margin: const EdgeInsets.all(10),
      width: width,
      height: height,
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
