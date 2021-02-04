import 'package:traindown/src/metadata.dart';

class Performance extends Metadatable {
  double _fails;
  double _load;
  double _sets;
  double _reps;
  String _unit;
  bool _touched = false;

  static const List<String> bodyweightKeywords = [
    'bw',
    'BW',
    'bodyweight',
    'Bodyweight'
  ];

  static const List<String> unitKeywords = [
    'u',
    'U',
    'unit',
    'Unit',
  ];

  Performance(
      {double fails = 0,
      double load = -1,
      double sets = 1,
      double reps = 1,
      String unit = 'unknown unit'})
      : _fails = fails,
        _load = load < 0 ? null : load,
        _sets = sets,
        _reps = reps,
        _unit = unit;

  @override
  void addKVP(String key, String value) {
    if (unitKeywords.contains(key)) {
      _unit = value;
    } else {
      super.addKVP(key, value);
    }
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
    if (unit.isNotEmpty) {
      return '$load $unit for $sets sets of $reps reps$failures.';
    } else {
      return '$load for $sets sets of $reps reps$failures.';
    }
  }

  @override
  String toString() {
    return '$_summary$_metadata$_notes';
  }

  String get unit => _unit;
  set unit(String newUnit) {
    _touched = true;
    _unit = newUnit;
  }

  double get volume => successfulReps * load * sets;
  bool get wasTouched => _touched;
}
