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

  Movement _currentMovement;
  Performance _currentPerformance;
  Scanner _scanner;

  Parser(Scanner scanner) {
    if (scanner == null) {
      throw "Needs a scanner, dummy";
    }
    _scanner = scanner;
  }

  Metadatable get _lastEntity {
    if (_currentPerformance != null) {
      return _currentPerformance;
    } else {
      return _currentMovement;
    }
  }

  void _handleDate() {
    var dateBuffer = "";
    var endDate = false;

    while (!_scanner.eof && !endDate) {
      var tokenLiteral = _scanner.scan();

      if (tokenLiteral.token == Token.LINEBREAK) {
        endDate = true;
      }
      if (tokenLiteral.token == Token.STAR ||
          tokenLiteral.token == Token.POUND) {
        _scanner.unscan();
        endDate = true;
      }

      dateBuffer += tokenLiteral.literal;
    }

    metadata.addKVP("Occurred", dateBuffer.trimRight());
  }

  void _handleKVP() {
    bool endKVP = false;
    StringBuffer key = StringBuffer("");
    bool keyComplete = false;
    StringBuffer value = StringBuffer("");

    while (!_scanner.eof && !endKVP) {
      TokenLiteral tokenLiteral = _scanner.scan();

      if (tokenLiteral.isLinebreak) {
        endKVP = true;
      }
      if (tokenLiteral.isColon) {
        keyComplete = true;
        continue;
      }
      if (!tokenLiteral.isWhitespace) {
        StringBuffer buffer = !keyComplete ? key : value;
        buffer.write("${tokenLiteral.literal} ");
      }
    }

    (_lastEntity != null ? _lastEntity.metadata : metadata)
        .addKVP(key.toString().trimRight(), value.toString().trimRight());
  }

  // TODO: Break this up
  void _handleMovement(TokenLiteral initial) {
    bool mustAmount = false;
    StringBuffer nameBuffer = StringBuffer("${initial.literal} ");

    _currentMovement = Movement(null);
    _currentPerformance = null;

    while (!_scanner.eof) {
      TokenLiteral tokenLiteral = _scanner.scan();

      // We check for metadata and notes prior to any amount so that we
      // may support Movement meta/notes.
      if (tokenLiteral.isStar) {
        _handleNote();
      }
      if (tokenLiteral.isPound) {
        _handleKVP();
      }

      // If we must have an amount but we see empty spaces, keep going
      if (mustAmount && tokenLiteral.isEmpty) {
        continue;
      }

      // If we must have an amount, we must have an amount
      if (mustAmount && !tokenLiteral.isAmount) {
        throw "Failed to receive an amount";
      }

      // If we see an amount, create current Performance and push the value
      // there.
      // TODO: Rescue failed parse
      if (tokenLiteral.isAmount) {
        if (_currentPerformance != null) {
          _currentMovement.performances.add(_currentPerformance);
        }
        _currentPerformance = _newPerformance(_currentMovement.name);
        _currentPerformance.load = num.tryParse(tokenLiteral.literal);
        mustAmount = false;
        continue;
      }

      // If we see fails...
      if (tokenLiteral.isFails) {
        _currentPerformance.fails = num.tryParse(tokenLiteral.literal);
        continue;
      }

      // If we see reps...
      if (tokenLiteral.isReps) {
        _currentPerformance.reps = num.tryParse(tokenLiteral.literal);
        continue;
      }

      // If we see sets...
      if (tokenLiteral.isSets) {
        _currentPerformance.repeat = num.tryParse(tokenLiteral.literal);
        continue;
      }

      // End of the Movement name. We now bootstrap the data and we must now
      // see an amount next, thus
      if (tokenLiteral.isColon) {
        _currentMovement = Movement(nameBuffer.toString().trimRight());
        mustAmount = true;
        continue;
      }

      // We are currently seeing a word. If there is a name for our current
      // Movement, then we must have hit another Movement, so we need to move
      // on. If not, collect the word for the name.
      if (tokenLiteral.isWord) {
        if (_currentMovement.name == null) {
          nameBuffer.write("${tokenLiteral.literal} ");
          continue;
        } else {
          _scanner.unscan();
          break;
        }
      }
    }

    if (_currentPerformance != null) {
      _currentMovement.performances.add(_currentPerformance);
    }

    movements.add(_currentMovement);
  }

  void _handleNote() {
    var endNote = false;
    var note = StringBuffer("");

    while (!_scanner.eof && !endNote) {
      var tokenLiteral = _scanner.scan();

      if (tokenLiteral.token == Token.LINEBREAK) {
        endNote = true;
      }
      if (tokenLiteral.token != Token.WHITESPACE) {
        note.write("${tokenLiteral.literal} ");
      }
    }

    (_lastEntity != null ? _lastEntity.metadata : metadata)
        .addNote(note.toString().trimRight());
  }

  Performance _newPerformance(String movementName) {
    if (movementName.startsWith("+")) {
      movementName = movementName.split("+").last.trim();
    }
    var unit = metadata.kvps["Unit for $movementName"] ??
        metadata.kvps["unit for $movementName"] ??
        metadata.kvps["Unit"] ??
        metadata.kvps["unit"] ??
        "unknown unit";
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
    if (hasParsed) {
      return;
    }
    if (_scanner == null) {
      throw "Needs a scanner, dummy";
    }

    while (!_scanner.eof) {
      var tokenLiteral = _scanner.scan();

      if (tokenLiteral.isEmpty) {
        continue;
      }

      if (tokenLiteral.token == Token.AT) {
        _handleDate();
      } else if (tokenLiteral.token == Token.POUND) {
        _handleKVP();
      } else if (tokenLiteral.token == Token.STAR) {
        _handleNote();
      } else if (tokenLiteral.token == Token.WORD) {
        _handleMovement(tokenLiteral);
      }
    }

    hasParsed = true;
  }
}
