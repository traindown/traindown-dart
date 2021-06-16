import 'dart:io';

import 'package:test/test.dart';

import 'package:traindown/src/inspector.dart';
import 'package:traindown/src/session.dart';
import 'package:traindown/src/session_io.dart';
import 'package:traindown/src/token.dart';

void main() {
  group('export', () {
    test('It concats all the strings like a boss', () {
      List<Token> tokens1 = [
        Token(TokenType.DateTime, "2020-01-01"),
        Token(TokenType.MetaKey, "Your"),
        Token(TokenType.MetaValue, "Mom"),
        Token(TokenType.MetaKey, "Foo"),
        Token(TokenType.MetaValue, "Bar"),
      ];
      Session session1 = Session(tokens1);

      List<Token> tokens2 = [
        Token(TokenType.DateTime, "2021-01-01"),
        Token(TokenType.MetaKey, "Your"),
        Token(TokenType.MetaValue, "Mom"),
        Token(TokenType.MetaKey, "Bar"),
        Token(TokenType.MetaValue, "Baz"),
      ];
      Session session2 = Session(tokens2);

      String expected = """
@ 2021-01-01

# Your: Mom
# Bar: Baz

@ 2020-01-01

# Your: Mom
# Foo: Bar""";

      expect(
          SessionIO.export([session2, session1], linebreaker: '\n'), expected);
    });
  });

  group('Inspector methods', () {
    test('Inspector from files', () {
      List<File> files = [File('./example/example.traindown')];
      Inspector subject = SessionIO.inspectorFromFiles(files);
      expect(subject.sessions.length, 1);
    });

    test('Inspector from directory', () {
      Directory dir = Directory('./example');
      Inspector subject = SessionIO.inspectorFromDirectory(dir);
      expect(subject.sessions.length, 1);
    });
  });

  group('Session methods', () {
    test('Session from file', () {
      File file = File('./example/example.traindown');
      Session subject = SessionIO.sessionFromFile(file);
      expect(subject.movements.length, 5);
    });

    test('Session from path', () {
      String path = './example/example.traindown';
      Session subject = SessionIO.sessionFromPath(path);
      expect(subject.movements.length, 5);
    });
  });

  group('validFile', () {
    test('It returns true for allowed extensions', () {
      expect(
          SessionIO.validFile(
              File('./example/example.traindown'), ['.traindown']),
          true);
    });

    test('It returns false for unallowed extensions', () {
      expect(
          SessionIO.validFile(
              File('./example/example.traindown'), ['.braindown']),
          false);
    });
  });
}
