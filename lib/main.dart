import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';

import 'examples/spring_scale_example.dart';
import 'util/spring/spring_scale_transition.dart';

const double kMaxSlide = 1000;
const SpringDescription springDescription = const SpringDescription(
  mass: 3,
  stiffness: 200,
  damping: 3,
);

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
  double height;
  int index;

  BoxData({this.color, this.height, this.index});
}

class _DragStackState extends State<DragStack> with TickerProviderStateMixin {
  List<BoxData> boxes = <BoxData>[
    BoxData(color: Colors.red, height: 100, index: 0),
    BoxData(color: Colors.blue, height: 300, index: 0),
    BoxData(color: Colors.green, height: 200, index: 0),
  ];

  List<AnimationController> controllers;

  @override
  void initState() {
    super.initState();
    controllers = List<AnimationController>.generate(
      boxes.length,
      (int index) => AnimationController(
        duration: const Duration(milliseconds: 500),
        vsync: this,
        // upperBound: double.infinity,
        // lowerBound: double.negativeInfinity,
      )..value =

          /// Set the [AnimationController] initial value to be the sum of all
          /// of the previous boxes' height
          boxes.sublist(0, index).fold<double>(
                  0,
                  (double previousValue, BoxData element) =>
                      previousValue + element.height) /
              kMaxSlide,
    );
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
            final double value = controller.value * kMaxSlide;

            return AnimatedBuilder(
              key: ValueKey<BoxData>(box),
              animation: controller,
              builder: (BuildContext context, Widget child) {
                return Transform(
                  transform: Matrix4.translationValues(
                    0,
                    value,
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

                        // final List<BoxData> indices = <BoxData>[...boxes]..sort(
                        //     (BoxData a, BoxData b) =>
                        //         a.index.compareTo(b.index));

                        // print(indices);

                        // final double previousHeight = boxes
                        //         // TODO(satvikpendem): sublist is wrong here, must be on a position list
                        //         .sublist(0, index)
                        //         .fold<double>(
                        //             0,
                        //             (double previousValue, BoxData element) =>
                        //                 previousValue + element.height) +
                        //     (box.height / 2);

                        if (value >= 150) {
                          // final initialValue = controllers[0].value;
                          // controllers[0].animateWith(
                          //   SpringSimulation(
                          //     springDescription,
                          //     initialValue,
                          //     0,
                          //     0,
                          //   ),
                          // );
                          controllers[0].animateTo(0);
                        } else {
                          // final endValue = controllers[0].value;
                          // controllers[0].animateWith(
                          //   SpringSimulation(
                          //     springDescription,
                          //     box.height / kMaxSlide,
                          //     endValue,
                          //     0,
                          //   ),
                          // );
                          controllers[0].animateTo(0.1);
                        }
                      });
                    },
                    child: SpringBox(
                      description:
                          'Cont: ${controller.value.toStringAsFixed(3)}\nHeight: ${box.height}\nPos: ${value.round()}\ni: $index',
                      height: box.height,
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
