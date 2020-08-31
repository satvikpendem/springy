extension ListManipulation<T> on List<T> {
  List<T> moveToEnd(T element) => this
    ..remove(element)
    ..add(element);
}
