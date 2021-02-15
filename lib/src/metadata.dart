class Metadata {
  Map<String, String> kvps = {};
  List<String> notes = [];

  void addKVP(String key, String value) => kvps.putIfAbsent(key, () => value);
  void addNote(String note) => notes.add(note);

  @override
  String toString() {
    StringBuffer output = StringBuffer();

    output.write("** Metadata **\n");

    if (kvps.entries.isEmpty) {
      output.write("No metadata.");
    } else {
      for (var mapEntry in kvps.entries) {
        output.write("${mapEntry.key}: ${mapEntry.value}\n");
      }
    }

    output.write("\n** Notes **\n");

    if (notes.isEmpty) {
      output.write("No notes.");
    } else {
      for (var note in notes) {
        output.write(" - $note\n");
      }
    }

    return output.toString();
  }
}

abstract class Metadatable {
  Metadata metadata = Metadata();

  void addKVP(String key, String value) =>
      metadata.kvps.putIfAbsent(key, () => value);
  void addNote(String note) => metadata.notes.add(note);
}
