import 'package:flutter/material.dart';

/// [Container] for testing [Animation]s
class SpringBox extends StatelessWidget {
  const SpringBox({
    @required this.description,
    this.color = Colors.blue,
    this.descriptionColor = Colors.white,
    this.width = 100,
    this.height = 100,
    Key key,
  }) : super(key: key);

  /// Description for the Box
  final String description;

  /// [Color] for the Box
  final Color color;

  /// [Color] of the [description]
  final Color descriptionColor;

  /// Width of the Box
  final double width;

  /// Height of the Box
  final double height;

  @override
  Widget build(BuildContext context) => Container(
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
}
