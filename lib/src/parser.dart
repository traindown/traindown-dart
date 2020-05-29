import "package:traindown/src/evented_parser.dart";
import "package:traindown/src/metadata.dart";
import "package:traindown/src/movement.dart";
import "package:traindown/src/performance.dart";
import "package:traindown/src/scanner.dart";
import "package:traindown/src/token.dart";

class Parser extends EventedParser {
  bool hasParsed = false;
  Metadata metadata = Metadata();
  List<Movement> movements = [];
  DateTime occurred = DateTime.now();

  StringBuffer _dateBuffer = StringBuffer();
  StringBuffer _keyBuffer = StringBuffer();
  StringBuffer _nameBuffer = StringBuffer();
  StringBuffer _noteBuffer = StringBuffer();
  StringBuffer _valueBuffer = StringBuffer();

  Movement _currentMovement;
  Performance _currentPerformance;

  bool _shouldSuperset = false;

  Parser(Scanner scanner) : super(scanner);
  Parser.for_file(String filename) : super.for_file(filename);
  Parser.for_string(String string) : super.for_string(string);

  Metadatable get _lastEntity {
    if (_currentPerformance != null) {
      return _currentPerformance;
    } else {
      return _currentMovement;
    }
  }

  void parse() => call();

  Performance _newPerformance(String movementName) {
    String unit =
        metadata.kvps["Unit"] ?? metadata.kvps["unit"] ?? "unknown unit";
    return Performance(unit: unit);
  }

  void amountDuringDate(TokenLiteral tokenLiteral) =>
      _dateBuffer.write(tokenLiteral.literal);

  void amountDuringIdle(TokenLiteral tokenLiteral) {}

  void amountDuringMetadataKey(TokenLiteral tokenLiteral) =>
      _keyBuffer.write("${tokenLiteral.literal} ");

  void amountDuringMetadataValue(TokenLiteral tokenLiteral) =>
      _valueBuffer.write("${tokenLiteral.literal} ");

  void amountDuringPerformance(TokenLiteral tokenLiteral) {
    if (_currentPerformance.load != 0) {
      endPerformance();
    }

    _currentPerformance.load = num.tryParse(tokenLiteral.literal);
  }

  void beginDate() => _dateBuffer.clear();

  void beginMetadata() {
    _keyBuffer.clear();
    _valueBuffer.clear();
  }

  void beginMovementName(TokenLiteral tokenLiteral) {
    if (_currentMovement != null) {
      movements.add(_currentMovement);
    }

    _nameBuffer.write("${tokenLiteral.literal}");
  }

  void beginNote() => _noteBuffer.clear();

  void beginPerformanceMetadata(TokenLiteral tokenLiteral) {
    _keyBuffer.clear();
    _valueBuffer.clear();
  }

  void beginPerformanceNote(TokenLiteral tokenLiteral) => _noteBuffer.clear();

  void encounteredDash(TokenLiteral tokenLiteral) =>
      _dateBuffer.write(tokenLiteral.literal);

  void encounteredEof() {
    endPerformance();
    movements.add(_currentMovement);
  }

  void encounteredFailures(TokenLiteral tokenLiteral) =>
      _currentPerformance.fails = num.tryParse(tokenLiteral.literal);

  void encounteredReps(TokenLiteral tokenLiteral) =>
      _currentPerformance.reps = num.tryParse(tokenLiteral.literal);

  void encounteredPlus(TokenLiteral tokenLiteral) => _shouldSuperset = true;

  void encounteredSets(TokenLiteral tokenLiteral) =>
      _currentPerformance.repeat = num.tryParse(tokenLiteral.literal);

  // NOTE: noop
  void encounteredWord(TokenLiteral tokenLiteral) {}

  void endDate() {
    DateTime parsedDate = DateTime.tryParse(_dateBuffer.toString().trim());

    if (parsedDate != null) {
      occurred = parsedDate;
    }
  }

  // NOTE: noop
  void endMetadataKey() {}

  void endMetadataValue() {
    String key = _keyBuffer.toString().trimRight();
    String value = _valueBuffer.toString().trimRight();

    if (_lastEntity != null) {
      _lastEntity.addKVP(key, value);
    } else {
      metadata.addKVP(key, value);
    }
  }

  void endMovementName() {
    String name = _nameBuffer.toString().trimRight();
    _currentMovement = Movement(name);
    _currentMovement.superSetted = _shouldSuperset;
    _currentPerformance = _newPerformance(name);
    _shouldSuperset = false;
  }

  void endNote() {
    String note = _noteBuffer.toString().trimRight();

    if (_lastEntity != null) {
      _lastEntity.addNote(note);
    } else {
      metadata.addNote(note);
    }
  }

  void endPerformance() {
    _currentMovement.performances.add(_currentPerformance);
    _currentPerformance = _newPerformance(_currentMovement.name);
  }

  void wordDuringDate(TokenLiteral tokenLiteral) =>
      _dateBuffer.write("${tokenLiteral.literal} ");

  void wordDuringMetadataKey(TokenLiteral tokenLiteral) =>
      _keyBuffer.write("${tokenLiteral.literal} ");

  void wordDuringMetadataValue(TokenLiteral tokenLiteral) =>
      _valueBuffer.write("${tokenLiteral.literal} ");

  void wordDuringMovementName(TokenLiteral tokenLiteral) =>
      _nameBuffer.write(" ${tokenLiteral.literal} ");

  void wordDuringNote(TokenLiteral tokenLiteral) =>
      _noteBuffer.write("${tokenLiteral.literal} ");

  void wordDuringPerformance(TokenLiteral tokenLiteral) {
    endPerformance();
    beginMovementName(tokenLiteral);
  }
}
