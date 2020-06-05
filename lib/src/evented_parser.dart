import "dart:mirrors";

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
  capturing_movement_note,
  capturing_movement_performance,
  capturing_metadata_value,
  capturing_note,
  capturing_performance_note,
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

  ParseState get state => _state;

  void amountDuringDate(TokenLiteral tokenLiteral);
  void amountDuringIdle(TokenLiteral tokenLiteral);
  void amountDuringMetadataKey(TokenLiteral tokenLiteral);
  void amountDuringMetadataValue(TokenLiteral tokenLiteral);
  void amountDuringNote(TokenLiteral tokenLiteral);
  void amountDuringPerformance(TokenLiteral tokenLiteral);
  void beginDate();
  void beginMetadata();
  void beginMovementName(TokenLiteral tokenLiteral);
  void beginMovementNote();
  void beginNote();
  void beginPerformanceMetadata(TokenLiteral tokenLiteral);
  void beginPerformanceNote();
  void encounteredDash(TokenLiteral tokenLiteral);
  void encounteredEof();
  void encounteredFailures(TokenLiteral tokenLiteral);
  void encounteredReps(TokenLiteral tokenLiteral);
  void encounteredPlus(TokenLiteral tokenLiteral);
  void encounteredSets(TokenLiteral tokenLiteral);
  void encounteredWord(TokenLiteral tokenLiteral);
  void endDate();
  void endMetadataKey();
  void endMetadataValue();
  void endMovementName();
  void endMovementNote();
  void endNote();
  void endPerformance();
  void endPerformanceNote();
  void wordDuringDate(TokenLiteral tokenLiteral);
  void wordDuringMetadataKey(TokenLiteral tokenLiteral);
  void wordDuringMetadataValue(TokenLiteral tokenLiteral);
  void wordDuringMovementName(TokenLiteral tokenLiteral);
  void wordDuringNote(TokenLiteral tokenLiteral);
  void wordDuringPerformance(TokenLiteral tokenLiteral);

  void call() {
    if (_scanner == null) throw "Needs a scanner, dummy";

    InstanceMirror self = reflect(this);

    while (!_scanner.eof) {
      TokenLiteral tokenLiteral = _scanner.scan();

      String method = "handle${tokenLiteral.token}";

      if (!self.invoke(Symbol(method), [tokenLiteral, _state]).reflectee) {
        throw UnexpectedToken(tokenLiteral.toString());
      }

      continue;
    }

    encounteredEof();
  }

  bool handleAmount(TokenLiteral tokenLiteral, ParseState state) {
    if (!tokenLiteral.isAmount) return false;

    switch (state) {
      case ParseState.capturing_date:
        amountDuringDate(tokenLiteral);
        return true;
      case ParseState.capturing_metadata_key:
        amountDuringMetadataKey(tokenLiteral);
        return true;
      case ParseState.capturing_metadata_value:
        amountDuringMetadataValue(tokenLiteral);
        return true;
      case ParseState.awaiting_movement_performance:
      case ParseState.capturing_movement_performance:
        amountDuringPerformance(tokenLiteral);
        _state = ParseState.capturing_movement_performance;
        return true;
      case ParseState.capturing_note:
      case ParseState.capturing_movement_note:
      case ParseState.capturing_performance_note:
        amountDuringNote(tokenLiteral);
        _state = ParseState.capturing_movement_performance;
        return true;
      case ParseState.idle:
        amountDuringIdle(tokenLiteral);
        _state = ParseState.capturing_movement_performance;
        return true;
      default:
        return false;
    }
  }

  bool handleAt(TokenLiteral tokenLiteral, ParseState state) {
    if (!tokenLiteral.isAt) return false;
    if (state != ParseState.initialized) return false;

    beginDate();
    _state = ParseState.capturing_date;
    return true;
  }

  bool handleColon(TokenLiteral tokenLiteral, ParseState state) {
    if (!tokenLiteral.isColon) return false;

    switch (state) {
      case ParseState.capturing_metadata_key:
        endMetadataKey();
        _state = ParseState.capturing_metadata_value;
        return true;
      case ParseState.capturing_movement_name:
        endMovementName();
        _state = ParseState.awaiting_movement_performance;
        return true;
      default:
        return false;
    }
  }

  bool handleDash(TokenLiteral tokenLiteral, ParseState state) {
    if (!tokenLiteral.isDash) return false;

    encounteredDash(tokenLiteral);
    return true;
  }

  bool handleFails(TokenLiteral tokenLiteral, ParseState state) {
    if (!tokenLiteral.isFails) return false;

    encounteredFailures(tokenLiteral);
    return true;
  }

  bool handleIllegal(TokenLiteral tokenLiteral, ParseState state) {
    if (!tokenLiteral.isIllegal) return false;
    return true;
  }

  bool handleLinebreak(TokenLiteral tokenLiteral, ParseState state) {
    if (!tokenLiteral.isLinebreak) return false;

    switch (state) {
      case ParseState.capturing_date:
        endDate();
        _state = ParseState.idle;
        return true;
      case ParseState.capturing_metadata_value:
        endMetadataValue();
        _state = ParseState.idle;
        return true;
      case ParseState.capturing_movement_performance:
        endPerformance();
        _state = ParseState.idle;
        return true;
      case ParseState.capturing_movement_note:
        endMovementNote();
        _state = ParseState.idle;
        return true;
      case ParseState.capturing_note:
        endNote();
        _state = ParseState.idle;
        return true;
      case ParseState.capturing_performance_note:
        endPerformanceNote();
        _state = ParseState.idle;
        return true;
      default:
        _state = ParseState.idle;
        return true;
    }
  }

  bool handlePlus(TokenLiteral tokenLiteral, ParseState state) {
    if (!tokenLiteral.isPlus) return false;

    encounteredPlus(tokenLiteral);
    return true;
  }

  bool handlePound(TokenLiteral tokenLiteral, ParseState state) {
    if (!tokenLiteral.isPound) return false;

    switch (state) {
      case ParseState.capturing_movement_performance:
        beginPerformanceMetadata(tokenLiteral);
        _state = ParseState.capturing_metadata_key;
        return true;
      default:
        beginMetadata();
        _state = ParseState.capturing_metadata_key;
        return true;
    }
  }

  bool handleReps(TokenLiteral tokenLiteral, ParseState state) {
    if (!tokenLiteral.isReps) return false;

    encounteredReps(tokenLiteral);
    return true;
  }

  bool handleSets(TokenLiteral tokenLiteral, ParseState state) {
    if (!tokenLiteral.isSets) return false;

    encounteredSets(tokenLiteral);
    return true;
  }

  bool handleStar(TokenLiteral tokenLiteral, ParseState state) {
    if (!tokenLiteral.isStar) return false;

    switch (state) {
      case ParseState.awaiting_movement_performance:
        beginMovementNote();
        _state = ParseState.capturing_movement_note;
        return true;
      case ParseState.capturing_movement_performance:
        beginPerformanceNote();
        _state = ParseState.capturing_performance_note;
        return true;
      default:
        beginNote();
        _state = ParseState.capturing_note;
        return true;
    }
  }

  bool handleWhitespace(TokenLiteral tokenLiteral, ParseState state) {
    if (!tokenLiteral.isWhitespace) return false;
    return true;
  }

  bool handleWord(TokenLiteral tokenLiteral, ParseState state) {
    if (!tokenLiteral.isWord) return false;

    switch (state) {
      case ParseState.capturing_metadata_key:
        wordDuringMetadataKey(tokenLiteral);
        return true;
      case ParseState.capturing_metadata_value:
        wordDuringMetadataValue(tokenLiteral);
        return true;
      case ParseState.capturing_movement_name:
        wordDuringMovementName(tokenLiteral);
        return true;
      case ParseState.capturing_note:
        wordDuringNote(tokenLiteral);
        return true;
      case ParseState.capturing_date:
        wordDuringDate(tokenLiteral);
        _state = ParseState.capturing_movement_name;
        return true;
      case ParseState.capturing_movement_performance:
        wordDuringPerformance(tokenLiteral);
        _state = ParseState.capturing_movement_name;
        return true;
      case ParseState.idle:
        beginMovementName(tokenLiteral);
        _state = ParseState.capturing_movement_name;
        return true;
      default:
        encounteredWord(tokenLiteral);
        return true;
    }
  }
}
