import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:functional_widget_annotation/functional_widget_annotation.dart';

import 'util/spring/spring_box.dart';
import 'util/spring/spring_transition.dart';

part 'main.g.dart';

void main(List<String> args) => runApp(const App());

/// Contains data about each box
class BoxData {
  /// Default Constructor
  BoxData({
    @required this.color,
    @required this.target,
    @required this.position,
    this.isDragging = false,
  });

  /// [Color] of the box
  Color color;

  /// Target of where the box should move
  double target;

  /// Position in list
  int position;

  /// Whether this element is being dragged, for suppressing animation if so
  bool isDragging;

  @override
  String toString() {
    final List<String> list = <String>[];

    // if (color == Colors.blue) {
    //   list.add('blue');
    // } else if (color == Colors.red) {
    //   list.add('red');
    // } else if (color == Colors.green) {
    //   list.add('green');
    // }

    list..add(target.toString())..add(position.toString());

    return list.toString();
  }
}

/// Default [Color] list
const List<Color> kColorList = <Color>[
  Colors.red,
  Colors.blue,
  Colors.green,
  Colors.orange,
  Colors.purple,
  Colors.brown,
  Colors.teal,
];

/// Number of boxes to generate
const int kNumBoxes = 10;

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
          body: Boxes(),
        ),
      ),
    );

/// Boxes to tap and drag
@hwidget
Widget boxes(
  BuildContext context,
) {
  final ValueNotifier<List<BoxData>> boxData = useState(
    List<BoxData>.generate(
      kNumBoxes,
      (int index) => BoxData(
        color: kColorList[index % kColorList.length],
        target: index * 100.0,
        position: index,
      ),
    ),
  );

  return SingleChildScrollView(
    child: Stack(
      children: <Widget>[
        Padding(
          padding: EdgeInsets.only(
            top: MediaQuery.of(context).size.height * 2,
            right: MediaQuery.of(context).size.width,
            left: MediaQuery.of(context).size.width,
          ),
        ),
        ...List<Widget>.generate(
          boxData.value.length,
          (int index) {
            final BoxData box = boxData.value[index];

            return SpringTransition(
              key: ValueKey<BoxData>(box),
              toX: (MediaQuery.of(context).size.width - 125) / 2,
              toY: box.target,
              suppressAnimation: box.isDragging,
              onTapDown: (_) {
                boxData.value = <BoxData>[
                  ...boxData.value

                    /// Move box to top of [Stack]
                    ..remove(box)
                    ..add(box)
                ];
              },
              onDragUpdate: (DragUpdateDetails details) {
                box
                  ..isDragging = true
                  ..target += details.primaryDelta;

                boxData.value = <BoxData>[
                  ...boxData.value

                    /// Move box to top of [Stack]
                    ..remove(box)
                    ..add(box)
                ];

                /// If not the last box in the list
                if (box.position < boxData.value.length - 1 &&
                    box.target > (100 * box.position) + 50) {
                  // TODO(satvikpendem): This sort might mess up the topology of the stack
                  final List<BoxData> data = boxData.value
                    ..sort((BoxData a, BoxData b) =>
                        a.position.compareTo(b.position));

                  /// Finds the box that should be below the dragging element but still above all others
                  BoxData secondaryBox;

                  secondaryBox = data.firstWhere((BoxData element) =>
                      element.position == box.position + 1);

                  data[box.position + 1]
                    ..target -= 100
                    ..position -= 1;
                  data[box.position].position += 1;

                  if (secondaryBox != null) {
                    /// Only reindex the secondary box after data's position has been set, not before
                    data
                      ..remove(secondaryBox)
                      ..add(secondaryBox);
                  }

                  boxData.value = <BoxData>[
                    ...data
                      ..remove(box)
                      ..add(box)
                  ];
                } else if (box.position > 0 &&
                    box.target <= (100 * box.position) - 50) {
                  final List<BoxData> data = boxData.value
                    ..sort((BoxData a, BoxData b) =>
                        a.position.compareTo(b.position));

                  List<BoxData> secondaryBoxes;

                  secondaryBoxes = data
                      .where((BoxData element) =>
                          element.position >= box.position - 1)
                      .toList();

                  data[box.position - 1]
                    ..target += 100
                    ..position += 1;
                  data[box.position].position -= 1;

                  /// Only reindex the secondary boxes after data's position has been set, not before
                  if (secondaryBoxes.isNotEmpty) {
                    /// Since we always add to the end of the stack, there is an issue when moving up.
                    /// The issue occurs when a box is dragged up rather than down, as when going down, the stack
                    /// behavior works fine, as we always add to the end of the stack. However, when we move up,
                    /// we must actually insert in reverse order as otherwise the items in the last position get 
                    /// the higher stack value.
                    secondaryBoxes.reversed.forEach((BoxData secondaryBox) {
                      data
                        ..remove(secondaryBox)
                        ..add(secondaryBox);
                    });
                  }

                  boxData.value = <BoxData>[
                    ...data
                      ..remove(box)
                      ..add(box)
                  ];
                }
              },
              onDragEnd: (_) {
                box
                  ..isDragging = false
                  ..target = 100.0 * box.position;
                boxData.value = <BoxData>[...boxData.value];
              },
              child: SpringBox(
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

/// Box
// @hwidget
// Widget box(
//   BuildContext context, {
//   @required int index,
//   @required double target,
// }) =>
//     SpringTransition(
//       scaleFinalValue: 2,
//       toX: (MediaQuery.of(context).size.width - 125) / 2,
//       toY: target,
//       child: SpringBox(color: colors[index]),
//     );
