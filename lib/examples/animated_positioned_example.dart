import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

void main(List<String> args) => runApp(const App());

class App extends HookWidget {
  const App({Key key});

  static const Duration duration = Duration(milliseconds: 500);
  static const Curve curve = Curves.easeOutBack;

  @override
  Widget build(BuildContext context) {
    final AnimationController controller =
        useAnimationController(duration: duration);
    final Animation<double> animation = Tween<double>(
      begin: 0,
      end: 300,
    )
        .chain(
          CurveTween(
            curve: curve,
          ),
        )
        .animate(controller);
    final ValueNotifier<bool> isDown = useState<bool>(false);
    final ValueNotifier<int> numBoxes = useState<int>(3);

    return MaterialApp(
      home: SafeArea(
        child: Scaffold(
          floatingActionButton: FloatingActionButton(
            onPressed: () {
              if (!isDown.value) {
                controller.forward();
                isDown.value = true;
              } else {
                controller.reverse();
                isDown.value = false;
              }
            },
          ),
          body: AnimatedBuilder(
            animation: animation,
            builder: (_, __) => Boxes(
              numBoxes: numBoxes.value,
              animation: animation,
            ),
          ),
        ),
      ),
    );
  }
}

class Boxes extends StatelessWidget {
  Boxes({
    @required this.numBoxes,
    @required this.animation,
  });

  final int numBoxes;
  final Animation<double> animation;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: List<Widget>.generate(
        numBoxes,
        (int index) => Positioned(
          top: (animation.value) + (index * (100 + 10)),
          left: (MediaQuery.of(context).size.width - 100) / 2,
          child: Container(
            width: 100,
            height: 100,
            color: Colors.blue,
          ),
        ),
      ),
      // ],
    );
  }
}
