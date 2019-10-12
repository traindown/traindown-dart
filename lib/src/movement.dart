import "./performance.dart";

class Movement {
  String name;
  List<Performance> performances = [];

  Movement(this.name);

  @override String toString() {
    return "$name:\n  ${performances.join('\n  ')}\n";
  }
}
