import 'dart:io';

import 'package:test/test.dart';

import 'package:traindown/src/metadata.dart';
import 'package:traindown/src/movement.dart';
import 'package:traindown/src/parser.dart';
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

    test('Stress test', () {
      File file = File("./example/example.traindown");
      String src = file.readAsStringSync();
      Parser fileParser = Parser(src);
      Session session = Session(fileParser.tokens());

      expect(session.movements.length, 5);
      expect(session.kvps.length, 4);
      expect(session.notes.length, 3);

      Movement movement1 = session.movements.first;

      expect(movement1.kvps.isEmpty, equals(true));
      expect(movement1.notes.isEmpty, equals(true));
      expect(movement1.performances.length, 3);

      expect(movement1.performances[0].load, 100.0);
      expect(movement1.performances[0].unit, equals(session.unit));
      expect(movement1.performances[0].reps, 1.0);
      expect(movement1.performances[0].sets, 1.0);
      expect(movement1.performances[1].load, 101.1);
      expect(movement1.performances[1].unit, equals(session.unit));
      expect(movement1.performances[1].reps, 1.0);
      expect(movement1.performances[1].sets, 1.0);
      expect(movement1.performances[2].load, 102.0);
      expect(movement1.performances[2].unit, equals(session.unit));
      expect(movement1.performances[2].reps, 1.0);
      expect(movement1.performances[2].sets, 1.0);

      Movement movement2 = session.movements[1];

      expect(movement2.kvps.length, 2);
      expect(movement2.notes.length, 2);
      expect(movement2.performances.length, 5);

      expect(movement2.performances[0].load, 201.0);
      expect(movement2.performances[0].unit, equals(session.unit));
      expect(movement2.performances[0].reps, 1.0);
      expect(movement2.performances[0].sets, 1.0);
      expect(movement2.performances[1].load, 202.0);
      expect(movement2.performances[1].unit, equals(session.unit));
      expect(movement2.performances[1].reps, 2.0);
      expect(movement2.performances[1].sets, 1.0);
      expect(movement2.performances[2].load, 203.0);
      expect(movement2.performances[2].unit, equals(session.unit));
      expect(movement2.performances[2].reps, 1.0);
      expect(movement2.performances[2].sets, 2.0);
      expect(movement2.performances[3].load, 204.0);
      expect(movement2.performances[3].unit, equals(session.unit));
      expect(movement2.performances[3].reps, 2.0);
      expect(movement2.performances[3].sets, 2.0);
      expect(movement2.performances[4].load, 205.0);
      expect(movement2.performances[4].unit, equals(session.unit));
      expect(movement2.performances[4].fails, 2.0);
      expect(movement2.performances[4].reps, 2.0);
      expect(movement2.performances[4].sets, 1.0);

      Movement movement3 = session.movements[2];

      expect(movement3.kvps.length, 0);
      expect(movement3.notes.length, 0);
      expect(movement3.performances.length, 2);

      expect(movement3.performances[0].notes.length, 2);
      expect(movement3.performances[0].load, 301.0);
      expect(movement3.performances[0].unit, equals(session.unit));
      expect(movement3.performances[0].reps, 1.0);
      expect(movement3.performances[0].sets, 1.0);
      expect(movement3.performances[1].kvps.length, 2);
      expect(movement3.performances[1].load, 302.0);
      expect(movement3.performances[1].unit, equals(session.unit));
      expect(movement3.performances[1].reps, 1.0);
      expect(movement3.performances[1].sets, 1.0);

      Movement movement4 = session.movements[3];

      // NOTE: Unit KVPs are stealthy
      expect(movement4.kvps.length, 0);
      expect(movement4.notes.length, 0);
      expect(movement4.unit, equals("4th unit movement"));
      expect(movement4.performances.length, 4);

      expect(movement4.performances[0].load, 400.456);
      expect(movement4.performances[0].unit, equals(movement4.unit));
      expect(movement4.performances[0].reps, 1.0);
      expect(movement4.performances[0].sets, 1.0);
      // NOTE: Unit KVPs are stealthy
      expect(movement4.performances[1].kvps.entries.length, 0);
      expect(movement4.performances[1].load, 401.0);
      expect(movement4.performances[1].unit, equals("401 unit"));
      expect(movement4.performances[1].reps, 1.0);
      expect(movement4.performances[1].sets, 1.0);
      expect(movement4.performances[2].load, double.parse(session.kvps['bw']));
      expect(movement4.performances[2].unit, equals(movement4.unit));
      expect(movement4.performances[2].reps, 1.0);
      expect(movement4.performances[2].sets, 1.0);
      expect(
          movement4.performances[3].load, double.parse(session.kvps['bw']) + 4);
      expect(movement4.performances[3].unit, equals(movement4.unit));
      expect(movement4.performances[3].reps, 1.0);
      expect(movement4.performances[3].sets, 1.0);

      Movement movement5 = session.movements[4];

      expect(movement5.kvps.length, 0);
      expect(movement5.notes.length, 0);
      expect(movement5.performances.length, 1);

      expect(movement5.performances[0].load, 500);
      expect(movement5.performances[0].unit, equals(session.unit));
      expect(movement5.performances[0].fails, 5.0);
      expect(movement5.performances[0].reps, 5.0);
      expect(movement5.performances[0].sets, 5.0);
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

    test('iOS pathological case with units round 2', () {
      List<Token> tokens = [
        Token(TokenType.DateTime, "2021-02-23"),
        Token(TokenType.MetaKey, "unit"),
        Token(TokenType.MetaValue, "lbs"),
        Token(TokenType.MetaKey, "bw"),
        Token(TokenType.MetaValue, "230"),
        Token(TokenType.MetaKey, "day"),
        Token(TokenType.MetaValue, "de lower"),
        Token(TokenType.Movement, "squat"),
        Token(TokenType.MetaKey, "box height"),
        Token(TokenType.MetaValue, "15\""),
        Token(TokenType.MetaKey, "chains"),
        Token(TokenType.MetaValue, "120lbs"),
        Token(TokenType.MetaKey, "stances"),
        Token(TokenType.MetaValue, "wide, med, narrow"),
        Token(TokenType.MetaKey, "rest"),
        Token(TokenType.MetaValue, "45 seconds"),
        Token(TokenType.Load, "135"),
        Token(TokenType.Rep, "5"),
        Token(TokenType.Load, "205"),
        Token(TokenType.Rep, "5"),
        Token(TokenType.Load, "275"),
        Token(TokenType.Rep, "2"),
        Token(TokenType.Load, "305"),
        Token(TokenType.Rep, "2"),
        Token(TokenType.Set, "9"),
      ];

      Session session = Session(tokens);

      expect(session.unit, equals("lbs"));
      expect(session.movements.length, 1);
      expect(session.movements[0].name, "squat");
      expect(session.movements[0].unit, session.unit);
      expect(session.movements[0].performances.length, 4);
      expect(session.movements[0].performances[0].load, 135);
      expect(session.movements[0].performances[0].unit, session.unit);
      expect(session.movements[0].performances[0].sets, 1);
      expect(session.movements[0].performances[0].reps, 5);
      expect(session.movements[0].performances[1].load, 205);
      expect(session.movements[0].performances[1].unit, session.unit);
      expect(session.movements[0].performances[1].sets, 1);
      expect(session.movements[0].performances[1].reps, 5);
      expect(session.movements[0].performances[2].load, 275);
      expect(session.movements[0].performances[2].unit, session.unit);
      expect(session.movements[0].performances[2].sets, 1);
      expect(session.movements[0].performances[2].reps, 2);
      expect(session.movements[0].performances[3].load, 305);
      expect(session.movements[0].performances[3].unit, session.unit);
      expect(session.movements[0].performances[3].sets, 9);
      expect(session.movements[0].performances[3].reps, 2);
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
        expect(session.movements[1].performances[0].unit, Metadata.unknownUnit);
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
        expect(session.movements[1].performances[0].unit, Metadata.unknownUnit);
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

      test("Session unit Movement and Performance override via $uk capture",
          () {
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
