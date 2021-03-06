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

  group('metadataByKey', () {
    List<File> files = [File('./example/example.traindown')];
    Inspector subject = Inspector.from_files(files);

    Map<String, Set<String>> expected = {
      "bw": {"230"},
      "session meta key 1": {"session meta \"value\" 1"},
      "session meta key '2'": {"session meta value 2"},
      "3rd session meta key": {"3rd session meta value"},
    };

    test('Session scope', () {
      Map<String, Set<String>> meta = subject.metadataByKey();
      expect(meta.length, 4);
      expect(meta, equals(expected));
    });

    test('Movement scope', () {
      expected["2nd movement meta key 1"] = {"2nd movement meta value 1"};
      expected["Movement 2 meta key 2"] = {"Movement 2 meta key 2"};
      Map<String, Set<String>> meta =
          subject.metadataByKey(TraindownScope.movement);
      expect(meta.length, 6);
      expect(meta, equals(expected));
    });

    test('Performance scope', () {
      expected["2nd movement meta key 1"] = {"2nd movement meta value 1"};
      expected["Movement 2 meta key 2"] = {"Movement 2 meta key 2"};
      expected["302 meta key 1"] = {"302 meta value 1"};
      expected["Meta key 2 for 302"] = {"Meta value 2 for 302"};
      Map<String, Set<String>> meta =
          subject.metadataByKey(TraindownScope.performance);
      expect(meta.length, 8);
      expect(meta, equals(expected));
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

  group('sessionQuery', () {
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

    Inspector subject = Inspector([session1, session2]);

    test('One kvp that does not match key or value', () {
      expect(subject.sessionQuery(metaLike: {"test": "test"}), equals([]));
    });

    test('One kvp that does match key but not value', () {
      expect(subject.sessionQuery(metaLike: {"Your": "test"}), equals([]));
    });

    test('One kvp that does match key and value on single', () {
      List<Session> results = subject.sessionQuery(metaLike: {"Foo": "Bar"});
      expect(results.length, 1);
      expect(results.contains(session1), true);
    });

    test('One kvp that does match key and value on multiple', () {
      List<Session> results = subject.sessionQuery(metaLike: {"Your": "Mom"});
      expect(results.length, 2);
      expect(results.contains(session1), true);
      expect(results.contains(session2), true);
    });

    test('One kvp that does match key and value on single case insensitive key',
        () {
      List<Session> results = subject.sessionQuery(metaLike: {"FOO": "Bar"});
      expect(results.length, 1);
      expect(results.contains(session1), true);
    });

    test(
        'One kvp that does match key and value on multiple case insensitive key',
        () {
      List<Session> results = subject.sessionQuery(metaLike: {"YOUR": "Mom"});
      expect(results.length, 2);
      expect(results.contains(session1), true);
      expect(results.contains(session2), true);
    });

    test(
        'One kvp that does match key and value on single case insensitive value',
        () {
      List<Session> results = subject.sessionQuery(metaLike: {"Foo": "BAR"});
      expect(results.length, 1);
      expect(results.contains(session1), true);
    });

    test(
        'One kvp that does match key and value on multiple case insensitive value',
        () {
      List<Session> results = subject.sessionQuery(metaLike: {"Your": "MOM"});
      expect(results.length, 2);
      expect(results.contains(session1), true);
      expect(results.contains(session2), true);
    });

    test(
        'One kvp that does match key and value on single case insensitive key and value',
        () {
      List<Session> results = subject.sessionQuery(metaLike: {"FOO": "BAR"});
      expect(results.length, 1);
      expect(results.contains(session1), true);
    });

    test(
        'One kvp that does match key and value on multiple case insensitive key and value',
        () {
      List<Session> results = subject.sessionQuery(metaLike: {"YOUR": "MOM"});
      expect(results.length, 2);
      expect(results.contains(session1), true);
      expect(results.contains(session2), true);
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
