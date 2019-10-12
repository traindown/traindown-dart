import "./movement.dart";
import "./parser.dart";

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

  void _writeMetadata(StringBuffer s) => throw "Must implement _writeMetadata.";
  void _writeMovements(StringBuffer s) => throw "Must implement _writeMovements.";
  void _writeNotes(StringBuffer s) => throw "Must implement _writeNotes";
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
    s.write("\n\n** Notes **\n");

    if (notes.isEmpty) {
      s.write(" - No notes for this session");
      return;
    }

    for (var note in notes) {
      s.write(" - $note\n");
    }
  }
}
