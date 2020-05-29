import "package:traindown/src/scanner.dart";
import "package:traindown/src/token.dart";

enum ParseState {
  initialized,
  awaiting_amount,
  awaiting_metadata_value,
  awaiting_movement_performance,
  capturing_date,
  capturing_metadata_key,
  capturing_movement_name,
  capturing_movement_performance,
  capturing_metadata_value,
  capturing_note,
  idle,
}

class UnexpectedToken implements Exception {
  final String msg;

  const UnexpectedToken([this.msg]);

  @override
  String toString() => msg ?? "UnexpectedToken";
}

abstract class EventedParser {
  ParseState _state = ParseState.initialized;
  Scanner _scanner;

  EventedParser(Scanner scanner) {
    if (scanner == null) {
      throw "Needs a scanner, dummy";
    }
    _scanner = scanner;
  }

  EventedParser.for_file(String filename) : this(Scanner(filename: filename));
  EventedParser.for_string(String string) : this(Scanner(string: string));

  void amountDuringDate(TokenLiteral tokenLiteral);
  void amountDuringIdle(TokenLiteral tokenLiteral);
  void amountDuringMetadataKey(TokenLiteral tokenLiteral);
  void amountDuringMetadataValue(TokenLiteral tokenLiteral);
  void amountDuringPerformance(TokenLiteral tokenLiteral);
  void beginDate(TokenLiteral tokenLiteral);
  void beginMetadata(TokenLiteral tokenLiteral);
  void beginMovementName(TokenLiteral tokenLiteral);
  void beginNote(TokenLiteral tokenLiteral);
  void beginPerformanceMetadata(TokenLiteral tokenLiteral);
  void beginPerformanceNote(TokenLiteral tokenLiteral);
  void encounteredDash(TokenLiteral tokenLiteral);
  void encounteredFailures(TokenLiteral tokenLiteral);
  void encounteredReps(TokenLiteral tokenLiteral);
  void encounteredPlus(TokenLiteral tokenLiteral);
  void encounteredSets(TokenLiteral tokenLiteral);
  void encounteredWord(TokenLiteral tokenLiteral);
  void endDate(TokenLiteral tokenLiteral);
  void endMetadataKey(TokenLiteral tokenLiteral);
  void endMetadataValue(TokenLiteral tokenLiteral);
  void endMovementName(TokenLiteral tokenLiteral);
  void endPerformance(TokenLiteral tokenLiteral);
  void wordDuringDate(TokenLiteral tokenLiteral);
  void wordDuringMetadataKey(TokenLiteral tokenLiteral);
  void wordDuringMetadataValue(TokenLiteral tokenLiteral);
  void wordDuringMovementName(TokenLiteral tokenLiteral);
  void wordDuringNote(TokenLiteral tokenLiteral);
  void wordDuringPerformance(TokenLiteral tokenLiteral);

  void call() {
    if (_scanner == null) throw "Needs a scanner, dummy";

    while (!_scanner.eof) {
      TokenLiteral tokenLiteral = _scanner.scan();

      if (tokenLiteral.isAmount) {
        switch (_state) {
          case ParseState.capturing_date:
            amountDuringDate(tokenLiteral);
            continue;
          case ParseState.capturing_metadata_key:
            amountDuringMetadataKey(tokenLiteral);
            continue;
          case ParseState.capturing_metadata_value:
            amountDuringMetadataValue(tokenLiteral);
            continue;
          case ParseState.capturing_movement_performance:
            amountDuringPerformance(tokenLiteral);
            continue;
          case ParseState.idle:
            amountDuringIdle(tokenLiteral);
            _state = ParseState.capturing_movement_performance;
            continue;
          default:
            throw UnexpectedToken(tokenLiteral.toString());
        }
      }

      if (tokenLiteral.isAt) {
        if (_state != ParseState.initialized) {
          throw UnexpectedToken(tokenLiteral.toString());
        }

        beginDate(tokenLiteral);
        _state = ParseState.capturing_date;
      }

      if (tokenLiteral.isColon) {
        switch (_state) {
          case ParseState.capturing_metadata_key:
            endMetadataKey(tokenLiteral);
            _state = ParseState.capturing_metadata_value;
            continue;
          case ParseState.capturing_movement_name:
            endMovementName(tokenLiteral);
            _state = ParseState.capturing_movement_performance;
            continue;
          default:
            throw UnexpectedToken(tokenLiteral.toString());
        }
      }

      if (tokenLiteral.isDash) {
        encounteredDash(tokenLiteral);
        continue;
      }

      if (tokenLiteral.isFails) {
        encounteredFailures(tokenLiteral);
        continue;
      }

      if (tokenLiteral.isIllegal) {
        throw UnexpectedToken(tokenLiteral.toString());
      }

      if (tokenLiteral.isLinebreak) {
        switch (_state) {
          case ParseState.capturing_date:
            endDate(tokenLiteral);
            continue;
          case ParseState.capturing_metadata_value:
            endMetadataValue(tokenLiteral);
            continue;
          case ParseState.capturing_movement_performance:
            endPerformance(tokenLiteral);
            _state = ParseState.idle;
            continue;
          default:
            continue;
        }
      }

      if (tokenLiteral.isPlus) {
        encounteredPlus(tokenLiteral);
        continue;
      }

      if (tokenLiteral.isPound) {
        switch (_state) {
          case ParseState.capturing_movement_performance:
            beginPerformanceMetadata(tokenLiteral);
            _state = ParseState.capturing_metadata_key;
            continue;
          default:
            beginMetadata(tokenLiteral);
            _state = ParseState.capturing_metadata_key;
            continue;
        }
      }

      if (tokenLiteral.isReps) {
        encounteredReps(tokenLiteral);
        continue;
      }

      if (tokenLiteral.isSets) {
        encounteredSets(tokenLiteral);
        continue;
      }

      if (tokenLiteral.isStar) {
        switch (_state) {
          case ParseState.capturing_movement_performance:
            beginPerformanceNote(tokenLiteral);
            _state = ParseState.capturing_note;
            continue;
          default:
            beginNote(tokenLiteral);
            _state = ParseState.capturing_metadata_key;
            continue;
        }
      }

      if (tokenLiteral.isWhitespace) continue;

      if (tokenLiteral.isWord) {
        switch (_state) {
          case ParseState.capturing_metadata_key:
            wordDuringMetadataKey(tokenLiteral);
            continue;
          case ParseState.capturing_metadata_value:
            wordDuringMetadataValue(tokenLiteral);
            continue;
          case ParseState.capturing_movement_name:
            wordDuringMovementName(tokenLiteral);
            continue;
          case ParseState.capturing_note:
            wordDuringNote(tokenLiteral);
            continue;
          case ParseState.capturing_date:
            wordDuringDate(tokenLiteral);
            _state = ParseState.capturing_movement_name;
            continue;
          case ParseState.capturing_movement_performance:
            wordDuringPerformance(tokenLiteral);
            _state = ParseState.capturing_movement_name;
            continue;
          case ParseState.idle:
            beginMovementName(tokenLiteral);
            _state = ParseState.capturing_movement_name;
            continue;
          default:
            encounteredWord(tokenLiteral);
            continue;
        }
      }
    }
  }
}
