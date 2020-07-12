import "package:traindown/src/evented_parser.dart";
import "package:traindown/src/scanner.dart";
import "package:traindown/src/token.dart";

class Formatter extends EventedParser {
  StringBuffer output = StringBuffer();

  Formatter(Scanner scanner) : super(scanner);
  Formatter.for_file(String filename) : super.for_file(filename);
  Formatter.for_string(String string) : super.for_string(string);

  String format() {
    output.clear();

    try {
      call();
    } on UnexpectedToken catch (e) {
      print("Error at ${e.msg}");
    }

    return output.toString();
  }

  @override
  void amountDuringDate(TokenLiteral tokenLiteral) => _addLiteral(tokenLiteral);

  @override
  void amountDuringIdle(TokenLiteral tokenLiteral) {
    _addLinebreak();
    _addSpace(2);
    _addLiteral(tokenLiteral);
  }

  @override
  void amountDuringMovementMetadataKey(TokenLiteral tokenLiteral) =>
      _addLiteral(tokenLiteral);

  @override
  void amountDuringMovementMetadataValue(TokenLiteral tokenLiteral) =>
      _addLeftPad(tokenLiteral);

  @override
  void amountDuringMovementName(TokenLiteral tokenLiteral) {
    output.write(':');
    _addLinebreak();
    _addSpace(2);
    _addLiteral(tokenLiteral);
  }

  @override
  void amountDuringMovementNote(TokenLiteral tokenLiteral) {
    _addLinebreak();
    _addSpace(2);
    _addLiteral(tokenLiteral);
  }

  @override
  void amountDuringPerformance(TokenLiteral tokenLiteral) {
    _addLinebreak();
    _addSpace(2);
    _addLiteral(tokenLiteral);
  }

  @override
  void amountDuringPerformanceMetadataKey(TokenLiteral tokenLiteral) =>
      _addLiteral(tokenLiteral);

  @override
  void amountDuringPerformanceMetadataValue(TokenLiteral tokenLiteral) =>
      _addLeftPad(tokenLiteral);

  @override
  void amountDuringPerformanceNote(TokenLiteral tokenLiteral) {
    _addLinebreak();
    _addSpace(2);
    _addLiteral(tokenLiteral);
  }

  @override
  void amountDuringSessionMetadataKey(TokenLiteral tokenLiteral) =>
      _addLiteral(tokenLiteral);

  @override
  void amountDuringSessionMetadataValue(TokenLiteral tokenLiteral) =>
      _addLeftPad(tokenLiteral);

  @override
  void amountDuringSessionNote(TokenLiteral tokenLiteral) {
    _addLinebreak();
    _addSpace(2);
    _addLiteral(tokenLiteral);
  }

  @override
  void beginDate() => output.write("@ ");

  @override
  void beginMovementMetadata() {
    _addLinebreak();
    _addSpace(2);
    output.write("#");
  }

  @override
  void beginMovementName(TokenLiteral tokenLiteral) {
    _addLinebreak();
    _addLinebreak();
    _addLiteral(tokenLiteral);
  }

  @override
  void beginMovementNote() {
    _addLinebreak();
    _addSpace(2);
    output.write("*");
  }

  @override
  void beginPerformanceMetadata() {
    _addLinebreak();
    _addSpace(4);
    output.write("#");
  }

  @override
  void beginPerformanceNote() {
    _addLinebreak();
    _addSpace(4);
    output.write("*");
  }

  @override
  void beginSessionMetadata() {
    _addLinebreak();
    output.write("#");
  }

  @override
  void beginSessionNote() {
    _addLinebreak();
    output.write("*");
  }

  @override
  void encounteredDash(TokenLiteral tokenLiteral) => _addLiteral(tokenLiteral);

  @override
  void encounteredEof() {}

  @override
  void encounteredFailures(TokenLiteral tokenLiteral) =>
      _addLeftPad(tokenLiteral, "f");

  @override
  void encounteredReps(TokenLiteral tokenLiteral) =>
      _addLeftPad(tokenLiteral, "r");

  @override
  void encounteredPlus(TokenLiteral tokenLiteral) {
    _addLinebreak();
    _addRightPad(tokenLiteral);
  }

  @override
  void encounteredSets(TokenLiteral tokenLiteral) =>
      _addLeftPad(tokenLiteral, "s");

  // NOTE: Investigate context on this.
  @override
  void encounteredWord(TokenLiteral tokenLiteral) => _addLiteral(tokenLiteral);

  @override
  void endDate() {}

  @override
  void endMovementMetadataKey() => output.write(":");

  @override
  void endMovementMetadataValue() {}

  @override
  void endMovementName() => output.write(":");

  @override
  void endMovementNote() {}

  @override
  void endPerformance() {}

  @override
  void endPerformanceMetadataKey() => output.write(":");

  @override
  void endPerformanceMetadataValue() {}

  @override
  void endPerformanceNote() {}

  @override
  void endSessionMetadataKey() => output.write(":");

  @override
  void endSessionMetadataValue() {}

  @override
  void endSessionNote() {}

  @override
  void wordDuringDate(TokenLiteral tokenLiteral) {
    _addLinebreak();
    _addLiteral(tokenLiteral);
  }

  @override
  void wordDuringMetadataKey(TokenLiteral tokenLiteral) =>
      _addLeftPad(tokenLiteral);

  @override
  void wordDuringMetadataValue(TokenLiteral tokenLiteral) =>
      _addLeftPad(tokenLiteral);

  @override
  void wordDuringMovementName(TokenLiteral tokenLiteral) =>
      _addLeftPad(tokenLiteral);

  @override
  void wordDuringNote(TokenLiteral tokenLiteral) => _addLeftPad(tokenLiteral);

  @override
  void wordDuringPerformance(TokenLiteral tokenLiteral) {
    _addLinebreak();
    _addLiteral(tokenLiteral);
  }

  void _addLeftPad(TokenLiteral tokenLiteral, [append = ""]) =>
      output.write(" ${tokenLiteral.literal}${append}");

  void _addLinebreak() => output.write("\r\n");

  void _addLiteral(TokenLiteral tokenLiteral) =>
      output.write(tokenLiteral.literal);

  void _addRightPad(TokenLiteral tokenLiteral) =>
      output.write("${tokenLiteral.literal} ");

  void _addSpace([int count = 1]) => output.write(" " * count);
}
