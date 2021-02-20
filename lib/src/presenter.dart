import "package:traindown/src/movement.dart";
import "package:traindown/src/session.dart";

/// Base class for turning a Session into a string.
abstract class Presenter {
  Session session;

  Presenter(this.session);

  Map get kvps => session.metadata.kvps;
  List<Movement> get movements => session.movements;
  List<String> get notes => session.metadata.notes;
  DateTime get occurred => session.occurred;

  void writeMetadata(StringBuffer result) {}
  void writeMovements(StringBuffer result) {}
  void writeNotes(StringBuffer result) {}

  String present() {
    StringBuffer result = initString();

    writeMetadata(result);
    writeNotes(result);
    writeMovements(result);

    return result.toString().trim();
  }

  StringBuffer initString() {
    return StringBuffer();
  }
}
