class Metadata {
  Map<String, String> kvps = {};
  List<String> notes = [];

  /// These are the special meta keywords to denote bodyweight.
  static const List<String> bodyweightKeywords = [
    'bodyweight',
    'Bodyweight',
    'bw',
    'BW',
  ];

  /// These are the special meta keywords that can affect the Performance
  /// unit. These may exist at the Session, Movement, or Performance scope.
  static const List<String> unitKeywords = [
    'unit',
    'Unit',
    'u',
    'U',
  ];

  /// In cases where we do not know the unit, we have a constant we can fall
  /// back onto.
  static const unknownUnit = "unknown unit";

  /// Add a key/value pair for a key not currently in the map.
  void addKVP(String key, String value) => kvps.putIfAbsent(key, () => value);

  /// Add a note.
  void addNote(String note) => notes.add(note);

  /// Set the value for the given key.
  void setKVP(String key, String value) => kvps[key] = value;

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

/// Metadatable provides an API for notes and kvps that are available
/// at each scope of a Traindown document.
abstract class Metadatable {
  Metadata metadata = Metadata();
  String unit = Metadata.unknownUnit;

  /// Adds the key value pair to the KVPs.
  void addKVP(String key, String value) {
    if (Metadata.unitKeywords.contains(key)) {
      unit = value;
    } else {
      metadata.addKVP(key, value);
    }
  }

  /// Adds a note.
  void addNote(String note) => metadata.notes.add(note);

  /// Convenience access to kvps.
  Map<String, String> get kvps => metadata.kvps;

  /// Convenience access to notes.
  List<String> get notes => metadata.notes;

  /// Sets the value for the given key.
  void setKVP(String key, String value) {
    if (Metadata.unitKeywords.contains(key)) {
      unit = value;
    } else {
      metadata.setKVP(key, value);
    }
  }
}
