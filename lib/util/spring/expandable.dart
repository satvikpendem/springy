import 'package:flutter/material.dart';

class Expandable extends StatefulWidget {
  final Duration duration;
  final String title;

  Expandable({
    @required Key key,
    @required this.title,
    this.duration = const Duration(minutes: 100),
  }) : super(key: key);

  @override
  _ExpandableState createState() => _ExpandableState();
}

class _ExpandableState extends State<Expandable> {
  double _height;

  @override
  void initState() {
    super.initState();
    _height = widget.duration.inMinutes.toDouble();
  }

  String toDurationText(double number) {
    Duration d = Duration(minutes: number.toInt());

    int minuteValue = d.inMinutes % Duration.minutesPerHour;
    String pluralizeMinutes = minuteValue == 1 ? "" : "s";

    int hourValue = d.inHours;
    String pluralizeHours = d.inHours == 1 ? "" : "s";

    return "$hourValue hour$pluralizeHours, $minuteValue minute$pluralizeMinutes";
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      // width: double.infinity,
      width: 300,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          SizedBox(
            width: double.infinity,
            child: Container(
              height: _height,
              color: Colors.blue,
              child: Column(
                children: <Widget>[
                  Text("${widget.title}"),
                  Text("${toDurationText(_height)}"),
                ],
              ),
            ),
          ),
          Container(
            height: 20,
            child: GestureDetector(
              child: Container(
                color: Colors.green,
                alignment: Alignment.center,
              ),
              onVerticalDragUpdate: (details) {
                setState(() {
                  _height += details.delta.dy.round();
                });
              },
            ),
          )
        ],
      ),
    );
  }
}
