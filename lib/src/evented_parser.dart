import "package:traindown/src/scanner.dart";
import "package:traindown/src/token.dart";

enum ParseState {
  atEof,
  awaitingPerformance,
  capturingDate,
  capturingMovementMetadataKey,
  capturingMovementMetadataValue,
  capturingMovementName,
  capturingMovementNote,
  capturingPerformance,
  capturingPerformanceMetadataKey,
  capturingPerformanceMetadataValue,
  capturingPerformanceNote,
  capturingSessionMetadataKey,
  capturingSessionMetadataValue,
  capturingSessionNote,
  idle,
  idleFollowingPerformance,
  initialized
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
  void amountDuringMovementMetadataKey(TokenLiteral tokenLiteral);
  void amountDuringMovementMetadataValue(TokenLiteral tokenLiteral);
  void amountDuringMovementNote(TokenLiteral tokenLiteral);
  void amountDuringPerformanceMetadataKey(TokenLiteral tokenLiteral);
  void amountDuringPerformanceMetadataValue(TokenLiteral tokenLiteral);
  void amountDuringPerformanceNote(TokenLiteral tokenLiteral);
  void amountDuringSessionMetadataKey(TokenLiteral tokenLiteral);
  void amountDuringSessionMetadataValue(TokenLiteral tokenLiteral);
  void amountDuringSessionNote(TokenLiteral tokenLiteral);
  void amountDuringPerformance(TokenLiteral tokenLiteral);
  void beginDate();
  void beginMovementMetadata();
  void beginMovementName(TokenLiteral tokenLiteral);
  void beginMovementNote();
  void beginPerformanceMetadata();
  void beginPerformanceNote();
  void beginSessionMetadata();
  void beginSessionNote();
  void encounteredDash(TokenLiteral tokenLiteral);
  void encounteredEof();
  void encounteredFailures(TokenLiteral tokenLiteral);
  void encounteredReps(TokenLiteral tokenLiteral);
  void encounteredPlus(TokenLiteral tokenLiteral);
  void encounteredSets(TokenLiteral tokenLiteral);
  void encounteredWord(TokenLiteral tokenLiteral);
  void endDate();
  void endMovementMetadataKey();
  void endMovementMetadataValue();
  void endMovementName();
  void endMovementNote();
  void endPerformance();
  void endPerformanceMetadataKey();
  void endPerformanceMetadataValue();
  void endPerformanceNote();
  void endSessionMetadataKey();
  void endSessionMetadataValue();
  void endSessionNote();
  void wordDuringDate(TokenLiteral tokenLiteral);
  void wordDuringMetadataKey(TokenLiteral tokenLiteral);
  void wordDuringMetadataValue(TokenLiteral tokenLiteral);
  void wordDuringMovementName(TokenLiteral tokenLiteral);
  void wordDuringNote(TokenLiteral tokenLiteral);
  void wordDuringPerformance(TokenLiteral tokenLiteral);

  void call() {
    if (_scanner == null) throw "Needs a scanner, dummy";

    while (!_scanner.eof) {
      _route(_scanner.scan());
      continue;
    }

    handleEof(TokenLiteral.eof(), _state);
  }

  // NOTE: This is a hamfisted approach that will be deprecated if/when
  // dart:mirrors gains Flutter/JS support.
  void _route(TokenLiteral tokenLiteral) {
    if (tokenLiteral.isAmount) handleAmount(tokenLiteral, _state);
    if (tokenLiteral.isAt) handleAt(tokenLiteral, _state);
    if (tokenLiteral.isColon) handleColon(tokenLiteral, _state);
    if (tokenLiteral.isDash) handleDash(tokenLiteral, _state);
    if (tokenLiteral.isEOF) handleEof(tokenLiteral, _state);
    if (tokenLiteral.isFails) handleFails(tokenLiteral, _state);
    if (tokenLiteral.isIllegal) handleIllegal(tokenLiteral, _state);
    if (tokenLiteral.isLinebreak) handleLinebreak(tokenLiteral, _state);
    if (tokenLiteral.isPlus) handlePlus(tokenLiteral, _state);
    if (tokenLiteral.isPound) handlePound(tokenLiteral, _state);
    if (tokenLiteral.isReps) handleReps(tokenLiteral, _state);
    if (tokenLiteral.isSets) handleSets(tokenLiteral, _state);
    if (tokenLiteral.isStar) handleStar(tokenLiteral, _state);
    if (tokenLiteral.isWhitespace) handleWhitespace(tokenLiteral, _state);
    if (tokenLiteral.isWord) handleWord(tokenLiteral, _state);
  }

  bool handleAmount(TokenLiteral tokenLiteral, ParseState state) {
    if (!tokenLiteral.isAmount) return false;

    switch (state) {
      case ParseState.capturingDate:
        amountDuringDate(tokenLiteral);
        return true;
      case ParseState.capturingMovementMetadataKey:
        amountDuringMovementMetadataKey(tokenLiteral);
        return true;
      case ParseState.capturingPerformanceMetadataKey:
        amountDuringPerformanceMetadataKey(tokenLiteral);
        return true;
      case ParseState.capturingSessionMetadataKey:
        amountDuringSessionMetadataKey(tokenLiteral);
        return true;
      case ParseState.capturingMovementMetadataValue:
        amountDuringMovementMetadataValue(tokenLiteral);
        return true;
      case ParseState.capturingPerformanceMetadataValue:
        amountDuringPerformanceMetadataValue(tokenLiteral);
        return true;
      case ParseState.capturingSessionMetadataValue:
        amountDuringSessionMetadataValue(tokenLiteral);
        return true;
      case ParseState.awaitingPerformance:
      case ParseState.capturingPerformance:
        amountDuringPerformance(tokenLiteral);
        _state = ParseState.capturingPerformance;
        return true;
      case ParseState.idleFollowingPerformance:
        endPerformance();
        amountDuringPerformance(tokenLiteral);
        _state = ParseState.capturingPerformance;
        return true;
      case ParseState.capturingMovementNote:
        amountDuringMovementNote(tokenLiteral);
        _state = ParseState.capturingPerformance;
        return true;
      case ParseState.capturingPerformanceNote:
        amountDuringPerformanceNote(tokenLiteral);
        _state = ParseState.capturingPerformance;
        return true;
      case ParseState.capturingSessionNote:
        amountDuringSessionNote(tokenLiteral);
        _state = ParseState.capturingPerformance;
        return true;
      case ParseState.idle:
        amountDuringIdle(tokenLiteral);
        _state = ParseState.capturingPerformance;
        return true;
      default:
        return false;
    }
  }

  bool handleAt(TokenLiteral tokenLiteral, ParseState state) {
    if (!tokenLiteral.isAt) return false;
    if (state != ParseState.initialized) return false;

    beginDate();
    _state = ParseState.capturingDate;
    return true;
  }

  bool handleColon(TokenLiteral tokenLiteral, ParseState state) {
    if (!tokenLiteral.isColon) return false;

    switch (state) {
      case ParseState.capturingMovementMetadataKey:
        endMovementMetadataKey();
        _state = ParseState.capturingMovementMetadataValue;
        return true;
      case ParseState.capturingPerformanceMetadataKey:
        endPerformanceMetadataKey();
        _state = ParseState.capturingPerformanceMetadataValue;
        return true;
      case ParseState.capturingSessionMetadataKey:
        endSessionMetadataKey();
        _state = ParseState.capturingSessionMetadataValue;
        return true;
      case ParseState.capturingMovementName:
        endMovementName();
        _state = ParseState.awaitingPerformance;
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

  bool handleEof(TokenLiteral tokenLiteral, ParseState state) {
    if (!tokenLiteral.isEOF) return false;

    switch (state) {
      case ParseState.capturingPerformanceMetadataValue:
        endPerformanceMetadataValue();
        encounteredEof();
        _state = ParseState.atEof;
        return true;
      case ParseState.capturingPerformanceNote:
        endPerformanceNote();
        encounteredEof();
        _state = ParseState.atEof;
        return true;
      default:
        encounteredEof();
        _state = ParseState.atEof;
        return true;
    }
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
      case ParseState.awaitingPerformance:
        return true;
      case ParseState.capturingDate:
        endDate();
        _state = ParseState.idle;
        return true;
      case ParseState.capturingMovementMetadataValue:
        endMovementMetadataValue();
        _state = ParseState.awaitingPerformance;
        return true;
      case ParseState.capturingPerformanceMetadataValue:
        endPerformanceMetadataValue();
        _state = ParseState.idleFollowingPerformance;
        return true;
      case ParseState.capturingSessionMetadataValue:
        endSessionMetadataValue();
        _state = ParseState.idle;
        return true;
      case ParseState.capturingPerformance:
        _state = ParseState.idleFollowingPerformance;
        return true;
      case ParseState.capturingMovementNote:
        endMovementNote();
        _state = ParseState.awaitingPerformance;
        return true;
      case ParseState.capturingPerformanceNote:
        endPerformanceNote();
        _state = ParseState.idleFollowingPerformance;
        return true;
      case ParseState.capturingSessionNote:
        endSessionNote();
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
      case ParseState.awaitingPerformance:
        beginMovementMetadata();
        _state = ParseState.capturingMovementMetadataKey;
        return true;
      case ParseState.capturingPerformance:
      case ParseState.idleFollowingPerformance:
        beginPerformanceMetadata();
        _state = ParseState.capturingPerformanceMetadataKey;
        return true;
      default:
        beginSessionMetadata();
        _state = ParseState.capturingSessionMetadataKey;
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
      case ParseState.awaitingPerformance:
      case ParseState.capturingMovementMetadataValue:
      case ParseState.capturingMovementNote:
        beginMovementNote();
        _state = ParseState.capturingMovementNote;
        return true;
      case ParseState.capturingPerformance:
      case ParseState.capturingPerformanceMetadataValue:
      case ParseState.capturingPerformanceNote:
      case ParseState.idleFollowingPerformance:
        beginPerformanceNote();
        _state = ParseState.capturingPerformanceNote;
        return true;
      default:
        beginSessionNote();
        _state = ParseState.capturingSessionNote;
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
      case ParseState.capturingDate:
        wordDuringDate(tokenLiteral);
        _state = ParseState.capturingMovementName;
        return true;
      case ParseState.capturingMovementMetadataKey:
      case ParseState.capturingPerformanceMetadataKey:
      case ParseState.capturingSessionMetadataKey:
        wordDuringMetadataKey(tokenLiteral);
        return true;
      case ParseState.capturingMovementMetadataValue:
      case ParseState.capturingPerformanceMetadataValue:
      case ParseState.capturingSessionMetadataValue:
        wordDuringMetadataValue(tokenLiteral);
        return true;
      case ParseState.capturingMovementName:
        wordDuringMovementName(tokenLiteral);
        return true;
      case ParseState.capturingMovementNote:
      case ParseState.capturingPerformanceNote:
      case ParseState.capturingSessionNote:
        wordDuringNote(tokenLiteral);
        return true;
      case ParseState.capturingPerformance:
        wordDuringPerformance(tokenLiteral);
        _state = ParseState.capturingMovementName;
        return true;
      case ParseState.idle:
        beginMovementName(tokenLiteral);
        _state = ParseState.capturingMovementName;
        return true;
      default:
        encounteredWord(tokenLiteral);
        return true;
    }
  }
}
