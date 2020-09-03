import 'dart:math';
import 'package:collection/collection.dart';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:functional_widget_annotation/functional_widget_annotation.dart';

import 'util/extensions/list.dart';
import 'util/spring/expandable_spring_box.dart';
import 'util/spring/spring_transition.dart';

part 'main.g.dart';

void main(List<String> args) => runApp(const App());

/// Contains data about each box
class Box {
  /// Default Constructor
  Box({
    @required this.target,
    @required this.position,
    this.height = 100,
    this.color = Colors.blue,
    this.isDragging = false,
    this.initialScale = 1,
    this.finalScale = 1.1,
  });

  /// [Color] of the box
  Color color;

  /// Target of where the box should move
  double target;

  /// Position in list
  int position;

  /// Height of element
  double height;

  /// Whether this element is being dragged, for suppressing animation if so
  bool isDragging;

  /// The initial scale value when dragging
  double initialScale;

  /// The final scale value when dragging
  double finalScale;

  @override
  String toString() {
    final List<String> list = <String>[target.toString(), position.toString()];

    return list.toString();
  }
}

/// Default [Color] list
const List<Color> kColorList = <Color>[
  Colors.red,
  Colors.orange,
  Colors.yellow,
  Colors.green,
  Colors.blue,
  Colors.indigo,
  Colors.purple,
];

/// Number of boxes to generate
const int kNumBoxes = 10;

/// Max width to use for boxes
const double kMaxWidth = 300;

/// Initial height list
const List<double> kHeightList = <double>[100, 200, 300];

/// List equality function
bool Function(List<double> list1, List<double> list2) eq =
    const ListEquality<double>().equals;

/// App
@hwidget
Widget app() => MaterialApp(
      theme: ThemeData.dark().copyWith(
        backgroundColor: Colors.black,
        scaffoldBackgroundColor: Colors.black,
        accentColor: const Color(0xFF6600FF),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          foregroundColor: Color(0xFF6600FF),
        ),
      ),
      home: const SafeArea(
        child: Scaffold(
          body: Center(
            child: Boxes(),
          ),
        ),
      ),
    );

/// Boxes to tap and drag
@hwidget
Widget boxes(BuildContext context) {
  double sumHeight(List<Box> list) => list.fold<double>(
      0, (double previousValue, Box element) => previousValue + element.height);

  List<Box> generateBoxList() {
    /// Keep track of overall height
    double cumulativeHeight = 0;

    return List<Box>.generate(
      kNumBoxes,
      (int index) => Box(
        color: kColorList[index % kColorList.length],

        /// Initially set the [target] to 0
        target: 0,
        position: index,
        height: kHeightList[index % kHeightList.length],
      ),
    )..map((Box element) {
        /// Set the box's [target] to be the [cumulativeHeight] so far, and increment it
        element.target = cumulativeHeight;
        cumulativeHeight += element.height;
      }).toList();
  }

  final ValueNotifier<List<Box>> boxList =
      useState<List<Box>>(generateBoxList());

  void handleTapDown(Box box) {
    boxList.value = <Box>[
      /// Move box to top of [Stack]
      ...boxList.value.moveToEnd(box)
    ];
  }

  void handleDragEnd(Box box) {
    final List<Box> positions = boxList.value.toList()
      ..sort((Box a, Box b) => a.position.compareTo(b.position));

    box
      ..isDragging = false
      ..target = sumHeight(positions.sublist(0, box.position));
    boxList.value = <Box>[...boxList.value];
  }

  void handleDragUpdate(DragUpdateDetails details, Box box, int index) {
    box
      ..isDragging = true
      ..target += details.primaryDelta;

    boxList.value = <Box>[
      /// Move box to top of [Stack]
      ...boxList.value.moveToEnd(box)
    ];

    List<Box> data;

    List<Box> secondaryBoxes;

    double targetChange = box.height;
    int positionChange = 1;

    final List<Box> positions = boxList.value.toList()
      ..sort((Box a, Box b) => a.position.compareTo(b.position));

    final List<Box> sub = positions.sublist(0, box.position);

    /// Moving down
    /// If not the last box in the list
    if (box.position < boxList.value.length - 1 &&
        box.target > sumHeight(sub) + positions[box.position + 1].height / 2) {
      data = boxList.value
        ..sort((Box a, Box b) => a.position.compareTo(b.position));

      /// Finds boxes that should be topologically below the dragging element but still above all others
      secondaryBoxes = data
          .where((Box element) =>
              element.position <= box.position + positionChange)
          .toList();

      targetChange = -targetChange;
      positionChange = -positionChange;
    }

    /// Moving up
    /// If not the first box in the list
    else if (box.position > 0 &&
        box.target <= sumHeight(sub) - positions[box.position - 1].height / 2) {
      data = boxList.value
        ..sort((Box a, Box b) => a.position.compareTo(b.position));

      /// Finds boxes that should be topologically below the dragging element but still above all others
      ///
      /// Since we always add to the end of the stack, there is an issue when moving up.
      /// The issue occurs when a box is dragged up rather than down, as when going down, the stack
      /// behavior works fine, as we always add to the end of the stack. However, when we move up,
      /// we must actually insert in reverse order as otherwise the items in the last position get
      /// the higher stack value.
      secondaryBoxes = data
          .where((Box element) =>
              element.position >= box.position - positionChange)
          .toList()
          .reversed
          .toList();
    }

    if (data != null && data.isNotEmpty) {
      /// When moving down, [positionChange] is -1, so in effect, box.position - positionChange becomes
      /// box.position + 1, meaning we change the properties of the next box, and when moving up,
      /// [positionChange] becomes (or rather, stays at) -1, changing the properties of the previous box.
      data[box.position - positionChange]
        ..target += targetChange
        ..position += positionChange;
      data[box.position].position -= positionChange;

      /// Only reindex the secondary boxes after data's position has been set, not before
      if (secondaryBoxes != null && secondaryBoxes.isNotEmpty) {
        secondaryBoxes.forEach(data.moveToEnd);
      }

      boxList.value = <Box>[...data.moveToEnd(box)];
    }
  }

  return SingleChildScrollView(
    physics:
        const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
    child: Stack(
      children: <Widget>[
        Padding(
          padding: EdgeInsets.only(
            top: MediaQuery.of(context).size.height * 2,
            left: MediaQuery.of(context).size.width,
          ),
        ),
        ...List<Widget>.generate(
          boxList.value.length,
          (int index) {
            final Box box = boxList.value[index];
            final double width =
                max(MediaQuery.of(context).size.width / 2, kMaxWidth);

            return SpringTransition(
              key: ValueKey<Box>(box),
              finalScale: box.finalScale,
              toX: (MediaQuery.of(context).size.width - width) / 2,
              toY: box.target,
              suppressAnimation: box.isDragging,
              onTapDown: (_) => handleTapDown(box),
              onDragStart: (_) => handleTapDown(box),
              onDragUpdate: (DragUpdateDetails details) =>
                  handleDragUpdate(details, box, index),
              onDragEnd: (_) => handleDragEnd(box),
              child: ExpandableSpringBox(
                  onDragUpdate: (DragUpdateDetails details) {
                    // print('dragging');
                    box
                      ..isDragging = true
                      ..finalScale = 1
                      ..height += details.primaryDelta;

                    /// Move box to top of [Stack]
                    boxList.value = <Box>[...boxList.value.moveToEnd(box)];

                    final List<Box> data = boxList.value.toList()
                      ..sort(
                          (Box a, Box b) => a.position.compareTo(b.position));

                    if (box.position < boxList.value.length - 1) {
                      for (int i = box.position + 1; i < data.length; i++) {
                        data[i].isDragging = true;
                        data[i].target += details.primaryDelta;
                      }
                    }
                  },
                  onDragEnd: (DragEndDetails details) {
                    box
                      ..isDragging = false
                      ..finalScale = 1.1;

                    for (int i = 0; i < boxList.value.length; i++) {
                      boxList.value[i].isDragging = false;
                    }

                    boxList.value = <Box>[...boxList.value];
                  },
                  suppressAnimation: box.isDragging,
                  height: box.height,
                  width: width,
                  description:
                      'I: $index, P: ${box.position}, T: ${box.target.round()}',
                  color: box.color),
            );
          },
        ),
      ],
    ),
  );
}
