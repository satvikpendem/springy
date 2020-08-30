import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:functional_widget_annotation/functional_widget_annotation.dart';

import 'util/spring/spring_box.dart';
import 'util/spring/spring_transition.dart';

part 'main.g.dart';

void main(List<String> args) => runApp(const App());

/// Contains data about each [Box]
class BoxData {
  /// Default Constructor
  BoxData({
    @required this.color,
    @required this.target,
    @required this.index,
  });

  /// [Color] of the box
  Color color;

  /// Target of where the box should move
  double target;

  /// Position in list
  int index;

  @override
  String toString() {
    final List<String> list = <String>[];

    if (color == Colors.blue) {
      list.add('blue');
    } else if (color == Colors.red) {
      list.add('red');
    } else if (color == Colors.green) {
      list.add('green');
    }

    list.add(target.toString());

    return list.toString();
  }
}

/// Default [Color] list
const List<Color> colors = <Color>[
  Colors.red,
  Colors.blue,
  Colors.green,
];

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
  final ValueNotifier<List<BoxData>> boxData = useState(<BoxData>[
    BoxData(color: Colors.red, target: 0, index: 0),
    BoxData(color: Colors.blue, target: 100, index: 1),
    BoxData(color: Colors.green, target: 200, index: 2),
  ]);

  final ValueNotifier<bool> isDragging = useState<bool>(false);

  return Stack(
    children: <Widget>[
      Padding(
        padding: EdgeInsets.only(
          top: MediaQuery.of(context).size.height,
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
            suppressAnimation: isDragging.value,
            onTapDown: (_) {
              boxData.value = <BoxData>[
                ...boxData.value
                  ..remove(box)
                  ..add(box)
              ];
            },
            onDragUpdate: (DragUpdateDetails details) {
              isDragging.value = true;

              box.target += details.primaryDelta;

              boxData.value = <BoxData>[
                ...boxData.value
                  ..remove(box)
                  ..add(box)
              ];

              /// If not the last box in the list
              if (box.index != boxData.value.length - 1) {
                if (box.target > (100 * box.index) + 50) {
                  final List<BoxData> tempData = boxData.value.toList()
                    ..sort(
                        (BoxData a, BoxData b) => a.index.compareTo(b.index));
                  tempData[box.index + 1].target -= 100;
                  tempData[box.index + 1].index -= 1;
                  tempData[box.index].index += 1;

                  boxData.value = <BoxData>[...tempData];
                }
              }
            },
            onDragEnd: (_) {
              box.target = 300;
              boxData.value = <BoxData>[...boxData.value];
            },
            child: SpringBox(
                description: 'T: $index, P: ${box.index}', color: box.color),
          );
        },
      ),
    ],
  );
}

/// Box
@hwidget
Widget box(
  BuildContext context, {
  @required int index,
  @required double target,
}) =>
    SpringTransition(
      scaleFinalValue: 2,
      toX: (MediaQuery.of(context).size.width - 125) / 2,
      toY: target,
      child: SpringBox(color: colors[index]),
    );
