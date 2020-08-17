import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:functional_widget_annotation/functional_widget_annotation.dart';

import 'util/spring/spring_box.dart';
import 'util/spring/spring_translation_transition.dart';

part 'main.g.dart';

void main() {
  WidgetsApp.debugAllowBannerOverride = false;
  runApp(const App());
}

/// Root
@hwidget
Widget app() {
  final ValueNotifier<double> y = useState<double>(100);

  return MaterialApp(
    debugShowCheckedModeBanner: false,
    home: SafeArea(
      child: Scaffold(
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            y.value = y.value == 100 ? 200 : 100;
            // print(y.value);
          },
        ),
        body: Center(
          child: SpringTranslationTransition(
            toY: y.value,
            toX: 0,
            child: const SpringBox(
              description: 'Box',
            ),
          ),
        ),
      ),
    ),
  );
}
