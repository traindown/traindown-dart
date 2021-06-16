import 'dart:io';

import 'package:traindown/src/formatter.dart';
import 'package:traindown/src/inspector.dart';
import 'package:traindown/src/metadata.dart';
import 'package:traindown/src/parser.dart';
import 'package:traindown/src/session.dart';

/// SessionIO provides simple utilities for working with Sessions from the file
/// system. Currently all methods are synchronous.
class SessionIO {
  /// Export all Sessions as a single Traindown string. Good for dumping
  /// and sharing.
  ///
  /// [sessions] is the list of Sessions that will be bundled for export.
  /// For details on the optional parameters, see Formatter.
  static String export(List<Session> sessions,
      {String indenter = '  ',
      String linebreaker = '\r\n',
      String spacer = ' '}) {
    Formatter formatter =
        Formatter(indenter: indenter, linebreaker: linebreaker, spacer: spacer);
    StringBuffer buffer = StringBuffer();
    sessions.forEach((s) => buffer
        .write('${formatter.format(s.tokens)}${formatter.linebreaker * 2}'));
    return buffer.toString().trim();
  }

  /// Create an Inspector from a directory.
  ///
  /// [directory] The target directory.
  /// [extensions] is a filter for the files using their extensions.
  static Inspector inspectorFromDirectory(Directory directory,
      [extensions = const ['.traindown']]) {
    List<File> files = [];

    for (FileSystemEntity file in directory.listSync()) {
      if (file is File) {
        files.add(file);
      }
    }

    return inspectorFromFiles(files);
  }

  /// Create an Inspector from a list of files.
  ///
  /// [files] List of files to consider.
  /// [extensions] is a filter for the files using their extensions.
  static Inspector inspectorFromFiles(List<File> files,
      [extensions = const ['.traindown']]) {
    Inspector inspector = Inspector([]);

    for (File file in files) {
      if (SessionIO.validFile(file, extensions)) {
        inspector.sessions.add(SessionIO.sessionFromFile(file));
      }
    }

    inspector.sessions.sort((a, b) => b.occurred.compareTo(a.occurred));

    return inspector;
  }

  /// Create a Session from a file.
  ///
  /// [file] Traindown file to hydrate the Session.
  /// [defaultBW] a fallback for if the file does not contain a bodyweight.
  /// [unit] will default to unknown if not set in the file.
  static Session sessionFromFile(File file,
      {double defaultBW = 100, String unit = Metadata.unknownUnit}) {
    String src = file.readAsStringSync();
    Parser fileParser = Parser(src);
    return Session(fileParser.tokens(), defaultBW: defaultBW, unit: unit);
  }

  /// Create a Session from a path.
  ///
  /// [path] Location of the Traindown file to hydrate the Session.
  /// [defaultBW] a fallback for if the file does not contain a bodyweight.
  /// [unit] will default to unknown if not set in the file.

  static Session sessionFromPath(String path,
      {double defaultBW = 100, String unit = Metadata.unknownUnit}) {
    File file = File(path);
    return SessionIO.sessionFromFile(file, defaultBW: defaultBW, unit: unit);
  }

  /// Test for if the [file] in question matches the list of [extensions].
  static bool validFile(File file, List<String> extensions) {
    bool valid = false;

    for (String ext in extensions) {
      if (file.path.endsWith(ext)) {
        valid = true;
        break;
      }
    }

    return valid;
  }
}
