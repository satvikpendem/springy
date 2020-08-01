import 'package:flutter/material.dart';

void main() {
  WidgetsApp.debugAllowBannerOverride = false;
  runApp(const App());
}

class App extends StatelessWidget {
  const App({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) => MaterialApp(
        theme: ThemeData(
          primarySwatch: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        home: SafeArea(
          child: Scaffold(
            body: DragStack(),
          ),
        ),
      );
}

class DragStack extends StatefulWidget {
  DragStack({Key key}) : super(key: key);

  @override
  _DragStackState createState() => _DragStackState();
}

class BoxData {
  Color color;
  double y = 0;
  int index = 0;

  BoxData(this.color);
}

class _DragStackState extends State<DragStack> {
  List<BoxData> boxes = <BoxData>[
    BoxData(Colors.red),
    BoxData(Colors.blue),
    BoxData(Colors.green)
  ];

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.topCenter,
      children: <Widget>[
        Padding(
          padding: EdgeInsets.only(
            top: MediaQuery.of(context).size.height,
            right: MediaQuery.of(context).size.width,
            left: MediaQuery.of(context).size.width,
          ),
        ),
        ...boxes.map((x) {
          final BoxData box = x;
          return Positioned(
            key: ValueKey<BoxData>(x),
            top: x.y,
            child: GestureDetector(
              onVerticalDragStart: (DragStartDetails details) => {
                setState(() {
                  boxes
                    ..remove(x)
                    ..add(x);
                })
              },
              onVerticalDragUpdate: (DragUpdateDetails details) {
                setState(() {
                  box.y += details.primaryDelta;
                });
              },
              child: Container(
                color: x.color,
                width: 100,
                height: 100,
              ),
            ),
          );
        }),
      ],
    );
  }
}
