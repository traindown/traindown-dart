import "package:traindown/src/parser.dart";
import "package:traindown/src/presenter.dart";

class HtmlPresenter extends Presenter {
  HtmlPresenter(Parser parser) : super(parser);

  @override
  StringBuffer initString() {
    StringBuffer string = StringBuffer();

    string.write("<h1>Training Session on $occurred</h1>");

    return string;
  }

  @override
  void writeMetadata() {
    result.write("<h2>Metadata</h2>");

    if (kvps.entries.isEmpty) {
      result.write("<strong>No metadata for this session.</strong>");
      return;
    }

    result.write("<dl>");

    for (var mapEntry in kvps.entries) {
      result.write("<dt>${mapEntry.key}</dt><dd>${mapEntry.value}</dd>");
    }

    result.write("</dl>");
  }

  @override
  void writeMovements() {
    result.write("<h2>Movements</h2>");
    result.write(
        "<table><thead><tr><th>Movement</th><th>Load</th><th>Unit</th><th>Sets</th><th>Reps</th></tr></thead><tbody>");

    for (var movement in movements) {
      result.write("<tr><td colspan=\"5\">${movement.name}</td></tr>");
      for (var p in movement.performances) {
        result.write(
            "<tr><td></td><td>${p.load}</td><td>${p.unit}</td><td>${p.repeat}</td><td>${p.reps}</td></tr>");
      }
    }

    result.write("</table>");
  }

  @override
  void writeNotes() {
    result.write("<h2>Notes</h2>");

    if (notes.isEmpty) {
      result.write("<strong>No notes for this session.</strong>");
      return;
    }

    result.write("<ul>");

    for (var note in notes) {
      result.write("<li>$note</li>");
    }

    result.write("</ul>");
  }
}
