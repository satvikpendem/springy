// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'main.dart';

// **************************************************************************
// FunctionalWidgetGenerator
// **************************************************************************

/// App
class App extends HookWidget {
  /// App
  const App({Key key}) : super(key: key);

  @override
  Widget build(BuildContext _context) => app();
}

class Boxes extends HookWidget {
  const Boxes({Key key, this.targets}) : super(key: key);

  final List<double> targets;

  @override
  Widget build(BuildContext _context) => boxes(_context, targets: targets);
}

/// Box
class Box extends HookWidget {
  /// Box
  const Box({Key key, @required this.index, @required this.target})
      : super(key: key);

  /// Box
  final int index;

  /// Box
  final double target;

  @override
  Widget build(BuildContext _context) =>
      box(_context, index: index, target: target);
}
