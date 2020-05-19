import "package:traindown/src/metadata.dart";
import "package:traindown/src/movement.dart";
import "package:traindown/src/performance.dart";
import "package:traindown/src/scanner.dart";
import "package:traindown/src/token.dart";

// TODO: Handle exceptions gracefully...

enum FormatterState {
  initialized,
  awaiting_amount,
  awaiting_metadata_value,
  awaiting_movement_performance,
  capturing_date,
  capturing_metadata_key,
  capturing_movement_name,
  capturing_movement_performance,
  capturing_metadata_value,
  capturing_note,
  idle,
}

class Formatter {
  FormatterState _state = FormatterState.initialized;
  Scanner _scanner;
  StringBuffer output = StringBuffer();

  Formatter(Scanner scanner) {
    if (scanner == null) {
      throw "Needs a scanner, dummy";
    }
    _scanner = scanner;
  }

  Formatter.for_file(String filename) : this(Scanner(filename: filename));
  Formatter.for_string(String string) : this(Scanner(string: string));

  void format() {
    output.clear();

    if (_scanner == null) {
      throw "Needs a scanner, dummy";
    }

    while (!_scanner.eof) {
      TokenLiteral tokenLiteral = _scanner.scan();

      if (tokenLiteral.isAmount) {
        switch (_state) {
          case FormatterState.capturing_date:
          case FormatterState.capturing_metadata_key:
            _addLiteral(tokenLiteral);
            continue;
          case FormatterState.capturing_metadata_value:
            _addLeftPad(tokenLiteral);
            _state = FormatterState.idle;
            continue;
          case FormatterState.capturing_movement_performance:
            _addLinebreak();
            _addSpace(2);
            _addLiteral(tokenLiteral);
            continue;
          case FormatterState.idle:
            _addLinebreak();
            _addSpace(2);
            _addLiteral(tokenLiteral);
            _state = FormatterState.capturing_movement_performance;
            continue;
          default:
            throw ("Unexpected token");
        }
      }

      if (tokenLiteral.isAt) {
        if (_state != FormatterState.initialized) throw ("Expected date");

        _addRightPad(tokenLiteral);
        _state = FormatterState.capturing_date;
      }

      if (tokenLiteral.isColon) {
        switch (_state) {
          case FormatterState.capturing_metadata_key:
            _addLiteral(tokenLiteral);
            _state = FormatterState.capturing_metadata_value;
            continue;
          case FormatterState.capturing_movement_name:
            _addLiteral(tokenLiteral);
            _state = FormatterState.capturing_movement_performance;
            continue;
          default:
            throw ("Unexpected token");
        }
      }

      if (tokenLiteral.isDash) {
        _addLiteral(tokenLiteral);
        continue;
      }

      if (tokenLiteral.isFails) {
        _addLeftPad(tokenLiteral, "f");
        continue;
      }

      if (tokenLiteral.isIllegal) {
        // HMMMM
      }

      if (tokenLiteral.isLinebreak) {
        switch (_state) {
          case FormatterState.capturing_date:
          case FormatterState.capturing_metadata_value:
            _addLinebreak();
            _state = FormatterState.idle;
            continue;
          default:
            continue;
        }
      }

      if (tokenLiteral.isPlus) {
        _addLinebreak();
        _addRightPad(tokenLiteral);
        continue;
      }

      if (tokenLiteral.isPound) {
        switch (_state) {
          case FormatterState.capturing_movement_performance:
            _addLinebreak();
            _addSpace(4);
            _addLiteral(tokenLiteral);
            _state = FormatterState.capturing_metadata_key;
            continue;
          default:
            _addLinebreak();
            _addLiteral(tokenLiteral);
            _state = FormatterState.capturing_metadata_key;
            continue;
        }
      }

      if (tokenLiteral.isReps) {
        _addLeftPad(tokenLiteral, "r");
        continue;
      }

      if (tokenLiteral.isSets) {
        _addLeftPad(tokenLiteral, "s");
        continue;
      }

      if (tokenLiteral.isStar) {
        switch (_state) {
          case FormatterState.capturing_movement_performance:
            _addLinebreak();
            _addSpace(4);
            _addLiteral(tokenLiteral);
            _state = FormatterState.capturing_note;
            continue;
          default:
            _addLinebreak();
            _addLiteral(tokenLiteral);
            _state = FormatterState.capturing_metadata_key;
            continue;
        }
      }

      if (tokenLiteral.isWhitespace) continue;

      if (tokenLiteral.isWord) {
        switch (_state) {
          case FormatterState.capturing_metadata_key:
          case FormatterState.capturing_metadata_value:
          case FormatterState.capturing_movement_name:
          case FormatterState.capturing_note:
            _addLeftPad(tokenLiteral);
            continue;
          case FormatterState.idle:
            _addLinebreak();
            _addLiteral(tokenLiteral);
            _state = FormatterState.capturing_movement_name;
            continue;
          default:
            _addLiteral(tokenLiteral);
            continue;
        }
      }
    }
  }

  void _addLeftPad(TokenLiteral tokenLiteral, [append = ""]) =>
      output.write(" ${tokenLiteral.literal}${append}");

  void _addLinebreak() => output.write("\r\n");

  void _addLiteral(TokenLiteral tokenLiteral) =>
      output.write(tokenLiteral.literal);

  void _addRightPad(TokenLiteral tokenLiteral) =>
      output.write("${tokenLiteral.literal} ");

  void _addSpace([int count = 1]) => output.write(" " * count);
}
