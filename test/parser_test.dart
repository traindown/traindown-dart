import "package:mockito/mockito.dart";
import "package:test/test.dart";

import "package:traindown/src/movement.dart";
import "package:traindown/src/parser.dart";
import "package:traindown/src/scanner.dart";
import "package:traindown/src/token.dart";

class ScannerMock extends Fake implements Scanner {
  int _index = 0;

  /*
    @ 2020-01-01
    # Key Key: Value Value
    * This is note.
    Movement Name: 100 200 2r 300 2s 400 2r 2s
  */

  final List<TokenLiteral> _tokenLiterals = [
    TokenLiteral(Token.AT, "@"),
    TokenLiteral(Token.WHITESPACE, " "),
    TokenLiteral(Token.AMOUNT, "2020"),
    TokenLiteral(Token.DASH, "-"),
    TokenLiteral(Token.AMOUNT, "01"),
    TokenLiteral(Token.DASH, "-"),
    TokenLiteral(Token.AMOUNT, "01"),
    TokenLiteral(Token.LINEBREAK, ""),
    TokenLiteral(Token.POUND, "#"),
    TokenLiteral(Token.WHITESPACE, " "),
    TokenLiteral(Token.WORD, "Key"),
    TokenLiteral(Token.WHITESPACE, " "),
    TokenLiteral(Token.WORD, "Key"),
    TokenLiteral(Token.COLON, ":"),
    TokenLiteral(Token.WHITESPACE, " "),
    TokenLiteral(Token.WORD, "Value"),
    TokenLiteral(Token.WHITESPACE, " "),
    TokenLiteral(Token.WORD, "Value"),
    TokenLiteral(Token.LINEBREAK, ""),
    TokenLiteral(Token.STAR, "*"),
    TokenLiteral(Token.WHITESPACE, " "),
    TokenLiteral(Token.WORD, "This"),
    TokenLiteral(Token.WHITESPACE, " "),
    TokenLiteral(Token.WORD, "is"),
    TokenLiteral(Token.WHITESPACE, " "),
    TokenLiteral(Token.WORD, "note."),
    TokenLiteral(Token.LINEBREAK, ""),
    TokenLiteral(Token.WORD, "Movement"),
    TokenLiteral(Token.WHITESPACE, " "),
    TokenLiteral(Token.WORD, "Name"),
    TokenLiteral(Token.COLON, ":"),
    TokenLiteral(Token.WHITESPACE, " "),
    TokenLiteral(Token.AMOUNT, "100"),
    TokenLiteral(Token.WHITESPACE, " "),
    TokenLiteral(Token.AMOUNT, "200"),
    TokenLiteral(Token.WHITESPACE, " "),
    TokenLiteral(Token.REPS, "2"),
    TokenLiteral(Token.WHITESPACE, " "),
    TokenLiteral(Token.AMOUNT, "300"),
    TokenLiteral(Token.WHITESPACE, " "),
    TokenLiteral(Token.SETS, "2"),
    TokenLiteral(Token.WHITESPACE, " "),
    TokenLiteral(Token.AMOUNT, "400"),
    TokenLiteral(Token.WHITESPACE, " "),
    TokenLiteral(Token.REPS, "2"),
    TokenLiteral(Token.WHITESPACE, " "),
    TokenLiteral(Token.SETS, "2"),
    TokenLiteral(Token.EOF, ""),
  ];

  @override
  bool get eof => _index == _tokenLiterals.length - 1;

  @override
  TokenLiteral scan() => _tokenLiterals[_index++];

  @override
  TokenLiteral unscan() => _tokenLiterals[_index--];
}

void main() {
  group("Constructor", () {
    test("An instance of Scanner is required for init", () {
      try {
        Parser(null);
      } catch (e) {
        expect(e, "Needs a scanner, dummy");
        return;
      }
      throw "Should have failed init";
    });
  });

  group("parse()", () {
    Parser parser = Parser(ScannerMock());

    group("After calling", () {
      parser.parse();

      test("Metadata is correctly captured", () {
        expect(parser.metadata.kvps, {"Key Key": "Value Value"});
      });

      test("Notes are correctly captured", () {
        expect(parser.metadata.notes, ["This is note."]);
      });

      test("Movements are correctly captured", () {
        Movement movement = parser.movements[0];
        expect(movement is Movement, true);
        expect(movement.name, "Movement Name");
        expect(movement.performances.length, 4);

        var ps = movement.performances;
        expect(ps[0].toString(), "100 unknown unit for 1 sets of 1 reps.");
        expect(ps[1].toString(), "200 unknown unit for 1 sets of 2 reps.");
        expect(ps[2].toString(), "300 unknown unit for 2 sets of 1 reps.");
        expect(ps[3].toString(), "400 unknown unit for 2 sets of 2 reps.");
      });
    });
  });
}
