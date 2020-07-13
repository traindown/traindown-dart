import 'package:traindown/src/evented_parser.dart';
import 'package:traindown/src/metadata.dart';
import 'package:traindown/src/movement.dart';
import 'package:traindown/src/performance.dart';
import 'package:traindown/src/scanner.dart';
import 'package:traindown/src/token.dart';

class Parser extends EventedParser {
  bool hasParsed = false;
  Metadata metadata = Metadata();
  List<Movement> movements = [];
  DateTime occurred = DateTime.now();

  final StringBuffer _dateBuffer = StringBuffer();
  final StringBuffer _keyBuffer = StringBuffer();
  final StringBuffer _nameBuffer = StringBuffer();
  final StringBuffer _noteBuffer = StringBuffer();
  final StringBuffer _valueBuffer = StringBuffer();

  Movement _currentMovement;
  Performance _currentPerformance;

  bool _shouldSuperset = false;

  Parser(Scanner scanner) : super(scanner);
  Parser.for_file(String filename) : super.for_file(filename);
  Parser.for_string(String string) : super.for_string(string);

  void parse() => call();

  Performance _newPerformance() {
    String unit = 'unknown unit';
    for (Metadata scope in [_currentMovement.metadata, metadata]) {
      for (String unitKeyword in Performance.unitKeywords) {
        if (scope.kvps.containsKey(unitKeyword)) {
          unit = scope.kvps[unitKeyword];
          break;
        }
      }
      if (unit != 'unknown unit') break;
    }

    return Performance(unit: unit);
  }

  @override
  void amountDuringDate(TokenLiteral tokenLiteral) =>
      _dateBuffer.write(tokenLiteral.literal);

  @override
  void amountDuringIdle(TokenLiteral tokenLiteral) {}

  @override
  void amountDuringMovementMetadataKey(TokenLiteral tokenLiteral) =>
      _keyBuffer.write('${tokenLiteral.literal} ');

  @override
  void amountDuringMovementMetadataValue(TokenLiteral tokenLiteral) =>
      _valueBuffer.write('${tokenLiteral.literal} ');

  @override
  void amountDuringMovementName(TokenLiteral tokenLiteral) {}

  @override
  void amountDuringMovementNote(TokenLiteral tokenLiteral) =>
      _noteBuffer.write('${tokenLiteral.literal} ');

  @override
  void amountDuringPerformance(TokenLiteral tokenLiteral) {
    if (_currentPerformance.load != 0) {
      endPerformance();
    }

    if (tokenLiteral.isWord) {
      if (Performance.bodyweightKeywords.contains(tokenLiteral.literal)) {
        _currentPerformance.load = 1;
        _currentPerformance.unit = 'bodyweight';
      } else {
        wordDuringPerformance(tokenLiteral);
      }
    }

    if (tokenLiteral.isAmount) {
      _currentPerformance.load = num.tryParse(tokenLiteral.literal);
    }
  }

  @override
  void amountDuringPerformanceMetadataKey(TokenLiteral tokenLiteral) =>
      _keyBuffer.write('${tokenLiteral.literal} ');

  @override
  void amountDuringPerformanceMetadataValue(TokenLiteral tokenLiteral) =>
      _valueBuffer.write('${tokenLiteral.literal} ');

  @override
  void amountDuringPerformanceNote(TokenLiteral tokenLiteral) =>
      _noteBuffer.write('${tokenLiteral.literal} ');

  @override
  void amountDuringSessionMetadataKey(TokenLiteral tokenLiteral) =>
      _keyBuffer.write('${tokenLiteral.literal} ');

  @override
  void amountDuringSessionMetadataValue(TokenLiteral tokenLiteral) =>
      _valueBuffer.write('${tokenLiteral.literal} ');

  @override
  void amountDuringSessionNote(TokenLiteral tokenLiteral) =>
      _noteBuffer.write('${tokenLiteral.literal} ');

  @override
  void beginDate() => _dateBuffer.clear();

  @override
  void beginMovementName(TokenLiteral tokenLiteral) {
    if (_currentPerformance != null) {
      endPerformance();
    }

    if (_currentMovement != null) {
      movements.add(_currentMovement);
    }

    _nameBuffer.clear();

    if (tokenLiteral.isPlus) {
      _shouldSuperset = true;
    } else {
      _nameBuffer.write('${tokenLiteral.literal}');
    }
  }

  @override
  void beginMovementMetadata() {
    _keyBuffer.clear();
    _valueBuffer.clear();
  }

  @override
  void beginMovementNote() => _noteBuffer.clear();

  @override
  void beginPerformanceMetadata() {
    _keyBuffer.clear();
    _valueBuffer.clear();
  }

  @override
  void beginPerformanceNote() => _noteBuffer.clear();

  @override
  void beginSessionMetadata() {
    _keyBuffer.clear();
    _valueBuffer.clear();
  }

  @override
  void beginSessionNote() => _noteBuffer.clear();

  @override
  void encounteredDash(TokenLiteral tokenLiteral) =>
      _dateBuffer.write(tokenLiteral.literal);

  @override
  void encounteredEof() {
    endPerformance();
    movements.add(_currentMovement);
  }

  @override
  void encounteredFailures(TokenLiteral tokenLiteral) =>
      _currentPerformance.fails = num.tryParse(tokenLiteral.literal);

  @override
  void encounteredReps(TokenLiteral tokenLiteral) =>
      _currentPerformance.reps = num.tryParse(tokenLiteral.literal);

  @override
  void encounteredPlus(TokenLiteral tokenLiteral) => _shouldSuperset = true;

  @override
  void encounteredSets(TokenLiteral tokenLiteral) =>
      _currentPerformance.repeat = num.tryParse(tokenLiteral.literal);

  // NOTE: noop
  @override
  void encounteredWord(TokenLiteral tokenLiteral) {}

  @override
  void endDate() {
    DateTime parsedDate = DateTime.tryParse(_dateBuffer.toString().trim());

    if (parsedDate != null) {
      occurred = parsedDate;
    }
  }

  @override
  void endMovementName() {
    String name = _nameBuffer.toString().trimRight();
    _currentMovement = Movement(name);
    _currentMovement.superSetted = _shouldSuperset;
    _currentPerformance = _newPerformance();
    _shouldSuperset = false;
  }

  // NOTE: noop
  @override
  void endMovementMetadataKey() {}

  @override
  void endMovementMetadataValue() {
    String key = _keyBuffer.toString().trimRight();
    String value = _valueBuffer.toString().trimRight();
    _currentMovement.addKVP(key, value);
  }

  @override
  void endMovementNote() {
    String note = _noteBuffer.toString().trimRight();
    _currentMovement.addNote(note);
  }

  @override
  void endPerformance() {
    if (_currentPerformance.wasTouched) {
      _currentMovement.performances.add(_currentPerformance);
    }
    _currentPerformance = _newPerformance();
  }

  // NOTE: noop
  @override
  void endPerformanceMetadataKey() {}

  @override
  void endPerformanceMetadataValue() {
    String key = _keyBuffer.toString().trimRight();
    String value = _valueBuffer.toString().trimRight();

    if (Performance.unitKeywords.contains(key)) {
      _currentPerformance.unit = value;
    } else {
      _currentPerformance.addKVP(key, value);
    }
  }

  @override
  void endPerformanceNote() {
    String note = _noteBuffer.toString().trimRight();
    _currentPerformance.addNote(note);
  }

  // NOTE: noop
  @override
  void endSessionMetadataKey() {}

  @override
  void endSessionMetadataValue() {
    String key = _keyBuffer.toString().trimRight();
    String value = _valueBuffer.toString().trimRight();

    metadata.addKVP(key, value);
  }

  @override
  void endSessionNote() {
    String note = _noteBuffer.toString().trimRight();
    metadata.addNote(note);
  }

  @override
  void wordDuringDate(TokenLiteral tokenLiteral) =>
      _dateBuffer.write('${tokenLiteral.literal} ');

  @override
  void wordDuringMetadataKey(TokenLiteral tokenLiteral) =>
      _keyBuffer.write('${tokenLiteral.literal} ');

  @override
  void wordDuringMetadataValue(TokenLiteral tokenLiteral) =>
      _valueBuffer.write('${tokenLiteral.literal} ');

  @override
  void wordDuringMovementName(TokenLiteral tokenLiteral) =>
      _nameBuffer.write(' ${tokenLiteral.literal} ');

  @override
  void wordDuringNote(TokenLiteral tokenLiteral) =>
      _noteBuffer.write('${tokenLiteral.literal} ');

  @override
  void wordDuringPerformance(TokenLiteral tokenLiteral) {
    endPerformance();
    beginMovementName(tokenLiteral);
  }
}
