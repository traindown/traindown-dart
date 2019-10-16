import 'package:mockito/mockito.dart';
import "package:test/test.dart";

import "package:traindown/src/movement.dart";
import "package:traindown/src/parser.dart";
import "package:traindown/src/scanner.dart";
import "package:traindown/src/token.dart";

class ScannerMock extends Fake implements Scanner {
  var _index = 0;

  /*
    # Key Key: Value Value
    * This is note.
    Movement: 100; 200 2r; 300 2s; 400 2r 2s;
  */

  var _tokenLiterals = [
    TokenLiteral(Token.POUND, "#"),
    TokenLiteral(Token.WHITESPACE, " "),
    TokenLiteral(Token.IDENT, "Key"),
    TokenLiteral(Token.WHITESPACE, " "),
    TokenLiteral(Token.IDENT, "Key"),
    TokenLiteral(Token.COLON, ":"),
    TokenLiteral(Token.WHITESPACE, " "),
    TokenLiteral(Token.IDENT, "Value"),
    TokenLiteral(Token.WHITESPACE, " "),
    TokenLiteral(Token.IDENT, "Value"),
    TokenLiteral(Token.LINEBREAK, ""),
    TokenLiteral(Token.STAR, "*"),
    TokenLiteral(Token.WHITESPACE, " "),
    TokenLiteral(Token.IDENT, "This"),
    TokenLiteral(Token.WHITESPACE, " "),
    TokenLiteral(Token.IDENT, "is"),
    TokenLiteral(Token.WHITESPACE, " "),
    TokenLiteral(Token.IDENT, "note."),
    TokenLiteral(Token.LINEBREAK, ""),
    TokenLiteral(Token.IDENT, "Movement"),
    TokenLiteral(Token.WHITESPACE, " "),
    TokenLiteral(Token.IDENT, "Name"),
    TokenLiteral(Token.COLON, ":"),
    TokenLiteral(Token.WHITESPACE, " "),
    TokenLiteral(Token.UNIT, "100"),
    TokenLiteral(Token.SEMICOLON, ";"),
    TokenLiteral(Token.WHITESPACE, " "),
    TokenLiteral(Token.UNIT, "200"),
    TokenLiteral(Token.WHITESPACE, " "),
    TokenLiteral(Token.UNIT, "2"),
    TokenLiteral(Token.IDENT, "r"),
    TokenLiteral(Token.SEMICOLON, ";"),
    TokenLiteral(Token.WHITESPACE, " "),
    TokenLiteral(Token.UNIT, "300"),
    TokenLiteral(Token.WHITESPACE, " "),
    TokenLiteral(Token.UNIT, "2"),
    TokenLiteral(Token.IDENT, "s"),
    TokenLiteral(Token.SEMICOLON, ";"),
    TokenLiteral(Token.WHITESPACE, " "),
    TokenLiteral(Token.UNIT, "400"),
    TokenLiteral(Token.WHITESPACE, " "),
    TokenLiteral(Token.UNIT, "2"),
    TokenLiteral(Token.IDENT, "r"),
    TokenLiteral(Token.WHITESPACE, " "),
    TokenLiteral(Token.UNIT, "2"),
    TokenLiteral(Token.IDENT, "s"),
    TokenLiteral(Token.SEMICOLON, ";"),
    TokenLiteral(Token.EOF, ""),
  ];

  @override
  bool get eof => _index == _tokenLiterals.length - 1;

  @override
  TokenLiteral scan() => _tokenLiterals[_index++];
}

void main() {
  group("Constructor", () {
    test("An instance of Scanner is required for init", () {
      try { Parser(null); }
      catch(e) {
        expect(e, "Needs a scanner, dummy");
        return;
      }
      throw "Should have failed init";
    });
  });

  group("parse()", () {
    var parser = Parser(ScannerMock());
 
    group("After calling", () {
      setUp(() => parser.parse());

      test("Metadata is correctly captured", () {
        expect(parser.metadata.kvps, { "Key Key": "Value Value" });
      });

      test("Notes are correctly captured", () {
        expect(parser.metadata.notes, ["This is note."]);
      });

      test("Movements are correctly captured", () {
        var movement = parser.movements[0];
        expect(movement is Movement, true);
        expect(movement.name, "Movement Name");
        expect(movement.performances.length, 4);

        var ps = movement.performances;
        expect(ps[0].toString(), "100 for 1 sets of 1 reps.");
        expect(ps[1].toString(), "200 for 1 sets of 2 reps.");
        expect(ps[2].toString(), "300 for 2 sets of 1 reps.");
        expect(ps[3].toString(), "400 for 2 sets of 2 reps.");
      });
    });

    test("An instance of Scanner is required for parsing", () {
      parser.scanner = null;
      try { parser.parse(); }
      catch(e) {
        expect(e, "Needs a scanner, dummy");
        return;
      }
      throw "Should have failed init";
    });

  });
}
