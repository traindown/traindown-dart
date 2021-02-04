import "package:traindown/src/metadata.dart";
import "package:traindown/src/performance.dart";

class Movement extends Metadatable {
  String name;
  List<Performance> performances = [];
  bool superSetted = false;

  Movement(String initName, [bool superset = false]) {
    name = initName.trim();
    superSetted = superset;
  }

  double get volume => performances.fold(0, (acc, p) => acc + p.volume);

  String get _metadata {
    if (metadata.kvps.entries.isEmpty) {
      return '';
    }
    StringBuffer ret = StringBuffer();
    for (var mapEntry in metadata.kvps.entries) {
      ret.write('  ${mapEntry.key}: ${mapEntry.value}\n');
    }
    return '\n$ret\n';
  }

  String get _notes {
    if (metadata.notes.isEmpty) {
      return '';
    }
    StringBuffer ret = StringBuffer();
    for (var note in metadata.notes) {
      ret.write('  - $note\n');
    }
    return '\n$ret';
  }

  @override
  String toString() {
    String maybePlus = superSetted ? "[Super Set] " : "";
    return "$maybePlus$name:$_notes$_metadata\n  ${performances.join('\n  ')}\n";
  }
}
