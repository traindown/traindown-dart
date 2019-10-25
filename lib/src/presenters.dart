import "dart:convert";

import "package:traindown/src/movement.dart";
import "package:traindown/src/parser.dart";

abstract class ParserPresenter {
  Parser _parser;
  
  Map get kvps => _parser.metadata.kvps;
  List<Movement> get movements => _parser.movements;
  List<String> get notes => _parser.metadata.notes;

  String call() {
    var string = initString();

    _writeMetadata(string);
    _writeNotes(string);
    _writeMovements(string);

    return string.toString();
  }

  StringBuffer initString() {
    return StringBuffer();
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

class HTMLPresenter extends ParserPresenter {
  Parser _parser;
  HTMLPresenter(this._parser);

  @override
  StringBuffer initString() {
    var string = StringBuffer();
    var date = kvps["Date"] ?? kvps["date"] ?? kvps["Day"] ?? kvps["day"] ?? "Unknown Date";
    var time = kvps["Time"] ?? kvps["time"] ?? "Unknown time";

    string.write("<h1>Training Session on $date at $time</h1>");

    return string;
  }

  void _writeMetadata(StringBuffer s) {
    s.write("<h2>Metadata</h2>");

    if (kvps.entries.isEmpty) {
      s.write("<strong>No metadata for this session.</strong>");
      return;
    }

    s.write("<dl>");

    for (var mapEntry in kvps.entries) {
      s.write("<dt>${mapEntry.key}</dt><dd>${mapEntry.value}</dd>");
    }

    s.write("</dl>");
  }

  void _writeMovements(StringBuffer s) {
    s.write("<h2>Movements</h2>");
    s.write("<table><thead><tr><th>Movement</th><th>Load</th><th>Unit</th><th>Sets</th><th>Reps</th></tr></thead><tbody>");

    for (var movement in movements) {
      s.write("<tr><td colspan=\"5\">${movement.name}</td></tr>");
      for (var p in movement.performances) {
        s.write("<tr><td></td><td>${p.load}</td><td>${p.unit}</td><td>${p.repeat}</td><td>${p.reps}</td></tr>");
      }
    }

    s.write("</table>");
  }

  void _writeNotes(StringBuffer s) {
    s.write("<h2>Notes</h2>");

    if (notes.isEmpty) {
      s.write("<strong>No notes for this session.</strong>");
      return;
    }

    s.write("<ul>");

    for (var note in notes) {
      s.write("<li>$note</li>");
    }

    s.write("</ul>");
  }
}

class JSONPresenter extends ParserPresenter {
  Parser _parser;
  JSONPresenter(this._parser);

  @override
  String call() {
    return jsonEncode({
      "metadata": kvps,
      "movements": _movementsHash(),
      "notes": notes
    });
  }

  List _movementsHash() {
    return movements.fold(List(), (acc, movement) {
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
