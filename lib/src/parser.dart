import "package:traindown/src/metadata.dart";
import "package:traindown/src/movement.dart";
import "package:traindown/src/performance.dart";
import "package:traindown/src/scanner.dart";
import "package:traindown/src/token.dart";

/// Parser uses the provided Scanner to create an intermediate representation of the training session.
class Parser {
  bool hasParsed = false;
  Metadata metadata = Metadata();
  List<Movement> movements = [];

  Scanner _scanner;

  Parser(Scanner scanner) {
    if (scanner == null) { throw "Needs a scanner, dummy"; }
    _scanner = scanner;
  }

  void _handleKVP() {
    var endKVP = false;
    var key = StringBuffer("");
    var keyComplete = false;
    var value = StringBuffer("");

    while (!_scanner.eof && !endKVP) {
      var tokenLiteral = _scanner.scan();

      if (tokenLiteral.token == Token.LINEBREAK) { endKVP = true; }
      if (tokenLiteral.token == Token.COLON) { keyComplete = true; continue; }
      if (tokenLiteral.token != Token.WHITESPACE) {
        var buffer = !keyComplete ? key : value;
        buffer.write("${tokenLiteral.literal} ");
      }
    }

    metadata.addKVP(key.toString().trimRight(), value.toString().trimRight());
  }

  void _handleMovement(TokenLiteral initial) {
    String currentUnit;
    var mustUnit = false;
    Movement movement;
    var name = StringBuffer("${initial.literal} ");
    Performance performance;

    while (!_scanner.eof) {
      var tokenLiteral = _scanner.scan();

      if (tokenLiteral.isEmpty) {
        if (currentUnit != null) {
          performance.load = num.tryParse(currentUnit);
          currentUnit = null;
        }
        continue;
      }

      if (tokenLiteral.token == Token.SEMICOLON) {
        if (currentUnit != null) {
          performance.load = num.tryParse(currentUnit);
          currentUnit = null;
        }
        movement.performances.add(performance);
        performance = _newPerformance(movement.name);
        mustUnit = true;
        continue;
      }

      // This should indicate end of movement...
      if (mustUnit && tokenLiteral.token != Token.UNIT) {
        _scanner.unscan();
        break;
      }

      if (tokenLiteral.token == Token.UNIT) {
        currentUnit = tokenLiteral.literal;
        mustUnit = false;
        continue;
      }

      if (tokenLiteral.token == Token.COLON) {
        movement = Movement(name.toString().trimRight());
        mustUnit = true;
        performance = _newPerformance(movement.name);
        continue;
      }

      if (tokenLiteral.token == Token.IDENT) {
        if (movement == null) {
          name.write("${tokenLiteral.literal} ");
          continue;
        } else {
          if (tokenLiteral.literal == "s") {
            performance.repeat = num.tryParse(currentUnit);
          }
          if (tokenLiteral.literal == "r") {
            performance.reps = num.tryParse(currentUnit);
          }
          currentUnit = null;
          continue;
        }
      }
    }

    movements.add(movement);
  }

  void _handleNote() {
    var endNote = false;
    var note = StringBuffer("");

    while (!_scanner.eof && !endNote) {
      var tokenLiteral = _scanner.scan();

      if (tokenLiteral.token == Token.LINEBREAK) { endNote = true; }
      if (tokenLiteral.token != Token.WHITESPACE) { note.write("${tokenLiteral.literal} "); }
    }

    metadata.addNote(note.toString().trimRight());
  }

  Performance _newPerformance(String movementName) {
    if (movementName.startsWith("+")) {
      movementName = movementName.split("+").last.trim();
    }
    var unit = metadata.kvps["Unit for $movementName"]
      ?? metadata.kvps["unit for $movementName"]
      ?? metadata.kvps["Unit"]
      ?? metadata.kvps["unit"]
      ?? "unknown unit";
    return Performance(unit: unit);
  }

  set scanner(Scanner newScanner) {
    hasParsed = false;
    metadata = Metadata();
    movements = [];
    _scanner = newScanner;
  }

  /// parse runs the provided Scanner until eof signal and stores the metadata and movements.
  void parse() {
    if (hasParsed) { return; }
    if (_scanner == null) { throw "Needs a scanner, dummy"; }

    while (!_scanner.eof) {
      var tokenLiteral = _scanner.scan();

      if (tokenLiteral.isEmpty) { continue; }
      
      if (tokenLiteral.token == Token.POUND) { _handleKVP(); }
      else if (tokenLiteral.token == Token.STAR) { _handleNote(); }
      else if (tokenLiteral.token == Token.IDENT) { _handleMovement(tokenLiteral); }
    }
    hasParsed = true;
  }
}
