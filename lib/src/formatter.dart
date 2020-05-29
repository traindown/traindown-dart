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

  void amountDuringDate(TokenLiteral tokenLiteral) => _addLiteral(tokenLiteral);

  void amountDuringIdle(TokenLiteral tokenLiteral) {
    _addLinebreak();
    _addSpace(2);
    _addLiteral(tokenLiteral);
  }

  void amountDuringMetadataKey(TokenLiteral tokenLiteral) =>
      _addLiteral(tokenLiteral);

  void amountDuringMetadataValue(TokenLiteral tokenLiteral) =>
      _addLeftPad(tokenLiteral);

  void amountDuringPerformance(TokenLiteral tokenLiteral) {
    _addLinebreak();
    _addSpace(2);
    _addLiteral(tokenLiteral);
  }

  void beginDate() => output.write("@ ");

  void beginMetadata() {
    _addLinebreak();
    output.write("# ");
  }

  void beginMovementName(TokenLiteral tokenLiteral) {
    _addLinebreak();
    _addLiteral(tokenLiteral);
  }

  void beginNote() {
    _addLinebreak();
    output.write("* ");
  }

  void beginPerformanceMetadata(TokenLiteral tokenLiteral) {
    _addLinebreak();
    _addSpace(4);
    _addLiteral(tokenLiteral);
  }

  void beginPerformanceNote(TokenLiteral tokenLiteral) {
    _addLinebreak();
    _addSpace(4);
    _addLiteral(tokenLiteral);
  }

  void encounteredDash(TokenLiteral tokenLiteral) => _addLiteral(tokenLiteral);

  void encounteredEof() {}

  void encounteredFailures(TokenLiteral tokenLiteral) =>
      _addLeftPad(tokenLiteral, "f");

  void encounteredReps(TokenLiteral tokenLiteral) =>
      _addLeftPad(tokenLiteral, "r");

  void encounteredPlus(TokenLiteral tokenLiteral) {
    _addLinebreak();
    _addRightPad(tokenLiteral);
  }

  void encounteredSets(TokenLiteral tokenLiteral) =>
      _addLeftPad(tokenLiteral, "s");

  // NOTE: Investigate context on this.
  void encounteredWord(TokenLiteral tokenLiteral) => _addLiteral(tokenLiteral);

  void endDate() => _addLinebreak();

  void endMetadataKey() => output.write(":");

  void endMetadataValue() => _addLinebreak();

  void endMovementName() => output.write(":");

  void endNote() => _addLinebreak();

  void endPerformance() => _addLinebreak();

  void wordDuringDate(TokenLiteral tokenLiteral) {
    _addLinebreak();
    _addLiteral(tokenLiteral);
  }

  void wordDuringMetadataKey(TokenLiteral tokenLiteral) =>
      _addLeftPad(tokenLiteral);

  void wordDuringMetadataValue(TokenLiteral tokenLiteral) =>
      _addLeftPad(tokenLiteral);

  void wordDuringMovementName(TokenLiteral tokenLiteral) =>
      _addLeftPad(tokenLiteral);

  void wordDuringNote(TokenLiteral tokenLiteral) => _addLeftPad(tokenLiteral);

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
