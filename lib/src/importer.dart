import 'package:traindown/src/parser.dart';
import 'package:traindown/src/session.dart';

/// Importer provides a means to pull in a blob of multiple Sessions and
/// spit out Session instances.
class Importer {
  List<String> errors = [];
  List<Session> sessions = [];
  List<String> sessionTexts = [];

  String input;

  Importer(this.input) {
    sessionTexts =
        input.split("@").skip(1).map((sessionText) => "@$sessionText").toList();
    _parseSessions();
  }

  void _parseSessions() {
    sessionTexts.forEach((sessionText) {
      Parser parser = Parser(sessionText);

      Session session = Session(parser.tokens());
      // TODO: Errors...
      sessions.add(session);
    });
  }
}
