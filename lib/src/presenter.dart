import "package:traindown/src/movement.dart";
import "package:traindown/src/parser.dart";

abstract class Presenter {
  Parser parser;
  StringBuffer result = StringBuffer();

  Presenter(this.parser);

  Map get kvps => parser.metadata.kvps;
  List<Movement> get movements => parser.movements;
  List<String> get notes => parser.metadata.notes;
  DateTime get occurred => parser.occurred;

  void writeMetadata() {}
  void writeMovements() {}
  void writeNotes() {}

  String call() {
    result = initString();

    writeMetadata();
    writeNotes();
    writeMovements();

    return result.toString().trim();
  }

  StringBuffer initString() {
    return StringBuffer();
  }
}
