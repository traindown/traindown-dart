import 'package:test/test.dart';

import 'package:traindown/src/metadata.dart';
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

    test('iOS pathological case with units', () {
      List<Token> tokens = [
        Token(TokenType.DateTime, "2020-01-01"),
        Token(TokenType.MetaKey, "unit"),
        Token(TokenType.MetaValue, "lbs"),
        Token(TokenType.Movement, "Squat"),
        Token(TokenType.Load, "500"),
        Token(TokenType.Movement, "Not squat"),
        Token(TokenType.MetaKey, "unit"),
        Token(TokenType.MetaValue, "not lbs"),
        Token(TokenType.Load, "100"),
      ];

      Session session = Session(tokens);

      expect(session.unit, equals("lbs"));
      expect(session.movements.length, 2);
      expect(session.movements[0].name, "Squat");
      expect(session.movements[0].performances.length, 1);
      expect(session.movements[0].performances[0].load, 500);
      expect(session.movements[0].performances[0].sets, 1);
      expect(session.movements[0].performances[0].reps, 1);
      expect(session.movements[1].name, "Not squat");
      expect(session.movements[1].performances.length, 1);
      expect(session.movements[1].performances[0].load, 100);
      expect(session.movements[1].performances[0].sets, 1);
      expect(session.movements[1].performances[0].reps, 1);
      expect(session.movements[1].performances[0].unit, "not lbs");
    });

    const String unit = "your mom";

    Metadata.unitKeywords.forEach((uk) {
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

        expect(session.movements[0].unit, unit);
        expect(session.movements[0].performances[0].unit, unit);
        expect(session.movements[1].unit, unit);
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
            session.movements[1].performances[0].unit, Metadata.unknownUnit);
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
            session.movements[1].performances[0].unit, Metadata.unknownUnit);
      });

      String otherUnit = "not your mom";

      test("Session unit Movement override via $uk capture", () {
        List<Token> tokens = [
          Token(TokenType.DateTime, "2020-01-01"),
          Token(TokenType.MetaKey, uk),
          Token(TokenType.MetaValue, otherUnit),
          Token(TokenType.Movement, "Squat"),
          Token(TokenType.MetaKey, uk),
          Token(TokenType.MetaValue, unit),
          Token(TokenType.Load, "500"),
          Token(TokenType.Movement, "Skwat"),
          Token(TokenType.Load, "500"),
        ];

        Session session = Session(tokens);

        expect(session.movements[0].performances[0].unit, unit);
        expect(session.movements[1].performances[0].unit, otherUnit);
      });

      test("Session unit Performance override via $uk capture", () {
        List<Token> tokens = [
          Token(TokenType.DateTime, "2020-01-01"),
          Token(TokenType.MetaKey, uk),
          Token(TokenType.MetaValue, otherUnit),
          Token(TokenType.Movement, "Squat"),
          Token(TokenType.Load, "500"),
          Token(TokenType.MetaKey, uk),
          Token(TokenType.MetaValue, unit),
          Token(TokenType.Movement, "Skwat"),
          Token(TokenType.Load, "500"),
        ];

        Session session = Session(tokens);

        expect(session.movements[0].performances[0].unit, unit);
        expect(session.movements[1].performances[0].unit, otherUnit);
      });

      String thirdUnit = "whatever";

      test("Session unit Movement and Performance override via $uk capture", () {
        List<Token> tokens = [
          Token(TokenType.DateTime, "2020-01-01"),
          Token(TokenType.MetaKey, uk),
          Token(TokenType.MetaValue, thirdUnit),
          Token(TokenType.Movement, "Squat"),
          Token(TokenType.MetaKey, uk),
          Token(TokenType.MetaValue, otherUnit),
          Token(TokenType.Load, "500"),
          Token(TokenType.MetaKey, uk),
          Token(TokenType.MetaValue, unit),
          Token(TokenType.Movement, "Skwat"),
          Token(TokenType.Load, "500"),
        ];

        Session session = Session(tokens);

        expect(session.movements[0].performances[0].unit, unit);
        expect(session.movements[1].performances[0].unit, thirdUnit);
      });

    });
  });
}
