import 'dart:io';

//import 'package:traindown/src/metadata.dart';
import 'package:traindown/src/movement.dart';
//import 'package:traindown/src/performance.dart';
import 'package:traindown/src/session.dart';
//import 'package:traindown/src/token.dart';

/// A search result that contains a DateTime and a Movement.
class MovementSearchResult {
  DateTime occurred;
  Movement movement;
  MovementSearchResult(this.occurred, this.movement);
}

/// Inspector provides tools for analyzing Sessions.
class Inspector {
  List<Session> sessions;
  List<String> _extensions = ['.traindown'];

  Inspector(this.sessions, [this._extensions]);

  /// Convenience constructor for slurping up files.
  factory Inspector.from_files(List<File> files,
      [extensions = const ['.traindown']]) {
    Inspector inspector = Inspector([], extensions);

    for (File file in files) {
      if (inspector.validFile(file)) {
        inspector.sessions.add(Session.from_file(file));
      }
    }

    return inspector;
  }

  /// Convenience constructor for slurping up a directory.
  factory Inspector.from_directory(Directory directory,
      [extensions = const ['.traindown']]) {
    List<File> files = [];

    for (FileSystemEntity file in directory.listSync()) {
      if (file is File) {
        files.add(file);
      }
    }

    return Inspector.from_files(files);
  }

  bool validFile(File file) {
    bool valid = false;

    for (String ext in _extensions) {
      if (file.path.endsWith(ext)) {
        valid = true;
        break;
      }
    }

    return valid;
  }

  /// List of unique Movement names in the Sessions.
  List<String> get movementNames => sessions
      .expand((s) => s.movements.map((m) => m.name.toLowerCase()))
      .toSet()
      .toList();

  /// Fetch all occurrances of a Movement as queried by a fuzzy name match.
  List<MovementSearchResult> movementOccurances(String movementName) {
    List<MovementSearchResult> result = [];

    for (Session session in sessions) {
      session.movements
          .where(
              (m) => m.name.toLowerCase().contains(movementName.toLowerCase()))
          .forEach(
              (m) => result.add(MovementSearchResult(session.occurred, m)));
    }

    return result;
  }
}
