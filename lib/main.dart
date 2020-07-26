import 'package:flutter/material.dart';

import 'examples/spring_scale_example.dart';
import 'util/spring/spring_scale_transition.dart';

void main() {
  WidgetsApp.debugAllowBannerOverride = false;
  runApp(const App());
}

/// App start
class App extends StatelessWidget {
  /// Constructor
  const App({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) => MaterialApp(
        theme: ThemeData(
          primarySwatch: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        home: const SafeArea(
          child: Scaffold(
            body: DragStack(),
          ),
        ),
      );
}

class DragStack extends StatefulWidget {
  const DragStack({
    Key key,
  }) : super(key: key);

  @override
  _DragStackState createState() => _DragStackState();
}

class _DragStackState extends State<DragStack> with TickerProviderStateMixin {
  static const double maxSlide = 1000;

  AnimationController dragController;

  @override
  void initState() {
    super.initState();
    dragController = AnimationController(
      vsync: this,
      duration: const Duration(),
    );
  }

  void onVerticalDragUpdate(DragUpdateDetails details) {
    dragController.value += details.primaryDelta / maxSlide;
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: dragController,
      builder: (context, child) {
        final double slide = maxSlide * dragController.value;

        print(slide);
        return Stack(
          alignment: Alignment.topCenter,
          children: <Widget>[
            Padding(
              /// Stack will size itself around the first non-positioned child, if it has one.
              /// Therefore, we need padding at least up to the height of the viewport,
              /// otherwise the elements won't show up
              ///
              /// https://stackoverflow.com/questions/50155840/can-should-stack-expand-its-size-to-its-positioned-children
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).size.height,
                right: MediaQuery.of(context).size.width,
                left: MediaQuery.of(context).size.width,
              ),
            ),
            Transform(
              /// Transform must be first in the widget tree as otherwise the gesture will stay in the same place
              /// while the child appears to be moving
              transform: Matrix4.identity()
                ..translate(
                  0,
                  slide,
                ),
              child: GestureDetector(
                onVerticalDragUpdate: onVerticalDragUpdate,
                child: SpringScaleTransition(
                  child: const SpringBox(
                    description: 'Test',
                  ),
                ),
              ),
            )
          ],
        );
      },
    );
  }
}
