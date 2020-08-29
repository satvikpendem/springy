import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:functional_widget_annotation/functional_widget_annotation.dart';

import 'util/spring/spring_box.dart';
import 'util/spring/spring_transition.dart';

part 'main.g.dart';

void main(List<String> args) => runApp(const App());

class BoxData {
  BoxData({
    @required this.color,
    @required this.target,
    // @required this.index,
  });

  Color color;
  double target;
  // int index;

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

    return list.toString();
  }
}

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

@hwidget
Widget boxes(
  BuildContext context,
) {
  final ValueNotifier<List<BoxData>> boxData = useState(<BoxData>[
    BoxData(color: Colors.red, target: 0),
    BoxData(color: Colors.blue, target: 110),
    BoxData(color: Colors.green, target: 220),
  ]);

  useEffect(() {
    print(boxData);
    return;
  }, [boxData.value]);

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
            scaleFinalValue: 2,
            toX: (MediaQuery.of(context).size.width - 125) / 2,
            toY: box.target,
            onTapDown: (_) {
              boxData.value = [
                ...boxData.value
                  ..remove(box)
                  ..add(box)
              ];
            },
            onDragUpdate: (DragUpdateDetails details) {
              boxData.value = [
                ...boxData.value
                  ..removeAt(index)
                  ..insert(
                    index,
                    BoxData(
                      color: box.color,
                      target: box.target + details.primaryDelta,
                    ),
                  ),
              ];
              print(box.target);
            },
            child: SpringBox(color: colors[index]),
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
