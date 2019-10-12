class Metadata {
  Map<String, String> kvps = {};
  List<String> notes = [];

  void addKVP(String key, String value) => kvps.putIfAbsent(key, () => value);
  void addNote(String note) => notes.add(note);
}

