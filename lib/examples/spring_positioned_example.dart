import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:functional_widget_annotation/functional_widget_annotation.dart';

import '../util/spring/spring_box.dart';
import '../util/spring/spring_scale_transition.dart';

part 'spring_positioned_example.g.dart';

void main(List<String> args) => runApp(const App());

/// App
@hwidget
Widget app() {
  final ValueNotifier<bool> isDown = useState(false);
  final ValueNotifier<List<double>> targets = useState<List<double>>(
    <double>[
      100,
      200,
      300,
    ],
  );

  useEffect(() {
    targets.value =
        isDown.value ? <double>[520, 410, 300] : <double>[0, 110, 220];
    return;
  }, <bool>[isDown.value]);

  return MaterialApp(
    home: SafeArea(
      child: Scaffold(
        floatingActionButton: FloatingActionButton(
          onPressed: () => isDown.value = !isDown.value,
        ),
        body: Boxes(targets: targets),
      ),
    ),
  );
}

class Boxes extends StatelessWidget {
  const Boxes({
    Key key,
    @required this.targets,
  }) : super(key: key);

  final ValueNotifier<List<double>> targets;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Padding(
          padding: EdgeInsets.only(
            top: MediaQuery.of(context).size.height,
            right: MediaQuery.of(context).size.width,
            left: MediaQuery.of(context).size.width,
          ),
        ),
        ...List<Box>.generate(
          targets.value.length,
          (int index) => Box(
            index: index,
            target: targets.value.elementAt(index),
          ),
        ),
      ],
    );
  }
}

/// Box
@hwidget
Widget box(
  BuildContext context, {
  @required int index,
  @required double target,
}) =>
    SpringScaleTransition(
      scaleFinalValue: 2,
      toX: MediaQuery.of(context).size.width / 2,
      toY: target,
      child: SpringBox(
        description: 'Hello',
        color: <Color>[
          Colors.blue,
          Colors.red,
          Colors.green,
        ].elementAt(index),
      ),
    );