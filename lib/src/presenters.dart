import "./movement.dart";
import "./parser.dart";

abstract class ParserPresenter {
  Parser _parser;
  ParserPresenter(this._parser);
  String call();
}

class ConsolePresenter implements ParserPresenter {
  Parser _parser;
  ConsolePresenter(this._parser);

  Map get kvps => _parser.metadata.kvps;
  List<Movement> get movements => _parser.movements;
  List<String> get notes => _parser.metadata.notes;

  String call() {
    var string = StringBuffer("** Metadata **\n");
    for (var mapEntry in kvps.entries) {
      string.write("${mapEntry.key}: ${mapEntry.value}\n");
    }
    string.write("\n\n** Notes **\n");
    for (var note in notes) {
      string.write(" - $note\n");
    }
    string.write("\n\n** Movements **\n");
    for (var movement in movements) {
      string.write("$movement\n");
    }

    return string.toString();
  }
}
