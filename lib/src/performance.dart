import 'package:traindown/src/metadata.dart';

class Performance extends Metadatable {
  int _fails;
  int _load;
  @override
  Metadata metadata = Metadata();
  int _repeat;
  int _reps;
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
      {int fails = 0,
      int load = 1,
      int repeat = 1,
      int reps = 1,
      String unit = 'unknown unit'})
      : _fails = fails,
        _load = load,
        _repeat = repeat,
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

  int get fails => _fails;
  set fails(int newFails) {
    _touched = true;
    _fails = newFails;
  }

  int get load => _load;
  set load(int newLoad) {
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

  int get repeat => _repeat;
  set repeat(int newRepeat) {
    _touched = true;
    _repeat = newRepeat;
  }

  int get reps => _reps;
  set reps(int newReps) {
    _touched = true;
    _reps = newReps;
  }

  int get successfulReps => reps - fails;

  String get _summary {
    String failures = fails > 0
        ? ' with $fails failures ($successfulReps successful reps)'
        : '';
    if (unit.isNotEmpty) {
      return '$load $unit for $repeat sets of $reps reps$failures.';
    } else {
      return '$load for $repeat sets of $reps reps$failures.';
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

  int get volume => successfulReps * load * repeat;
  bool get wasTouched => _touched;
}
