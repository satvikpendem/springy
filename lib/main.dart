import 'package:flutter/material.dart';

import 'examples/spring_scale_example.dart';
import 'util/spring/spring_scale_transition.dart';

void main() {
  WidgetsApp.debugAllowBannerOverride = false;
  runApp(const App());
}

const double kMaxSlide = 1000;

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
  List<AnimationController> dragControllers;
  List<String> dragKeys;
  static const int controllerLength = 2;

  @override
  void initState() {
    super.initState();
    dragControllers = List<AnimationController>.generate(
      controllerLength,
      (int index) => AnimationController(
        vsync: this,
        duration: const Duration(),
      ),
    );
    dragKeys = List<String>.generate(
        controllerLength, (int index) => index.toString());
  }

  void onVerticalDragStart(
    DragStartDetails details,
    AnimationController dragController,
    int index,
  ) {
    setState(() {
      final AnimationController draggingElement =
          dragControllers.removeAt(index);
      dragControllers.add(draggingElement);

      // final String draggingKey = dragKeys.removeAt(index);
      // dragKeys.insert(0, draggingKey);
    });

    print(index);
    print(dragControllers);
  }

  void onVerticalDragUpdate(
    DragUpdateDetails details,
    AnimationController dragController,
  ) {
    // TODO(satvikpendem): Don't make function depend on the constant maxSlide value, `kMaxSlide`
    dragController.value += details.primaryDelta / kMaxSlide;
  }

  List<DragContainer> buildList() => List<DragContainer>.generate(
        dragControllers.length,
        (int index) => DragContainer(
          // key: Key(['a', 'b', 'c'][index]),
          index: index,
          dragController: dragControllers[index],
          maxSlide: kMaxSlide,
          onVerticalDragUpdate: onVerticalDragUpdate,
          onVerticalDragStart: onVerticalDragStart,
          // color: <Color>[Colors.blue, Colors.red, Colors.green][index],
        ),
      );

  @override
  Widget build(BuildContext context) {
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
        // SpringBox(
        //   description: "Test",
        // ),
        ...buildList()
      ],
    );
  }
}

class DragContainer extends StatelessWidget {
  const DragContainer({
    Key key,
    @required this.dragController,
    @required this.maxSlide,
    @required this.onVerticalDragUpdate,
    @required this.onVerticalDragStart,
    @required this.index,
    this.color,
  }) : super(key: key);

  final AnimationController dragController;
  final double maxSlide;

  final void Function(
    DragUpdateDetails details,
    AnimationController controller,
  ) onVerticalDragUpdate;

  final void Function(
    DragStartDetails details,
    AnimationController controller,
    int index,
  ) onVerticalDragStart;

  final int index;

  final Color color;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: dragController,
      builder: (BuildContext context, Widget child) => Transform(
        /// Transform must be first in the widget tree as otherwise the gesture will stay in the same place
        /// while the child appears to be moving
        transform: Matrix4.identity()
          ..translate(
            /// [Transform]s' `x` must always be a `double` as it's normally `dynamic`
            0.0,
            maxSlide * dragController.value,
          ),
        child: SpringScaleTransition(
          onDragStart: (DragStartDetails details) =>
              onVerticalDragStart(details, dragController, index),
          onDragUpdate: (DragUpdateDetails details) =>
              onVerticalDragUpdate(details, dragController),
          child: SpringBox(
            description: 'Test',
            color: color ?? Colors.blue,
          ),
        ),
      ),
    );
  }
}
