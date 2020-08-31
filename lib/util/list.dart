/// Methods to manuipulate elements in a list in a functional way
extension ListManipulation<T> on List<T> {
  /// Move [element] to end of list by removing and readding it
  List<T> moveToEnd(T element) => this
    ..remove(element)
    ..add(element);
}
