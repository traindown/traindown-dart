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
  DateTime occurred = DateTime.now();

  Movement _currentMovement;
  Performance _currentPerformance;
  Scanner _scanner;

  Parser(Scanner scanner) {
    if (scanner == null) {
      throw "Needs a scanner, dummy";
    }
    _scanner = scanner;
  }
  Parser.for_file(String filename) : this(Scanner(filename: filename));
  Parser.for_string(String string) : this(Scanner(string: string));

  Metadatable get _lastEntity {
    if (_currentPerformance != null) {
      return _currentPerformance;
    } else {
      return _currentMovement;
    }
  }

  void _handleDate() {
    StringBuffer buffer = StringBuffer();
    bool endDate = false;

    while (!_scanner.eof && !endDate) {
      TokenLiteral tokenLiteral = _scanner.scan();

      if (tokenLiteral.isLinebreak) {
        endDate = true;
      }
      if (tokenLiteral.isStar || tokenLiteral.isPound) {
        _scanner.unscan();
        endDate = true;
      }
      if (tokenLiteral.isWhitespace) {
        buffer.write(" ");
        continue;
      }

      buffer.write(tokenLiteral.literal);
    }

    DateTime parsedDate = DateTime.tryParse(buffer.toString().trim());
    if (parsedDate != null) {
      occurred = parsedDate;
    }
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

    if (_lastEntity != null) {
      _lastEntity.addKVP(
          key.toString().trimRight(), value.toString().trimRight());
    } else {
      metadata.addKVP(key.toString().trimRight(), value.toString().trimRight());
    }
  }

  void _handleMovement({TokenLiteral trigger, bool superSetted = false}) {
    bool mustAmount = false;
    StringBuffer nameBuffer =
        StringBuffer(trigger != null ? "${trigger.literal} " : "");

    _currentMovement = null;
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

      // If we must have an amount, we must have an amount or if it's
      // sets and reps, we add a little dash of bypass.
      bool assumeAmount = false;
      if (mustAmount && !tokenLiteral.isAmount) {
        if (tokenLiteral.isReps || tokenLiteral.isSets) {
          assumeAmount = true;
        } else {
          throw "Failed to receive an amount";
        }
      }

      // If we see an amount, create current Performance and push the value
      // there.
      if (tokenLiteral.isAmount || assumeAmount) {
        if (_currentPerformance != null) {
          _currentMovement.performances.add(_currentPerformance);
        }
        _currentPerformance = _newPerformance(_currentMovement.name);
        _currentPerformance.load =
            assumeAmount ? 1 : num.tryParse(tokenLiteral.literal);
        mustAmount = false;

        if (!assumeAmount) continue;
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
        _currentMovement.superSetted = superSetted;
        mustAmount = true;
        continue;
      }

      // We are currently seeing a word. If there is a name for our current
      // Movement, then we must have hit another Movement, so we need to move
      // on. If not, collect the word for the name.
      if (tokenLiteral.isWord) {
        if (_currentMovement == null) {
          nameBuffer.write("${tokenLiteral.literal} ");
          continue;
        } else {
          _scanner.unscan();
          break;
        }
      }

      // If we hit a supersetted exercise, we need to set which is the parent
      // and then move onto the next movement.
      if (tokenLiteral.isPlus) {
        _scanner.unscan();
        break;
      }
    }

    if (_currentPerformance != null) {
      _currentMovement.performances.add(_currentPerformance);
    }

    movements.add(_currentMovement);
  }

  void _handleNote() {
    bool endNote = false;
    StringBuffer note = StringBuffer("");

    while (!_scanner.eof && !endNote) {
      TokenLiteral tokenLiteral = _scanner.scan();

      if (tokenLiteral.isLinebreak) {
        endNote = true;
      }
      if (!tokenLiteral.isWhitespace) {
        note.write("${tokenLiteral.literal} ");
      }
    }

    if (_lastEntity != null) {
      _lastEntity.addNote(note.toString().trimRight());
    } else {
      metadata.addNote(note.toString().trimRight());
    }
  }

  Performance _newPerformance(String movementName) {
    String unit =
        metadata.kvps["Unit"] ?? metadata.kvps["unit"] ?? "unknown unit";
    return Performance(unit: unit);
  }

  set scanner(Scanner newScanner) {
    hasParsed = false;
    metadata = Metadata();
    movements = [];
    occurred = DateTime.now();
    _scanner = newScanner;
    _currentMovement = null;
    _currentPerformance = null;
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
      TokenLiteral tokenLiteral = _scanner.scan();

      if (tokenLiteral.isEmpty) {
        continue;
      }

      if (tokenLiteral.isAt) {
        _handleDate();
      } else if (tokenLiteral.isPound) {
        _handleKVP();
      } else if (tokenLiteral.isStar) {
        _handleNote();
      } else if (tokenLiteral.isWord) {
        _handleMovement(trigger: tokenLiteral);
      } else if (tokenLiteral.isPlus) {
        _handleMovement(superSetted: true);
      }
    }

    hasParsed = true;
  }
}
