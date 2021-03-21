import 'package:flutter/foundation.dart';
import '../main.dart';

/// Use isolates to generate list of Box positions
class PositionList {
  PositionList._internal({@required this.list, @required this.position});

  /// @deprecated
  static Future<PositionList> create(
      {@required List<Box> list, @required int position}) async {
    final List<Box> positions = await compute(_sortList, list);

    final PositionList positionList = PositionList._internal(
      list: list,
      position: position,
    )
      ..positions = positions
      ..sublist = positions.sublist(0, position);

    return positionList;
  }

  static List<Box> _sortList(List<Box> list) =>
      list.toList()..sort((Box a, Box b) => a.position.compareTo(b.position));

  List<Box> list;
  int position;
  List<Box> positions;
  List<Box> sublist;
}
