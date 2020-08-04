import 'package:flutter/material.dart';

import 'examples/spring_scale_example.dart';
import 'util/spring/spring_scale_transition.dart';

const double kMaxSlide = 1000;

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
  BoxData(this.color);
}

class _DragStackState extends State<DragStack> with TickerProviderStateMixin {
  List<BoxData> boxes = <BoxData>[
    BoxData(Colors.red),
    BoxData(Colors.blue),
    BoxData(Colors.green),
  ];

  List<AnimationController> controllers;

  @override
  void initState() {
    super.initState();
    controllers = boxes
        .map(
          (BoxData e) => AnimationController(
            duration: const Duration(),
            vsync: this,
          ),
        )
        .toList();
  }

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
        ...List<AnimatedBuilder>.generate(
          boxes.length,
          (int index) {
            final BoxData box = boxes[index];
            final AnimationController controller = controllers[index];

            return AnimatedBuilder(
              key: ValueKey<BoxData>(box),
              animation: controller,
              builder: (BuildContext context, Widget child) {
                return Transform(
                  transform: Matrix4.translationValues(
                    0,
                    controller.value * kMaxSlide,
                    0,
                  ),
                  child: SpringScaleTransition(
                    maxScaleFactor: 0.1,
                    onDragStart: (DragStartDetails details) {
                      setState(() {
                        boxes
                          ..remove(box)
                          ..add(box);
                        controllers
                          ..remove(controller)
                          ..add(controller);
                      });
                    },
                    onDragUpdate: (DragUpdateDetails details) {
                      setState(() {
                        controllers[index].value +=
                            details.primaryDelta / kMaxSlide;
                      });
                    },
                    child: SpringBox(
                      description: 'Box',
                      color: box.color ?? Colors.blue,
                    ),
                  ),
                );
              },
            );
          },
        )
      ],
    );
  }
}
