import 'package:test/test.dart';

import 'package:traindown/src/performance.dart';
import 'package:traindown/src/session.dart';
import 'package:traindown/src/token.dart';

void main() {
  group('init', () {
    test('Basic init', () {
      List<Token> tokens = [
        Token(TokenType.DateTime, "2020-01-01"),
        Token(TokenType.Movement, "Squat"),
        Token(TokenType.Load, "500")
      ];

      Session session = Session(tokens);

      expect(session.movements.length, 1);
      expect(session.movements[0].name, "Squat");
      expect(session.movements[0].performances.length, 1);
      expect(session.movements[0].performances[0].load, 500);
      expect(session.movements[0].performances[0].sets, 1);
      expect(session.movements[0].performances[0].reps, 1);
    });

    const String unit = "your mom";

    Performance.unitKeywords.forEach((uk) {
      test("Session unit via $uk capture", () {
        List<Token> tokens = [
          Token(TokenType.DateTime, "2020-01-01"),
          Token(TokenType.MetaKey, uk),
          Token(TokenType.MetaValue, unit),
          Token(TokenType.Movement, "Squat"),
          Token(TokenType.Load, "500"),
          Token(TokenType.Movement, "Skwat"),
          Token(TokenType.Load, "500"),
        ];

        Session session = Session(tokens);

        expect(session.movements[0].performances[0].unit, unit);
        expect(session.movements[1].performances[0].unit, unit);
      });

      test("Movement unit via $uk capture", () {
        List<Token> tokens = [
          Token(TokenType.DateTime, "2020-01-01"),
          Token(TokenType.Movement, "Squat"),
          Token(TokenType.MetaKey, uk),
          Token(TokenType.MetaValue, unit),
          Token(TokenType.Load, "500"),
          Token(TokenType.Movement, "Skwat"),
          Token(TokenType.Load, "500"),
        ];

        Session session = Session(tokens);

        expect(session.movements[0].performances[0].unit, unit);
        expect(
            session.movements[1].performances[0].unit, Performance.unknownUnit);
      });

      test("Performance unit via $uk capture", () {
        List<Token> tokens = [
          Token(TokenType.DateTime, "2020-01-01"),
          Token(TokenType.Movement, "Squat"),
          Token(TokenType.Load, "500"),
          Token(TokenType.MetaKey, uk),
          Token(TokenType.MetaValue, unit),
          Token(TokenType.Movement, "Skwat"),
          Token(TokenType.Load, "500"),
        ];

        Session session = Session(tokens);

        expect(session.movements[0].performances[0].unit, unit);
        expect(
            session.movements[1].performances[0].unit, Performance.unknownUnit);
      });
    });
  });
}
