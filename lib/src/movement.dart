import "package:traindown/src/metadata.dart";
import "package:traindown/src/performance.dart";

class Movement implements Metadatable {
  Metadata metadata = Metadata();
  String name;
  List<Performance> performances = [];

  Movement(this.name);

  @override
  String toString() {
    return "$name:\n  ${performances.join('\n  ')}\n";
  }
}
