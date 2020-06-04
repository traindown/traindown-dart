import "package:test/test.dart";

import "package:traindown/src/evented_parser.dart";
import "package:traindown/src/scanner.dart";
import "package:traindown/src/token.dart";

class TestParser extends EventedParser {
  TestParser(Scanner scanner) : super(scanner);
  TestParser.for_file(String filename) : super.for_file(filename);
  TestParser.for_string(String string) : super.for_string(string);

  List<String> calls = [];

  void amountDuringDate(TokenLiteral tokenLiteral) {
    calls.add("amountDuringDate");
  }

  void amountDuringIdle(TokenLiteral tokenLiteral) {
    calls.add("amountDuringIdle");
  }

  void amountDuringMetadataKey(TokenLiteral tokenLiteral) {
    calls.add("amountDuringMetadataKey");
  }

  void amountDuringMetadataValue(TokenLiteral tokenLiteral) {
    calls.add("amountDuringMetadataValue");
  }

  void amountDuringPerformance(TokenLiteral tokenLiteral) {
    calls.add("amountDuringPerformance");
  }

  void beginDate() {
    calls.add("beginDate");
  }

  void beginMetadata() {
    calls.add("beginMetadata");
  }

  void beginMovementName(TokenLiteral tokenLiteral) {
    calls.add("beginMovementName");
  }

  void beginNote() {
    calls.add("beginNote");
  }

  void beginPerformanceMetadata(TokenLiteral tokenLiteral) {
    calls.add("beginPerformanceMetadata");
  }

  void beginPerformanceNote(TokenLiteral tokenLiteral) {
    calls.add("beginPerformanceNote");
  }

  void encounteredDash(TokenLiteral tokenLiteral) {
    calls.add("encounteredDash");
  }

  void encounteredEof() {
    calls.add("encounteredEof");
  }

  void encounteredFailures(TokenLiteral tokenLiteral) {
    calls.add("encounteredFailures");
  }

  void encounteredReps(TokenLiteral tokenLiteral) {
    calls.add("encounteredReps");
  }

  void encounteredPlus(TokenLiteral tokenLiteral) {
    calls.add("encounteredPlus");
  }

  void encounteredSets(TokenLiteral tokenLiteral) {
    calls.add("encounteredSets");
  }

  void encounteredWord(TokenLiteral tokenLiteral) {
    calls.add("encounteredWord");
  }

  void endDate() {
    calls.add("endDate");
  }

  void endMetadataKey() {
    calls.add("endMetadataKey");
  }

  void endMetadataValue() {
    calls.add("endMetadataValue");
  }

  void endMovementName() {
    calls.add("endMovementName");
  }

  void endNote() {
    calls.add("endNote");
  }

  void endPerformance() {
    calls.add("endPerformance");
  }

  void wordDuringDate(TokenLiteral tokenLiteral) {
    calls.add("wordDuringDate");
  }

  void wordDuringMetadataKey(TokenLiteral tokenLiteral) {
    calls.add("wordDuringMetadataKey");
  }

  void wordDuringMetadataValue(TokenLiteral tokenLiteral) {
    calls.add("wordDuringMetadataValue");
  }

  void wordDuringMovementName(TokenLiteral tokenLiteral) {
    calls.add("wordDuringMovementName");
  }

  void wordDuringNote(TokenLiteral tokenLiteral) {
    calls.add("wordDuringNote");
  }

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

      test("with capturing_date state", () {
        state = ParseState.capturing_date;
        expect(getResult(), true);
        expect(subject.calls, ["amountDuringDate"]);
      });

      test("with capturing_metadata_key state", () {
        state = ParseState.capturing_metadata_key;
        expect(getResult(), true);
        expect(subject.calls, ["amountDuringMetadataKey"]);
      });

      test("with capturing_metadata_value state", () {
        state = ParseState.capturing_metadata_key;
        expect(getResult(), true);
        expect(subject.calls, ["amountDuringMetadataKey"]);
      });

      test("with idle state", () {
        state = ParseState.idle;
        expect(getResult(), true);
        expect(subject.calls, ["amountDuringIdle"]);
        expect(subject.state, ParseState.capturing_movement_performance);
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
        expect(subject.state, ParseState.capturing_date);
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

      test("with capturing_metadata_key state", () {
        state = ParseState.capturing_metadata_key;
        expect(getResult(), true);
        expect(subject.calls, ["endMetadataKey"]);
        expect(subject.state, ParseState.capturing_metadata_value);
      });

      test("with capturing_movement_name state", () {
        state = ParseState.capturing_movement_name;
        expect(getResult(), true);
        expect(subject.calls, ["endMovementName"]);
        expect(subject.state, ParseState.capturing_movement_performance);
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

      test("with capturing_date state", () {
        state = ParseState.capturing_date;
        expect(getResult(), true);
        expect(subject.calls, ["endDate"]);
        expect(subject.state, ParseState.idle);
      });

      test("with capturing_metadata_value state", () {
        state = ParseState.capturing_metadata_value;
        expect(getResult(), true);
        expect(subject.calls, ["endMetadataValue"]);
        expect(subject.state, ParseState.idle);
      });

      test("with capturing_movement_performance state", () {
        state = ParseState.capturing_movement_performance;
        expect(getResult(), true);
        expect(subject.calls, ["endPerformance"]);
        expect(subject.state, ParseState.idle);
      });

      test("with capturing_note state", () {
        state = ParseState.capturing_note;
        expect(getResult(), true);
        expect(subject.calls, ["endNote"]);
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

      test("with capturing_movement_performance", () {
        state = ParseState.capturing_movement_performance;
        expect(getResult(), true);
        expect(subject.calls, ["beginPerformanceMetadata"]);
        expect(subject.state, ParseState.capturing_metadata_key);
      });

      test("with unexpected state", () {
        state = ParseState.idle;
        expect(getResult(), true);
        expect(subject.calls, ["beginMetadata"]);
        expect(subject.state, ParseState.capturing_metadata_key);
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

      test("with capturing_movement_performance", () {
        state = ParseState.capturing_movement_performance;
        expect(getResult(), true);
        expect(subject.calls, ["beginPerformanceNote"]);
        expect(subject.state, ParseState.capturing_note);
      });

      test("with unexpected state", () {
        state = ParseState.idle;
        expect(getResult(), true);
        expect(subject.calls, ["beginNote"]);
        expect(subject.state, ParseState.capturing_note);
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

      test("with capturing_metadata_key", () {
        state = ParseState.capturing_metadata_key;
        expect(getResult(), true);
        expect(subject.calls, ["wordDuringMetadataKey"]);
      });

      test("with capturing_metadata_value", () {
        state = ParseState.capturing_metadata_value;
        expect(getResult(), true);
        expect(subject.calls, ["wordDuringMetadataValue"]);
      });

      test("with capturing_movement_name", () {
        state = ParseState.capturing_movement_name;
        expect(getResult(), true);
        expect(subject.calls, ["wordDuringMovementName"]);
      });

      test("with capturing_note", () {
        state = ParseState.capturing_note;
        expect(getResult(), true);
        expect(subject.calls, ["wordDuringNote"]);
      });

      test("with capturing_date", () {
        state = ParseState.capturing_date;
        expect(getResult(), true);
        expect(subject.calls, ["wordDuringDate"]);
        expect(subject.state, ParseState.capturing_movement_name);
      });

      test("with capturing_movement_performance", () {
        state = ParseState.capturing_movement_performance;
        expect(getResult(), true);
        expect(subject.calls, ["wordDuringPerformance"]);
        expect(subject.state, ParseState.capturing_movement_name);
      });

      test("with idle", () {
        state = ParseState.idle;
        expect(getResult(), true);
        expect(subject.calls, ["beginMovementName"]);
        expect(subject.state, ParseState.capturing_movement_name);
      });

      test("with unexpected state", () {
        state = ParseState.initialized;
        expect(getResult(), true);
        expect(subject.calls, ["encounteredWord"]);
      });
    });
  });
}
