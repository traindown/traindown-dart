import 'package:mockito/mockito.dart';
import 'package:test/test.dart';

import 'package:traindown/src/movement.dart';
import 'package:traindown/src/parser.dart';
import 'package:traindown/src/performance.dart';
import 'package:traindown/src/scanner.dart';
import 'package:traindown/src/token.dart';

class ScannerMock extends Fake implements Scanner {
  int _index = 0;

  /*
    @ 2020-01-01

    # Session Key: Session Value # unit: Session Unit
    * This is a session note.

    Movement Name: 
      # Movement Key: Movement Value
      * This is a movement note.

      100 200 2r 300 2s
      400 2r 2s
        # Peformance Key: Performance Value
        * This is a performance note
      500

    + Another:
      # unit: Movement Unit
      bw
      100
      200
        # unit: Performance Unit
  */

  final List<TokenLiteral> _tokenLiterals = [
    TokenLiteral(Token.AT, '@'),
    TokenLiteral(Token.WHITESPACE, ' '),
    TokenLiteral(Token.AMOUNT, '2020'),
    TokenLiteral(Token.DASH, '-'),
    TokenLiteral(Token.AMOUNT, '01'),
    TokenLiteral(Token.DASH, '-'),
    TokenLiteral(Token.AMOUNT, '01'),
    TokenLiteral(Token.LINEBREAK, ''),
    TokenLiteral(Token.LINEBREAK, ''),
    TokenLiteral(Token.POUND, '#'),
    TokenLiteral(Token.WHITESPACE, ' '),
    TokenLiteral(Token.WORD, 'Session'),
    TokenLiteral(Token.WHITESPACE, ' '),
    TokenLiteral(Token.WORD, 'Key'),
    TokenLiteral(Token.COLON, ':'),
    TokenLiteral(Token.WHITESPACE, ' '),
    TokenLiteral(Token.WORD, 'Session'),
    TokenLiteral(Token.WHITESPACE, ' '),
    TokenLiteral(Token.WORD, 'Value'),
    TokenLiteral(Token.WHITESPACE, ' '),
    TokenLiteral(Token.POUND, '#'),
    TokenLiteral(Token.WHITESPACE, ' '),
    TokenLiteral(Token.WORD, 'unit'),
    TokenLiteral(Token.COLON, ':'),
    TokenLiteral(Token.WHITESPACE, ' '),
    TokenLiteral(Token.WORD, 'Session'),
    TokenLiteral(Token.WHITESPACE, ' '),
    TokenLiteral(Token.WORD, 'Unit'),
    TokenLiteral(Token.LINEBREAK, ''),
    TokenLiteral(Token.STAR, '*'),
    TokenLiteral(Token.WHITESPACE, ' '),
    TokenLiteral(Token.WORD, 'This'),
    TokenLiteral(Token.WHITESPACE, ' '),
    TokenLiteral(Token.WORD, 'is'),
    TokenLiteral(Token.WHITESPACE, ' '),
    TokenLiteral(Token.WORD, 'a'),
    TokenLiteral(Token.WHITESPACE, ' '),
    TokenLiteral(Token.WORD, 'session'),
    TokenLiteral(Token.WHITESPACE, ' '),
    TokenLiteral(Token.WORD, 'note.'),
    TokenLiteral(Token.LINEBREAK, ''),
    TokenLiteral(Token.LINEBREAK, ''),
    TokenLiteral(Token.WORD, 'Movement'),
    TokenLiteral(Token.WHITESPACE, ' '),
    TokenLiteral(Token.WORD, 'Name'),
    TokenLiteral(Token.COLON, ':'),
    TokenLiteral(Token.LINEBREAK, ''),
    TokenLiteral(Token.POUND, '#'),
    TokenLiteral(Token.WHITESPACE, ' '),
    TokenLiteral(Token.WORD, 'Movement'),
    TokenLiteral(Token.WHITESPACE, ' '),
    TokenLiteral(Token.WORD, 'Key'),
    TokenLiteral(Token.COLON, ':'),
    TokenLiteral(Token.WHITESPACE, ' '),
    TokenLiteral(Token.WORD, 'Movement'),
    TokenLiteral(Token.WHITESPACE, ' '),
    TokenLiteral(Token.WORD, 'Value'),
    TokenLiteral(Token.LINEBREAK, ''),
    TokenLiteral(Token.STAR, '*'),
    TokenLiteral(Token.WHITESPACE, ' '),
    TokenLiteral(Token.WORD, 'This'),
    TokenLiteral(Token.WHITESPACE, ' '),
    TokenLiteral(Token.WORD, 'is'),
    TokenLiteral(Token.WHITESPACE, ' '),
    TokenLiteral(Token.WORD, 'a'),
    TokenLiteral(Token.WHITESPACE, ' '),
    TokenLiteral(Token.WORD, 'movement'),
    TokenLiteral(Token.WHITESPACE, ' '),
    TokenLiteral(Token.WORD, 'note.'),
    TokenLiteral(Token.LINEBREAK, ''),
    TokenLiteral(Token.WHITESPACE, '  '),
    TokenLiteral(Token.AMOUNT, '100'),
    TokenLiteral(Token.WHITESPACE, ' '),
    TokenLiteral(Token.AMOUNT, '200'),
    TokenLiteral(Token.WHITESPACE, ' '),
    TokenLiteral(Token.REPS, '2'),
    TokenLiteral(Token.WHITESPACE, ' '),
    TokenLiteral(Token.AMOUNT, '300'),
    TokenLiteral(Token.WHITESPACE, ' '),
    TokenLiteral(Token.SETS, '2'),
    TokenLiteral(Token.LINEBREAK, ''),
    TokenLiteral(Token.WHITESPACE, '  '),
    TokenLiteral(Token.AMOUNT, '400'),
    TokenLiteral(Token.WHITESPACE, ' '),
    TokenLiteral(Token.REPS, '2'),
    TokenLiteral(Token.WHITESPACE, ' '),
    TokenLiteral(Token.SETS, '2'),
    TokenLiteral(Token.LINEBREAK, ''),
    TokenLiteral(Token.POUND, '#'),
    TokenLiteral(Token.WHITESPACE, ' '),
    TokenLiteral(Token.WORD, 'Performance'),
    TokenLiteral(Token.WHITESPACE, ' '),
    TokenLiteral(Token.WORD, 'Key'),
    TokenLiteral(Token.COLON, ':'),
    TokenLiteral(Token.WHITESPACE, ' '),
    TokenLiteral(Token.WORD, 'Performance'),
    TokenLiteral(Token.WHITESPACE, ' '),
    TokenLiteral(Token.WORD, 'Value'),
    TokenLiteral(Token.LINEBREAK, ''),
    TokenLiteral(Token.STAR, '*'),
    TokenLiteral(Token.WHITESPACE, ' '),
    TokenLiteral(Token.WORD, 'This'),
    TokenLiteral(Token.WHITESPACE, ' '),
    TokenLiteral(Token.WORD, 'is'),
    TokenLiteral(Token.WHITESPACE, ' '),
    TokenLiteral(Token.WORD, 'a'),
    TokenLiteral(Token.WHITESPACE, ' '),
    TokenLiteral(Token.WORD, 'performance'),
    TokenLiteral(Token.WHITESPACE, ' '),
    TokenLiteral(Token.WORD, 'note.'),
    TokenLiteral(Token.LINEBREAK, ''),
    TokenLiteral(Token.AMOUNT, '500'),
    TokenLiteral(Token.LINEBREAK, ''),
    TokenLiteral(Token.PLUS, '+'),
    TokenLiteral(Token.WHITESPACE, ' '),
    TokenLiteral(Token.WORD, 'Another'),
    TokenLiteral(Token.COLON, ':'),
    TokenLiteral(Token.LINEBREAK, ''),
    TokenLiteral(Token.WHITESPACE, ' '),
    TokenLiteral(Token.POUND, '#'),
    TokenLiteral(Token.WHITESPACE, ' '),
    TokenLiteral(Token.WORD, 'unit'),
    TokenLiteral(Token.COLON, ':'),
    TokenLiteral(Token.WHITESPACE, ' '),
    TokenLiteral(Token.WORD, 'Movement'),
    TokenLiteral(Token.WHITESPACE, ' '),
    TokenLiteral(Token.WORD, 'Unit'),
    TokenLiteral(Token.LINEBREAK, ''),
    TokenLiteral(Token.WHITESPACE, ' '),
    TokenLiteral(Token.WORD, 'bw'),
    TokenLiteral(Token.LINEBREAK, ''),
    TokenLiteral(Token.WHITESPACE, ' '),
    TokenLiteral(Token.AMOUNT, '100'),
    TokenLiteral(Token.LINEBREAK, ''),
    TokenLiteral(Token.WHITESPACE, ' '),
    TokenLiteral(Token.AMOUNT, '200'),
    TokenLiteral(Token.LINEBREAK, ''),
    TokenLiteral(Token.WHITESPACE, ' '),
    TokenLiteral(Token.POUND, '#'),
    TokenLiteral(Token.WHITESPACE, ' '),
    TokenLiteral(Token.WORD, 'unit'),
    TokenLiteral(Token.COLON, ':'),
    TokenLiteral(Token.WHITESPACE, ' '),
    TokenLiteral(Token.WORD, 'Performance'),
    TokenLiteral(Token.WHITESPACE, ' '),
    TokenLiteral(Token.WORD, 'Unit'),
    TokenLiteral(Token.EOF, ''),
  ];

  @override
  bool get eof => _index == _tokenLiterals.length - 1;

  @override
  TokenLiteral scan() => _tokenLiterals[_index++];

  @override
  TokenLiteral unscan() => _tokenLiterals[_index--];
}

void main() {
  group('Constructor', () {
    test('An instance of Scanner is required for init', () {
      try {
        Parser(null);
      } catch (e) {
        expect(e, 'Needs a scanner, dummy');
        return;
      }
      throw 'Should have failed init';
    });
  });

  group('parse()', () {
    Parser parser = Parser(ScannerMock());

    group('After calling', () {
      parser.parse();

      test('Session Metadata is correctly captured', () {
        expect(parser.metadata.kvps,
            {'Session Key': 'Session Value', 'unit': 'Session Unit'});
      });

      test('Session Notes are correctly captured', () {
        expect(parser.metadata.notes, ['This is a session note.']);
      });

      test('Movements are correctly captured', () {
        Movement movement = parser.movements.first;
        expect(movement is Movement, true);
        expect(movement.name, 'Movement Name');
        expect(movement.performances.length, 5);

        Movement another = parser.movements.last;
        expect(another is Movement, true);
        expect(another.name, 'Another');
        expect(another.performances.length, 3);
      });

      test('Movement Metadata is correctly captured', () {
        Movement movement = parser.movements.first;
        expect(movement.metadata.kvps, {'Movement Key': 'Movement Value'});
      });

      test('Movement Notes are correctly captured', () {
        Movement movement = parser.movements.first;
        expect(movement.metadata.notes, ['This is a movement note.']);
      });

      test('Performances are correctly captured', () {
        Movement movement = parser.movements.first;
        List<Performance> performances = movement.performances;
        expect(performances[0].toString(),
            Performance(load: 100, unit: 'Session Unit').toString());
        expect(performances[1].toString(),
            Performance(load: 200, reps: 2, unit: 'Session Unit').toString());
        expect(performances[2].toString(),
            Performance(load: 300, repeat: 2, unit: 'Session Unit').toString());
        Performance penultimatePerformance =
            Performance(load: 400, repeat: 2, reps: 2, unit: 'Session Unit');
        penultimatePerformance.addKVP('Performance Key', 'Performance Value');
        penultimatePerformance.addNote('This is a performance note.');
        expect(performances[3].toString(), penultimatePerformance.toString());
        expect(performances[4].toString(),
            Performance(load: 500, unit: 'Session Unit').toString());

        Movement another = parser.movements.last;
        List<Performance> another_performances = another.performances;
        expect(another_performances[0].toString(),
            Performance(load: 1, unit: 'bodyweight').toString());
        expect(another_performances[1].toString(),
            Performance(load: 100, unit: 'Movement Unit').toString());
        expect(another_performances[2].toString(),
            Performance(load: 200, unit: 'Performance Unit').toString());
      });

      test('Performance Metadata is correctly captured', () {
        Movement movement = parser.movements.first;
        Performance performance = movement.performances[3];
        expect(performance.metadata.kvps,
            {'Performance Key': 'Performance Value'});
      });

      test('Performance Notes are correctly captured', () {
        Movement movement = parser.movements.first;
        Performance performance = movement.performances[3];
        expect(performance.metadata.notes, ['This is a performance note.']);
      });
    });
  });
}
