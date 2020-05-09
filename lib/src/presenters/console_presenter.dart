import "package:traindown/src/parser.dart";
import "package:traindown/src/presenter.dart";

class ConsolePresenter extends Presenter {
  ConsolePresenter(Parser parser) : super(parser);

  @override
  StringBuffer initString() {
    StringBuffer string = StringBuffer();
    String title = "$occurred Training";

    string.write("$title\n");
    string.write("${'=' * title.length}\n\n");

    return string;
  }

  @override
  void writeMetadata() {
    result.write("** Metadata **\n");

    if (kvps.entries.isEmpty) {
      result.write("No metadata for this session.");
      return;
    }

    for (var mapEntry in kvps.entries) {
      result.write("${mapEntry.key}: ${mapEntry.value}\n");
    }
  }

  @override
  void writeMovements() {
    result.write("\n\n** Movements **\n");

    for (var movement in movements) {
      result.write("$movement\n");
    }
  }

  @override
  void writeNotes() {
    result.write("\n** Notes **\n");

    if (notes.isEmpty) {
      result.write(" - No notes for this session");
      return;
    }

    for (var note in notes) {
      result.write(" - $note\n");
    }
  }
}
