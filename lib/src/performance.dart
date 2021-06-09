import 'package:traindown/src/metadata.dart';

/// Performance represents a single expression of movement. It can be as little
/// as a single or as much as needed. Each Performance *must* have a load
/// otherwise it is somewhat nonsensical. Outside that, a Performance may have
/// a count of repititions performed for the given load, a count of sets of
/// reps, a count of failed reps, and a unit for the load.
class Performance extends Metadatable {
  double fails;
  double? load;
  double sets;
  double reps;

  /// List of getters/setters on the class used for dynamic access without
  /// the use of Mirrors.
  static List<String> attrs = ['fails', 'load', 'sets', 'reps'];

  Performance(
      {this.fails = 0,
      this.load = -1,
      this.sets = 1,
      this.reps = 1,
      String unit = Metadata.unknownUnit}) {
    load = load! < 0 ? null : load;
    if (unit != Metadata.unknownUnit) this.unit = unit;
  }

  /// Simple accessors that do not require Mirrors.
  void operator []=(String attr, double value) {
    if (!attrs.contains(attr)) throw 'Invalid attr';

    switch (attr) {
      case 'fails':
        fails = value;
        break;
      case 'load':
        load = value;
        break;
      case 'sets':
        sets = value;
        break;
      case 'reps':
        reps = value;
        break;
    }
    ;
  }

  String get _metadata {
    if (kvps.entries.isEmpty) {
      return '';
    }
    StringBuffer ret = StringBuffer();
    for (var mapEntry in kvps.entries) {
      ret.write('    ${mapEntry.key}: ${mapEntry.value}\n');
    }
    return '\n$ret\n';
  }

  String get _notes {
    if (notes.isEmpty) {
      return '';
    }
    StringBuffer ret = StringBuffer();
    for (var note in notes) {
      ret.write('    - $note\n');
    }
    return '\n$ret\n';
  }

  double get successfulReps => reps - fails;

  String get _summary {
    String failures = fails > 0
        ? ' with $fails failures ($successfulReps successful reps)'
        : '';
    String loadStr = load != null ? "$load" : "unknown load";

    if (unit.isNotEmpty) {
      return '$loadStr $unit for $sets sets of $reps reps$failures.';
    } else {
      return '$loadStr for $sets sets of $reps reps$failures.';
    }
  }

  @override
  String toString() => '$_summary$_metadata$_notes';

  double get volume => successfulReps * load! * sets;
}
