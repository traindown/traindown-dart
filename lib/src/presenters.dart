import "dart:convert";

import "package:traindown/src/movement.dart";
import "package:traindown/src/parser.dart";

abstract class ParserPresenter {
  Parser _parser;
  
  Map get kvps => _parser.metadata.kvps;
  List<Movement> get movements => _parser.movements;
  List<String> get notes => _parser.metadata.notes;

  String call() {
    var string = StringBuffer();

    _writeMetadata(string);
    _writeNotes(string);
    _writeMovements(string);

    return string.toString();
  }

  void _writeMetadata(StringBuffer s);
  void _writeMovements(StringBuffer s);
  void _writeNotes(StringBuffer s);
}

class ConsolePresenter extends ParserPresenter {
  Parser _parser;
  ConsolePresenter(this._parser);

  @override
  void _writeMetadata(StringBuffer s) {
    s.write("** Metadata **\n");

    if (kvps.entries.isEmpty) {
      s.write("No metadata for this session.");
      return;
    }

    for (var mapEntry in kvps.entries) {
      s.write("${mapEntry.key}: ${mapEntry.value}\n");
    }
  }

  @override
  void _writeMovements(StringBuffer s) {
    s.write("\n\n** Movements **\n");

    for (var movement in movements) {
      s.write("$movement\n");
    }
  }

  @override
  void _writeNotes(StringBuffer s) {
    s.write("\n** Notes **\n");

    if (notes.isEmpty) {
      s.write(" - No notes for this session");
      return;
    }

    for (var note in notes) {
      s.write(" - $note\n");
    }
  }
}

class JSONPresenter extends ParserPresenter {
  Parser _parser;
  JSONPresenter(this._parser);

  @override
  String call() {
    return jsonEncode({
      "metadata": _parser.metadata.kvps,
      "movements": _movementsHash(),
      "notes": _parser.metadata.notes
    });
  }

  List _movementsHash() {
    return _parser.movements.fold(List(), (acc, movement) {
      acc.add({
        "name": movement.name,
        "performances": movement.performances.fold(List(), (pacc, performance) {
          pacc.add({
            "load": performance.load,
            "reps": performance.reps,
            "sets": performance.repeat,
            "unit": performance.unit
          });
          return pacc;
        })
      });
      return acc;
    });
  }

  // TODO: Probably get rid of the abstract class...
  void _writeMetadata(StringBuffer s) {}
  void _writeMovements(StringBuffer s) {}
  void _writeNotes(StringBuffer s) {}
}
