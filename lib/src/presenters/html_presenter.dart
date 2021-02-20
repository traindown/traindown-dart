import "package:traindown/src/movement.dart";
import "package:traindown/src/performance.dart";
import "package:traindown/src/presenter.dart";
import "package:traindown/src/session.dart";

/// Turns a Session into an HTML document.
class HtmlPresenter extends Presenter {
  HtmlPresenter(Session session) : super(session);

  @override
  StringBuffer initString() {
    StringBuffer string = StringBuffer();

    string.write("<h1>Training Session on $occurred</h1>");

    return string;
  }

  @override
  void writeMetadata(StringBuffer result) {
    result.write("<h2>Metadata</h2>");

    if (kvps.entries.isEmpty) {
      result.write("<strong>No metadata for this session.</strong>");
      return;
    }

    result.write("<ul>");

    for (var mapEntry in kvps.entries) {
      result.write(
          "<li><strong>${mapEntry.key}:</strong>&nbsp;${mapEntry.value}</li>");
    }

    result.write("</ul>");
  }

  @override
  void writeMovements(StringBuffer result) {
    result.write("<h2>Movements</h2>");
    result.write(
        "<table><thead><tr><th>Movement</th><th>Load</th><th>Unit</th><th>Sets</th><th>Reps</th></tr></thead><tbody>");

    bool highlight = true;
    String rowClass([String otherClasses = ""]) => highlight
        ? "class='highlighted $otherClasses'"
        : "class='$otherClasses'";

    for (Movement movement in movements) {
      highlight = !highlight;

      int movementRowCount = 1;
      StringBuffer movementBuffer = StringBuffer(
          "<tr ${rowClass()}><td rowspan='ROWCOUNT'>${movement.name}</td></tr>");

      for (Performance p in movement.performances) {
        StringBuffer perfRows = StringBuffer(
            "<tr ${rowClass()}><td>${p.load}</td><td>${p.unit}</td><td>${p.sets}</td><td>${p.reps}</td></tr>");
        movementRowCount++;

        if (p.metadata.notes.isNotEmpty) {
          perfRows.write(
              "<tr ${rowClass('notes')}><td colspan='5'><strong>Notes</strong><ul>");

          for (String pn in p.metadata.notes) {
            perfRows.write("<li>$pn</li>");
          }
          perfRows.write("</ul></td></tr>");
          movementRowCount++;
        }

        if (p.metadata.kvps.isNotEmpty) {
          perfRows.write(
              "<tr ${rowClass('metadata')}><td colspan='5'><strong>Metadata</strong><ul>");

          for (MapEntry<String, String> pm in p.metadata.kvps.entries) {
            perfRows.write("<li>${pm.key}: ${pm.value}</li>");
          }
          perfRows.write("</ul></td></tr>");
          movementRowCount++;
        }

        movementBuffer.write(perfRows.toString());
      }

      String movementString = movementBuffer.toString();
      result
          .write(movementString.replaceFirst("ROWCOUNT", "$movementRowCount"));
    }

    result.write("</table>");
  }

  @override
  void writeNotes(StringBuffer result) {
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
