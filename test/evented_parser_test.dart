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
}
