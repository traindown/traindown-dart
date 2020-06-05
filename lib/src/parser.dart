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

  @override
  void amountDuringDate(TokenLiteral tokenLiteral) =>
      _dateBuffer.write(tokenLiteral.literal);

  @override
  void amountDuringIdle(TokenLiteral tokenLiteral) {}

  @override
  void amountDuringMetadataKey(TokenLiteral tokenLiteral) =>
      _keyBuffer.write("${tokenLiteral.literal} ");

  @override
  void amountDuringMetadataValue(TokenLiteral tokenLiteral) =>
      _valueBuffer.write("${tokenLiteral.literal} ");

  @override
  void amountDuringNote(TokenLiteral tokenLiteral) =>
      _noteBuffer.write("${tokenLiteral.literal} ");

  @override
  void amountDuringPerformance(TokenLiteral tokenLiteral) {
    if (_currentPerformance.load != 0) {
      endPerformance();
    }

    _currentPerformance.load = num.tryParse(tokenLiteral.literal);
  }

  @override
  void beginDate() => _dateBuffer.clear();

  @override
  void beginMetadata() {
    _keyBuffer.clear();
    _valueBuffer.clear();
  }

  @override
  void beginMovementName(TokenLiteral tokenLiteral) {
    if (_currentMovement != null) {
      movements.add(_currentMovement);
    }

    _nameBuffer.write("${tokenLiteral.literal}");
  }

  @override
  void beginMovementNote() => _noteBuffer.clear();

  @override
  void beginNote() => _noteBuffer.clear();

  @override
  void beginPerformanceMetadata(TokenLiteral tokenLiteral) {
    _keyBuffer.clear();
    _valueBuffer.clear();
  }

  @override
  void beginPerformanceNote() => _noteBuffer.clear();

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

  // NOTE: noop
  @override
  void endMetadataKey() {}

  @override
  void endMetadataValue() {
    String key = _keyBuffer.toString().trimRight();
    String value = _valueBuffer.toString().trimRight();

    if (_lastEntity != null) {
      _lastEntity.addKVP(key, value);
    } else {
      metadata.addKVP(key, value);
    }
  }

  @override
  void endMovementName() {
    String name = _nameBuffer.toString().trimRight();
    _currentMovement = Movement(name);
    _currentMovement.superSetted = _shouldSuperset;
    _currentPerformance = _newPerformance(name);
    _shouldSuperset = false;
  }

  @override
  void endMovementNote() {
    String note = _noteBuffer.toString().trimRight();
    _currentMovement.addNote(note);
  }

  @override
  void endNote() {
    String note = _noteBuffer.toString().trimRight();

    if (_lastEntity != null) {
      _lastEntity.addNote(note);
    } else {
      metadata.addNote(note);
    }
  }

  @override
  void endPerformance() {
    _currentMovement.performances.add(_currentPerformance);
    _currentPerformance = _newPerformance(_currentMovement.name);
  }

  @override
  void endPerformanceNote() {
    String note = _noteBuffer.toString().trimRight();
    _currentPerformance.addNote(note);
  }

  @override
  void wordDuringDate(TokenLiteral tokenLiteral) =>
      _dateBuffer.write("${tokenLiteral.literal} ");

  @override
  void wordDuringMetadataKey(TokenLiteral tokenLiteral) =>
      _keyBuffer.write("${tokenLiteral.literal} ");

  @override
  void wordDuringMetadataValue(TokenLiteral tokenLiteral) =>
      _valueBuffer.write("${tokenLiteral.literal} ");

  @override
  void wordDuringMovementName(TokenLiteral tokenLiteral) =>
      _nameBuffer.write(" ${tokenLiteral.literal} ");

  @override
  void wordDuringNote(TokenLiteral tokenLiteral) =>
      _noteBuffer.write("${tokenLiteral.literal} ");

  @override
  void wordDuringPerformance(TokenLiteral tokenLiteral) {
    endPerformance();
    beginMovementName(tokenLiteral);
  }
}
