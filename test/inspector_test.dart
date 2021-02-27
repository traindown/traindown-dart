import 'dart:io';

import 'package:test/test.dart';

import 'package:traindown/src/inspector.dart';
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
      Inspector subject = Inspector([session]);
      expect(subject.sessions.length, 1);
    });

    test('File init', () {
      List<File> files = [File('./example/example.traindown')];
      Inspector subject = Inspector.from_files(files);
      expect(subject.sessions.length, 1);
    });

    test('Directory init', () {
      Directory dir = Directory('./example');
      Inspector subject = Inspector.from_directory(dir);
      expect(subject.sessions.length, 1);
    });
  });

  group('movementNames', () {
    test('Basic use', () {
      List<File> files = [File('./example/example.traindown')];
      Inspector subject = Inspector.from_files(files);
      List<String> movementNames = subject.movementNames;
      expect(movementNames.length, 5);
      expect(movementNames[0], equals('movement 1'));
      expect(movementNames[1], equals('2nd movement'));
      expect(movementNames[2], equals('third movement'));
      expect(movementNames[3], equals('4th movement'));
      expect(movementNames[4], equals('fifth movement'));
    });

    test('Deduper pooper with identical', () {
      List<Token> tokens = [
        Token(TokenType.DateTime, "2020-01-01"),
        Token(TokenType.Movement, "Squat"),
        Token(TokenType.Load, "500"),
        Token(TokenType.Movement, "Squat"),
        Token(TokenType.Load, "500")
      ];

      Session session = Session(tokens);
      Inspector subject = Inspector([session]);
      List<String> movementNames = subject.movementNames;

      expect(movementNames.length, 1);
      expect(movementNames[0], equals('squat'));
    });

    test('Deduper pooper with fuzzy', () {
      List<Token> tokens = [
        Token(TokenType.DateTime, "2020-01-01"),
        Token(TokenType.Movement, "Squat"),
        Token(TokenType.Load, "500"),
        Token(TokenType.Movement, "squat"),
        Token(TokenType.Load, "500"),
        Token(TokenType.Movement, "SQUAT"),
        Token(TokenType.Load, "500")
      ];

      Session session = Session(tokens);
      Inspector subject = Inspector([session]);
      List<String> movementNames = subject.movementNames;

      expect(movementNames.length, 1);
      expect(movementNames[0], equals('squat'));
    });
  });

  group('validFile', () {
    test('It returns true for allowed extensions', () {
      Inspector subject = Inspector([], ['.traindown']);
      expect(subject.validFile(File('./example/example.traindown')), true);
    });

    test('It returns false for unallowed extensions', () {
      Inspector subject = Inspector([], ['.braindown']);
      expect(subject.validFile(File('./example/example.traindown')), false);
    });
  });
}
