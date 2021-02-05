import "package:traindown/src/movement.dart";
import "package:traindown/src/session.dart";
import "package:traindown/src/token.dart";

abstract class Presenter {
  Session session;

  Map get kvps => session.metadata.kvps;
  List<Movement> get movements => session.movements;
  List<String> get notes => session.metadata.notes;
  DateTime get occurred => session.occurred;

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
