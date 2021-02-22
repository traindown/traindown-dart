import "package:traindown/src/metadata.dart";
import "package:traindown/src/performance.dart";

/// Movement represents a single type of exercise or, well, movement.
/// A Movement has many Performances and a Session can have many Movements.
/// An example would simply be "Squats".
class Movement extends Metadatable {
  String name;
  List<Performance> performances = [];
  bool superSetted = false;

  Movement(String initName, {bool superset = false, String unit = Metadata.unknownUnit}) {
    name = initName.trim();
    superSetted = superset;
    unit = unit;
  }

  /// Adds a Performance and ensures the units align.
  void addPerformance(Performance performance) {
    if (performance.unit == Metadata.unknownUnit) {
      performance.unit = unit;
    }

    performances.add(performance);
  }

  /// Volume does not currently account for differing units per Performance.
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
