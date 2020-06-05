import "package:test/test.dart";

import "package:traindown/src/evented_parser.dart";
import "package:traindown/src/scanner.dart";
import "package:traindown/src/token.dart";

class TestParser extends EventedParser {
  TestParser(Scanner scanner) : super(scanner);
  TestParser.for_file(String filename) : super.for_file(filename);
  TestParser.for_string(String string) : super.for_string(string);

  List<String> calls = [];

  @override
  void amountDuringDate(TokenLiteral tokenLiteral) {
    calls.add("amountDuringDate");
  }

  @override
  void amountDuringIdle(TokenLiteral tokenLiteral) {
    calls.add("amountDuringIdle");
  }

  @override
  void amountDuringMovementMetadataKey(TokenLiteral tokenLiteral) {
    calls.add("amountDuringMovementMetadataKey");
  }

  @override
  void amountDuringMovementMetadataValue(TokenLiteral tokenLiteral) {
    calls.add("amountDuringMovementMetadataValue");
  }

  @override
  void amountDuringMovementNote(TokenLiteral tokenLiteral) {
    calls.add("amountDuringMovementNote");
  }

  @override
  void amountDuringPerformance(TokenLiteral tokenLiteral) {
    calls.add("amountDuringPerformance");
  }

  @override
  void amountDuringPerformanceMetadataKey(TokenLiteral tokenLiteral) {
    calls.add("amountDuringPerformanceMetadataKey");
  }

  @override
  void amountDuringPerformanceMetadataValue(TokenLiteral tokenLiteral) {
    calls.add("amountDuringPerformanceMetadataValue");
  }

  @override
  void amountDuringPerformanceNote(TokenLiteral tokenLiteral) {
    calls.add("amountDuringPerformanceNote");
  }

  @override
  void amountDuringSessionMetadataKey(TokenLiteral tokenLiteral) {
    calls.add("amountDuringSessionMetadataKey");
  }

  @override
  void amountDuringSessionMetadataValue(TokenLiteral tokenLiteral) {
    calls.add("amountDuringSessionMetadataValue");
  }

  @override
  void amountDuringSessionNote(TokenLiteral tokenLiteral) {
    calls.add("amountDuringSessionNote");
  }

  @override
  void beginDate() {
    calls.add("beginDate");
  }

  @override
  void beginMovementMetadata() {
    calls.add("beginMovementMetadata");
  }

  @override
  void beginMovementName(TokenLiteral tokenLiteral) {
    calls.add("beginMovementName");
  }

  @override
  void beginMovementNote() {
    calls.add("beginMovementNote");
  }

  @override
  void beginPerformanceMetadata() {
    calls.add("beginPerformanceMetadata");
  }

  @override
  void beginPerformanceNote() {
    calls.add("beginPerformanceNote");
  }

  @override
  void beginSessionMetadata() {
    calls.add("beginSessionMetadata");
  }

  @override
  void beginSessionNote() {
    calls.add("beginSessionNote");
  }

  @override
  void encounteredDash(TokenLiteral tokenLiteral) {
    calls.add("encounteredDash");
  }

  @override
  void encounteredEof() {
    calls.add("encounteredEof");
  }

  @override
  void encounteredFailures(TokenLiteral tokenLiteral) {
    calls.add("encounteredFailures");
  }

  @override
  void encounteredReps(TokenLiteral tokenLiteral) {
    calls.add("encounteredReps");
  }

  @override
  void encounteredPlus(TokenLiteral tokenLiteral) {
    calls.add("encounteredPlus");
  }

  @override
  void encounteredSets(TokenLiteral tokenLiteral) {
    calls.add("encounteredSets");
  }

  @override
  void encounteredWord(TokenLiteral tokenLiteral) {
    calls.add("encounteredWord");
  }

  @override
  void endDate() {
    calls.add("endDate");
  }

  @override
  void endMovementMetadataKey() {
    calls.add("endMovementMetadataKey");
  }

  @override
  void endMovementMetadataValue() {
    calls.add("endMovementMetadataValue");
  }

  @override
  void endPerformanceMetadataKey() {
    calls.add("endPerformanceMetadataKey");
  }

  @override
  void endPerformanceMetadataValue() {
    calls.add("endPerformanceMetadataValue");
  }

  @override
  void endSessionMetadataKey() {
    calls.add("endSessionMetadataKey");
  }

  @override
  void endSessionMetadataValue() {
    calls.add("endSessionMetadataValue");
  }

  @override
  void endMovementName() {
    calls.add("endMovementName");
  }

  @override
  void endMovementNote() {
    calls.add("endMovementNote");
  }

  @override
  void endPerformanceNote() {
    calls.add("endPerformanceNote");
  }

  @override
  void endSessionNote() {
    calls.add("endSessionNote");
  }

  @override
  void endPerformance() {
    calls.add("endPerformance");
  }

  @override
  void wordDuringDate(TokenLiteral tokenLiteral) {
    calls.add("wordDuringDate");
  }

  @override
  void wordDuringMetadataKey(TokenLiteral tokenLiteral) {
    calls.add("wordDuringMetadataKey");
  }

  @override
  void wordDuringMetadataValue(TokenLiteral tokenLiteral) {
    calls.add("wordDuringMetadataValue");
  }

  @override
  void wordDuringMovementName(TokenLiteral tokenLiteral) {
    calls.add("wordDuringMovementName");
  }

  @override
  void wordDuringNote(TokenLiteral tokenLiteral) {
    calls.add("wordDuringNote");
  }

  @override
  void wordDuringPerformance(TokenLiteral tokenLiteral) {
    calls.add("wordDuringPerformance");
  }
}

void main() {
  TestParser subject;
  setUp(() => subject = TestParser.for_string(""));

  group("handleAmount", () {
    test("A TokenLiteral other than Amount", () {
      TokenLiteral notAmount = TokenLiteral(Token.AT, "@");
      bool result = subject.handleAmount(notAmount, ParseState.idle);
      expect(result, false);
    });

    group("With an Amount TokenLiteral", () {
      TokenLiteral amount = TokenLiteral(Token.AMOUNT, "1");
      ParseState state;

      var getResult = () => subject.handleAmount(amount, state);

      test("with capturingDate state", () {
        state = ParseState.capturingDate;
        expect(getResult(), true);
        expect(subject.calls, ["amountDuringDate"]);
      });

      test("with capturingMovementMetadataKey state", () {
        state = ParseState.capturingMovementMetadataKey;
        expect(getResult(), true);
        expect(subject.calls, ["amountDuringMovementMetadataKey"]);
      });

      test("with capturingMovementMetadataValue state", () {
        state = ParseState.capturingMovementMetadataKey;
        expect(getResult(), true);
        expect(subject.calls, ["amountDuringMovementMetadataKey"]);
      });

      test("with capturingPerformanceMetadataKey state", () {
        state = ParseState.capturingPerformanceMetadataKey;
        expect(getResult(), true);
        expect(subject.calls, ["amountDuringPerformanceMetadataKey"]);
      });

      test("with capturingPerformanceMetadataValue state", () {
        state = ParseState.capturingPerformanceMetadataKey;
        expect(getResult(), true);
        expect(subject.calls, ["amountDuringPerformanceMetadataKey"]);
      });

      test("with capturingSessionMetadataKey state", () {
        state = ParseState.capturingSessionMetadataKey;
        expect(getResult(), true);
        expect(subject.calls, ["amountDuringSessionMetadataKey"]);
      });

      test("with capturingSessionMetadataValue state", () {
        state = ParseState.capturingSessionMetadataKey;
        expect(getResult(), true);
        expect(subject.calls, ["amountDuringSessionMetadataKey"]);
      });

      test("with idle state", () {
        state = ParseState.idle;
        expect(getResult(), true);
        expect(subject.calls, ["amountDuringIdle"]);
        expect(subject.state, ParseState.capturingPerformance);
      });

      test("with unexpected state", () {
        state = ParseState.initialized;
        expect(getResult(), false);
        expect(subject.calls, []);
      });
    });
  });

  group("handleAt", () {
    test("A TokenLiteral other than At", () {
      TokenLiteral notAt = TokenLiteral(Token.AMOUNT, "1");
      bool result = subject.handleAt(notAt, ParseState.idle);
      expect(result, false);
    });

    group("With an At TokenLiteral", () {
      TokenLiteral at = TokenLiteral(Token.AT, "@");
      ParseState state;

      var getResult = () => subject.handleAt(at, state);

      test("with initialized state", () {
        state = ParseState.initialized;
        expect(getResult(), true);
        expect(subject.calls, ["beginDate"]);
        expect(subject.state, ParseState.capturingDate);
      });

      test("with unexpected state", () {
        state = ParseState.idle;
        expect(getResult(), false);
        expect(subject.calls, []);
      });
    });
  });

  group("handleColon", () {
    test("A TokenLiteral other than Colon", () {
      TokenLiteral notColon = TokenLiteral(Token.AMOUNT, "1");
      bool result = subject.handleColon(notColon, ParseState.idle);
      expect(result, false);
    });

    group("With an At TokenLiteral", () {
      TokenLiteral colon = TokenLiteral(Token.COLON, ":");
      ParseState state;

      var getResult = () => subject.handleColon(colon, state);

      test("with capturingMovementMetadataKey state", () {
        state = ParseState.capturingMovementMetadataKey;
        expect(getResult(), true);
        expect(subject.calls, ["endMovementMetadataKey"]);
        expect(subject.state, ParseState.capturingMovementMetadataValue);
      });

      test("with capturingPerformanceMetadataKey state", () {
        state = ParseState.capturingPerformanceMetadataKey;
        expect(getResult(), true);
        expect(subject.calls, ["endPerformanceMetadataKey"]);
        expect(subject.state, ParseState.capturingPerformanceMetadataValue);
      });

      test("with capturingMovementName state", () {
        state = ParseState.capturingMovementName;
        expect(getResult(), true);
        expect(subject.calls, ["endMovementName"]);
        expect(subject.state, ParseState.awaitingPerformance);
      });

      test("with capturingSessionMetadataKey state", () {
        state = ParseState.capturingSessionMetadataKey;
        expect(getResult(), true);
        expect(subject.calls, ["endSessionMetadataKey"]);
        expect(subject.state, ParseState.capturingSessionMetadataValue);
      });

      test("with unexpected state", () {
        state = ParseState.idle;
        expect(getResult(), false);
        expect(subject.calls, []);
      });
    });
  });

  group("handleDash", () {
    test("A TokenLiteral other than dash", () {
      TokenLiteral notDash = TokenLiteral(Token.AMOUNT, "1");
      bool result = subject.handleAt(notDash, ParseState.idle);
      expect(result, false);
    });

    group("With a dash TokenLiteral", () {
      TokenLiteral dash = TokenLiteral(Token.DASH, "-");
      ParseState state;

      var getResult = () => subject.handleDash(dash, state);

      ParseState.values.forEach((possibleState) {
        test("with $possibleState state", () {
          state = possibleState;
          expect(getResult(), true);
          expect(subject.calls, ["encounteredDash"]);
        });
      });
    });
  });

  group("handleFails", () {
    test("A TokenLiteral other than fails", () {
      TokenLiteral notFails = TokenLiteral(Token.AMOUNT, "1");
      bool result = subject.handleFails(notFails, ParseState.idle);
      expect(result, false);
    });

    group("With a fails TokenLiteral", () {
      TokenLiteral fails = TokenLiteral(Token.FAILS, "1");
      ParseState state;

      var getResult = () => subject.handleFails(fails, state);

      ParseState.values.forEach((possibleState) {
        test("with $possibleState state", () {
          state = possibleState;
          expect(getResult(), true);
          expect(subject.calls, ["encounteredFailures"]);
        });
      });
    });
  });

  group("handleIllegal", () {
    test("A TokenLiteral other than illegal", () {
      TokenLiteral notIllegal = TokenLiteral(Token.AMOUNT, "1");
      bool result = subject.handleIllegal(notIllegal, ParseState.idle);
      expect(result, false);
    });

    group("With an illegal TokenLiteral", () {
      TokenLiteral illegal = TokenLiteral(Token.ILLEGAL, "!");
      ParseState state;

      var getResult = () => subject.handleIllegal(illegal, state);

      ParseState.values.forEach((possibleState) {
        test("with $possibleState state", () {
          state = possibleState;
          expect(getResult(), true);
        });
      });
    });
  });

  group("handleLinebreak", () {
    test("A TokenLiteral other than linebreak", () {
      TokenLiteral notLinebreak = TokenLiteral(Token.AMOUNT, "1");
      bool result = subject.handleLinebreak(notLinebreak, ParseState.idle);
      expect(result, false);
    });

    group("With a linebreak TokenLiteral", () {
      TokenLiteral linebreak = TokenLiteral(Token.LINEBREAK, "\n");
      ParseState state;

      var getResult = () => subject.handleLinebreak(linebreak, state);

      test("with capturingDate state", () {
        state = ParseState.capturingDate;
        expect(getResult(), true);
        expect(subject.calls, ["endDate"]);
        expect(subject.state, ParseState.idle);
      });

      test("with capturingMovementMetadataValue state", () {
        state = ParseState.capturingMovementMetadataValue;
        expect(getResult(), true);
        expect(subject.calls, ["endMovementMetadataValue"]);
        expect(subject.state, ParseState.idle);
      });

      test("with capturingMovementNote state", () {
        state = ParseState.capturingMovementNote;
        expect(getResult(), true);
        expect(subject.calls, ["endMovementNote"]);
        expect(subject.state, ParseState.idle);
      });

      test("with capturingPerformance state", () {
        state = ParseState.capturingPerformance;
        expect(getResult(), true);
        expect(subject.calls, ["endPerformance"]);
        expect(subject.state, ParseState.idle);
      });

      test("with capturingPerformanceMetadataValue state", () {
        state = ParseState.capturingPerformanceMetadataValue;
        expect(getResult(), true);
        expect(subject.calls, ["endPerformanceMetadataValue"]);
        expect(subject.state, ParseState.idle);
      });

      test("with capturingPerformanceNote state", () {
        state = ParseState.capturingPerformanceNote;
        expect(getResult(), true);
        expect(subject.calls, ["endPerformanceNote"]);
        expect(subject.state, ParseState.idle);
      });

      test("with capturingSessionMetadataValue state", () {
        state = ParseState.capturingSessionMetadataValue;
        expect(getResult(), true);
        expect(subject.calls, ["endSessionMetadataValue"]);
        expect(subject.state, ParseState.idle);
      });

      test("with capturingSessionNote state", () {
        state = ParseState.capturingSessionNote;
        expect(getResult(), true);
        expect(subject.calls, ["endSessionNote"]);
        expect(subject.state, ParseState.idle);
      });

      test("with unexpected state", () {
        state = ParseState.idle;
        expect(getResult(), true);
        expect(subject.calls, []);
        expect(subject.state, ParseState.idle);
      });
    });
  });

  group("handlePlus", () {
    test("A TokenLiteral other than plus", () {
      TokenLiteral notPlus = TokenLiteral(Token.AMOUNT, "1");
      bool result = subject.handlePlus(notPlus, ParseState.idle);
      expect(result, false);
    });

    group("With a plus TokenLiteral", () {
      TokenLiteral plus = TokenLiteral(Token.PLUS, "+");
      ParseState state;

      var getResult = () => subject.handlePlus(plus, state);

      ParseState.values.forEach((possibleState) {
        test("with $possibleState state", () {
          state = possibleState;
          expect(getResult(), true);
          expect(subject.calls, ["encounteredPlus"]);
        });
      });
    });
  });

  group("handlePound", () {
    test("A TokenLiteral other than pound", () {
      TokenLiteral notPound = TokenLiteral(Token.AMOUNT, "1");
      bool result = subject.handlePound(notPound, ParseState.idle);
      expect(result, false);
    });

    group("With a pound TokenLiteral", () {
      TokenLiteral pound = TokenLiteral(Token.POUND, "#");
      ParseState state;

      var getResult = () => subject.handlePound(pound, state);

      test("with awaitingPerformance", () {
        state = ParseState.awaitingPerformance;
        expect(getResult(), true);
        expect(subject.calls, ["beginMovementMetadata"]);
        expect(subject.state, ParseState.capturingMovementMetadataKey);
      });

      test("with capturingPerformance", () {
        state = ParseState.capturingPerformance;
        expect(getResult(), true);
        expect(subject.calls, ["beginPerformanceMetadata"]);
        expect(subject.state, ParseState.capturingPerformanceMetadataKey);
      });

      test("with unexpected state", () {
        state = ParseState.idle;
        expect(getResult(), true);
        expect(subject.calls, ["beginSessionMetadata"]);
        expect(subject.state, ParseState.capturingSessionMetadataKey);
      });
    });
  });

  group("handleReps", () {
    test("A TokenLiteral other than reps", () {
      TokenLiteral notReps = TokenLiteral(Token.AMOUNT, "1");
      bool result = subject.handleReps(notReps, ParseState.idle);
      expect(result, false);
    });

    group("With a reps TokenLiteral", () {
      TokenLiteral reps = TokenLiteral(Token.REPS, "1");
      ParseState state;

      var getResult = () => subject.handleReps(reps, state);

      ParseState.values.forEach((possibleState) {
        test("with $possibleState state", () {
          state = possibleState;
          expect(getResult(), true);
          expect(subject.calls, ["encounteredReps"]);
        });
      });
    });
  });

  group("handleSets", () {
    test("A TokenLiteral other than sets", () {
      TokenLiteral notSets = TokenLiteral(Token.AMOUNT, "1");
      bool result = subject.handleSets(notSets, ParseState.idle);
      expect(result, false);
    });

    group("With a sets TokenLiteral", () {
      TokenLiteral sets = TokenLiteral(Token.SETS, "1");
      ParseState state;

      var getResult = () => subject.handleSets(sets, state);

      ParseState.values.forEach((possibleState) {
        test("with $possibleState state", () {
          state = possibleState;
          expect(getResult(), true);
          expect(subject.calls, ["encounteredSets"]);
        });
      });
    });
  });

  group("handleStar", () {
    test("A TokenLiteral other than star", () {
      TokenLiteral notStar = TokenLiteral(Token.AMOUNT, "1");
      bool result = subject.handleStar(notStar, ParseState.idle);
      expect(result, false);
    });

    group("With a star TokenLiteral", () {
      TokenLiteral star = TokenLiteral(Token.STAR, "*");
      ParseState state;

      var getResult = () => subject.handleStar(star, state);

      test("with awaitingPerformance", () {
        state = ParseState.awaitingPerformance;
        expect(getResult(), true);
        expect(subject.calls, ["beginMovementNote"]);
        expect(subject.state, ParseState.capturingMovementNote);
      });

      test("with capturingPerformance", () {
        state = ParseState.capturingPerformance;
        expect(getResult(), true);
        expect(subject.calls, ["beginPerformanceNote"]);
        expect(subject.state, ParseState.capturingPerformanceNote);
      });

      test("with unexpected state", () {
        state = ParseState.idle;
        expect(getResult(), true);
        expect(subject.calls, ["beginSessionNote"]);
        expect(subject.state, ParseState.capturingSessionNote);
      });
    });
  });

  group("handleWhitespace", () {
    test("A TokenLiteral other than whitespace", () {
      TokenLiteral notWhitespace = TokenLiteral(Token.AMOUNT, "1");
      bool result = subject.handleWhitespace(notWhitespace, ParseState.idle);
      expect(result, false);
    });

    group("With a whitespace TokenLiteral", () {
      TokenLiteral whitespace = TokenLiteral(Token.WHITESPACE, " ");
      ParseState state;

      var getResult = () => subject.handleWhitespace(whitespace, state);

      ParseState.values.forEach((possibleState) {
        test("with $possibleState state", () {
          state = possibleState;
          expect(getResult(), true);
        });
      });
    });
  });

  group("handleWord", () {
    test("A TokenLiteral other than word", () {
      TokenLiteral notWord = TokenLiteral(Token.AMOUNT, "1");
      bool result = subject.handleWord(notWord, ParseState.idle);
      expect(result, false);
    });

    group("With a word TokenLiteral", () {
      TokenLiteral word = TokenLiteral(Token.WORD, "yay");
      ParseState state;

      var getResult = () => subject.handleWord(word, state);

      test("with capturingDate", () {
        state = ParseState.capturingDate;
        expect(getResult(), true);
        expect(subject.calls, ["wordDuringDate"]);
        expect(subject.state, ParseState.capturingMovementName);
      });

      test("with capturingMovementMetadataKey", () {
        state = ParseState.capturingMovementMetadataKey;
        expect(getResult(), true);
        expect(subject.calls, ["wordDuringMetadataKey"]);
      });

      test("with capturingMovementMetadataValue", () {
        state = ParseState.capturingMovementMetadataValue;
        expect(getResult(), true);
        expect(subject.calls, ["wordDuringMetadataValue"]);
      });

      test("with capturingMovementName", () {
        state = ParseState.capturingMovementName;
        expect(getResult(), true);
        expect(subject.calls, ["wordDuringMovementName"]);
      });

      test("with capturingMovementNote", () {
        state = ParseState.capturingMovementNote;
        expect(getResult(), true);
        expect(subject.calls, ["wordDuringNote"]);
      });

      test("with capturingPerformance", () {
        state = ParseState.capturingPerformance;
        expect(getResult(), true);
        expect(subject.calls, ["wordDuringPerformance"]);
        expect(subject.state, ParseState.capturingMovementName);
      });

      test("with capturingPerformanceMetadataKey", () {
        state = ParseState.capturingPerformanceMetadataKey;
        expect(getResult(), true);
        expect(subject.calls, ["wordDuringMetadataKey"]);
      });

      test("with capturingPerformanceMetadataValue", () {
        state = ParseState.capturingPerformanceMetadataValue;
        expect(getResult(), true);
        expect(subject.calls, ["wordDuringMetadataValue"]);
      });

      test("with capturingPerformanceNote", () {
        state = ParseState.capturingPerformanceNote;
        expect(getResult(), true);
        expect(subject.calls, ["wordDuringNote"]);
      });

      test("with capturingSessionMetadataKey", () {
        state = ParseState.capturingSessionMetadataKey;
        expect(getResult(), true);
        expect(subject.calls, ["wordDuringMetadataKey"]);
      });

      test("with capturingSessionMetadataValue", () {
        state = ParseState.capturingSessionMetadataValue;
        expect(getResult(), true);
        expect(subject.calls, ["wordDuringMetadataValue"]);
      });

      test("with capturingSessionNote", () {
        state = ParseState.capturingSessionNote;
        expect(getResult(), true);
        expect(subject.calls, ["wordDuringNote"]);
      });

      test("with idle", () {
        state = ParseState.idle;
        expect(getResult(), true);
        expect(subject.calls, ["beginMovementName"]);
        expect(subject.state, ParseState.capturingMovementName);
      });

      test("with unexpected state", () {
        state = ParseState.initialized;
        expect(getResult(), true);
        expect(subject.calls, ["encounteredWord"]);
      });
    });
  });
}
