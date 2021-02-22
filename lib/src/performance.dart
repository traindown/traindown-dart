import 'package:traindown/src/metadata.dart';

/// Performance represents a single expression of movement. It can be as little
/// as a single or as much as needed. Each Performance *must* have a load
/// otherwise it is somewhat nonsensical. Outside that, a Performance may have
/// a count of repititions performed for the given load, a count of sets of
/// reps, a count of failed reps, and a unit for the load.
class Performance extends Metadatable {
  double _fails;
  double _load;
  double _sets;
  double _reps;
  bool _touched = false;

  static List<String> attrs = ['fails', 'load', 'sets', 'reps'];

  Performance(
      {double fails = 0,
      double load = -1,
      double sets = 1,
      double reps = 1,
      String unit = Metadata.unknownUnit})
      : _fails = fails,
        _load = load < 0 ? null : load,
        _sets = sets,
        _reps = reps {
          if (unit != Metadata.unknownUnit) {
            this.unit = unit;
          }
        }

  void operator []=(String attr, double value) {
    if (!attrs.contains(attr)) throw 'Invalid attr';

    switch(attr) {
      case 'fails':
        _fails = value;
        break;
      case 'load':
        _load = value;
        break;
      case 'sets':
        _sets = value;
        break;
      case 'reps':
        _reps = value;
        break;
    };
  }

  @override
  void addKVP(String key, String value) {
    super.addKVP(key, value);
    _touched = true;
  }

  double get fails => _fails;
  set fails(double newFails) {
    _touched = true;
    _fails = newFails;
  }

  double get load => _load;
  set load(double newLoad) {
    _touched = true;
    _load = newLoad;
  }

  String get _metadata {
    if (metadata.kvps.entries.isEmpty) {
      return '';
    }
    StringBuffer ret = StringBuffer();
    for (var mapEntry in metadata.kvps.entries) {
      ret.write('    ${mapEntry.key}: ${mapEntry.value}\n');
    }
    return '\n$ret\n';
  }

  String get _notes {
    if (metadata.notes.isEmpty) {
      return '';
    }
    StringBuffer ret = StringBuffer();
    for (var note in metadata.notes) {
      ret.write('    - $note\n');
    }
    return '\n$ret\n';
  }

  double get sets => _sets;
  set sets(double newSets) {
    _touched = true;
    _sets = newSets;
  }

  double get reps => _reps;
  set reps(double newReps) {
    _touched = true;
    _reps = newReps;
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
  String toString() {
    return '$_summary$_metadata$_notes';
  }

  @override
  set unit(String newUnit) {
    super.unit = newUnit;
    _touched = true;
  }

  double get volume => successfulReps * load * sets;
  bool get wasTouched => _touched;
}
