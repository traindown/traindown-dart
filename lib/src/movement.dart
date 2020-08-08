import "package:traindown/src/metadata.dart";
import "package:traindown/src/performance.dart";

class Movement extends Metadatable {
  @override
  Metadata metadata = Metadata();
  String name;
  List<Performance> performances = [];
  bool superSetted = false;

  Movement(String initName) : name = initName.trim();

  int get volume => performances.fold(0, (acc, p) => acc + p.volume);

  @override
  String toString() {
    String maybePlus = superSetted ? "[Super Set] " : "";
    return "$maybePlus$name:\n  ${performances.join('\n  ')}\n";
  }
}
