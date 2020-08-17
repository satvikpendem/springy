import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:functional_widget_annotation/functional_widget_annotation.dart';

import 'spring_animation_hook.dart';
import 'spring_box.dart';
import 'spring_scale_transition.dart';

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
        body: Boxes(numBoxes: numBoxes, springAnimator: springAnimator),
      ),
    ),
  );
}

class Boxes extends HookWidget {
  const Boxes({
    Key key,
    @required this.numBoxes,
    @required this.springAnimator,
  }) : super(key: key);

  final ValueNotifier<int> numBoxes;
  final SpringAnimation springAnimator;

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
        child: Stack(children: <Widget>[
          Padding(
            padding: EdgeInsets.only(
              top: MediaQuery.of(useContext()).size.height * 2,
              right: MediaQuery.of(useContext()).size.width,
              left: MediaQuery.of(useContext()).size.width,
            ),
          ),
          ...List<Widget>.generate(
            numBoxes.value,
            (int index) => Positioned(
              top: (springAnimator.controller.value * 100) +
                  (index * (100 + 10)),
              // right: MediaQuery.of(useContext()).size.width - 100 / 2,
              left: (MediaQuery.of(useContext()).size.width - 100) / 2,
              child: SpringScaleTransition(
                child: SpringBox(
                  description: 'Hello',
                  color:
                      [Colors.blue, Colors.red, Colors.green].elementAt(index),
                ),
              ),
            ),
          ),
        ]),
      );
}
