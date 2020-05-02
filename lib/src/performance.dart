import "package:traindown/src/metadata.dart";

class Performance extends Metadatable {
  int fails;
  int load;
  Metadata metadata = Metadata();
  int repeat;
  int reps;
  String unit;

  static const List<String> unitKeywords = ["unit", "Unit", "u", "U"];

  Performance(
      {this.fails = 0,
      this.load = 0,
      this.repeat = 1,
      this.reps = 1,
      this.unit = ""});

  @override
  void addKVP(String key, String value) {
    super.addKVP(key, value);
    if (unitKeywords.contains(key)) {
      unit = value;
    }
  }

  String get _metadata {
    if (metadata.kvps.entries.isEmpty) {
      return "";
    }
    StringBuffer ret = StringBuffer();
    for (var mapEntry in metadata.kvps.entries) {
      ret.write("    ${mapEntry.key}: ${mapEntry.value}\n");
    }
    return "\n$ret\n";
  }

  String get _notes {
    if (metadata.notes.isEmpty) {
      return "";
    }
    StringBuffer ret = StringBuffer();
    for (var note in metadata.notes) {
      ret.write("    - $note\n");
    }
    return "\n$ret\n";
  }

  String get _summary {
    if (unit.isNotEmpty) {
      return "$load $unit for $repeat sets of $reps reps.";
    } else {
      return "$load for $repeat sets of $reps reps.";
    }
  }

  @override
  String toString() {
    return "$_summary$_metadata$_notes";
  }
}
