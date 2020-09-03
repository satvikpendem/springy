import 'package:flutter/foundation.dart'; // required for functional_widget_annotation to build
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart'; // required for @hwidget functional_widget_annotation
import 'package:functional_widget_annotation/functional_widget_annotation.dart';

import 'use_spring_animation.dart';

part 'expandable_spring_box.g.dart';

/// [Container] for testing [Animation]s
@hwidget
Widget expandableSpringBox({
  @required void Function(DragUpdateDetails details) onDragUpdate,
  String description = 'Box',
  Color color = Colors.blue,
  Color descriptionColor = Colors.white,
  double width = 100,
  double height = 100,
}) {
  final AnimationController heightAnimation = useSpringAnimation(height);

  // return
  // Column(
  //   mainAxisSize: MainAxisSize.min,
  //   children: <Widget>[
  //     SizedBox(
  //       width: width,
  //       child: Container(
  //         height: heightAnimation.value - 20,
  //         color: color,
  //         child: Column(
  //           children: <Widget>[
  //             Text('$height'),
  //           ],
  //         ),
  //       ),
  //     ),
  //     Container(
  //       height: 20,
  //       child: GestureDetector(
  //         onVerticalDragUpdate: onDragUpdate,
  //         child: Container(
  //           color: Colors.green,
  //           alignment: Alignment.center,
  //         ),
  //       ),
  //     )
  //   ],
  // );

  return Column(
    children: [
      Container(
        // margin: const EdgeInsets.all(10),
        width: width,
        height: heightAnimation.value - 20,
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
      ),
      Container(
        height: 20,
        child: GestureDetector(
          onVerticalDragUpdate: onDragUpdate,
          child: Container(
            width: width,
            color: Colors.white,
          ),
        ),
      )
    ],
  );
}
