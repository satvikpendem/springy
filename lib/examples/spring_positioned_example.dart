import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:functional_widget_annotation/functional_widget_annotation.dart';

import '../util/spring/spring_animation_hook.dart';
import '../util/spring/spring_box.dart';
import '../util/spring/spring_scale_transition.dart';

part 'spring_positioned_example.g.dart';

void main(List<String> args) => runApp(const App());

@hwidget
Widget app() {
  final SpringAnimation springAnimator = useSpringAnimation();
  final ValueNotifier<bool> isDown = useState<bool>(false);
  final ValueNotifier<int> numBoxes = useState<int>(3);

  return MaterialApp(
    home: SafeArea(
      child: Scaffold(
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            if (!isDown.value) {
              springAnimator.run(0, 1);
              isDown.value = true;
            } else {
              springAnimator.run(1, 0);
              isDown.value = false;
            }
          },
        ),
        body: Boxes(numBoxes: numBoxes.value, springAnimator: springAnimator),
      ),
    ),
  );
}

@hwidget
Widget boxes({int numBoxes, SpringAnimation springAnimator}) {
  return SingleChildScrollView(
    child: Stack(children: <Widget>[
      Padding(
        padding: EdgeInsets.only(
          top: MediaQuery.of(useContext()).size.height * 2,
          right: MediaQuery.of(useContext()).size.width,
          left: MediaQuery.of(useContext()).size.width,
        ),
      ),
      ...List<Widget>.generate(
        numBoxes,
        (int index) => Positioned(
          top: (springAnimator.controller.value * 100) + (index * (100 + 10)),
          left: (MediaQuery.of(useContext()).size.width - 100) / 2,
          child: SpringScaleTransition(
            child: SpringBox(
              description: 'Hello',
              color: [Colors.blue, Colors.red, Colors.green].elementAt(index),
            ),
          ),
        ),
      ),
    ]),
  );
}
