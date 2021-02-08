import 'package:test/test.dart';

import 'package:traindown/src/session.dart';
import 'package:traindown/src/token.dart';

void main() {
  List<Token> tokens = [
    Token(TokenType.DateTime, "2020-01-01"),
    Token(TokenType.Movement, "Squat"),
    Token(TokenType.Load, "500")
  ];

  group('init', () {
    test('Basic init', () {
      Session session = Session(tokens);
      expect(session.movements.length, 1);
      expect(session.movements[0].name, "Squat");
      expect(session.movements[0].performances.length, 1);
      expect(session.movements[0].performances[0].load, 500);
      expect(session.movements[0].performances[0].sets, 1);
      expect(session.movements[0].performances[0].reps, 1);
    });
  });
}
