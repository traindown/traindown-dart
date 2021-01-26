import "package:traindown/src/movement.dart";
import "package:traindown/src/token.dart";

abstract class Presenter {
  Map get kvps => parser.metadata.kvps;
  List<Movement> get movements => parser.movements;
  List<String> get notes => parser.metadata.notes;
  DateTime get occurred => parser.occurred;

  void writeMetadata() {}
  void writeMovements() {}
  void writeNotes() {}

  String present(List<Token> tokens) {
    StringBuffer result = initString();

    writeMetadata();
    writeNotes();
    writeMovements();

    return result.toString().trim();
  }

  StringBuffer initString() {
    return StringBuffer();
  }
}
