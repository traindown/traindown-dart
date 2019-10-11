import "dart:convert";
import "dart:io";

class Token {
  static const COLON = "Colon";
  static const DATE = "Date";
  static const EOF = "EOF";
  static const IDENT = "Identifier";
  static const ILLEGAL = "Illegal";
  static const LINEBREAK = "Linebreak";
  static const POUND = "Pound";
  static const REP = "Rep";
  static const SEMICOLON = "Semicolon";
  static const SET = "Set";
  static const STAR = "Star";
  static const TIME = "Time";
  static const UNIT = "Unit";
  static const WHITESPACE = "Whitespace";
}

class TokenLiteral {
  String literal;
  String token;

  TokenLiteral(this.token, this.literal);

  TokenLiteral.eof() {
    literal = "";
    token = Token.EOF;
  }

  TokenLiteral.illegal() {
    literal = "";
    token = Token.ILLEGAL;
  }

  @override String toString() => "$token: $literal";
}

class Scanner {
  List<int> _bytes;
  Utf8Decoder _decoder;
  File _file;
  int _index = -1;

  Scanner(String filename) {
    _decoder = new Utf8Decoder();
    _file = new File(filename);
    _bytes = _file.readAsBytesSync();
  }

  String get _current {
    return (_index >= _bytes.length) ? "" : _decoder.convert([_bytes.elementAt(_index)]);
  }

  bool get eof => _index == _bytes.length - 1;
  bool get _isCharacter {
    return !_isColon
      && !_isDigit
      && !_isLinebreak
      && !_isPound
      && !_isSemicolon
      && !_isStar
      && !_isWhitespace;
  }
  bool get _isColon => _current == ":";
  bool get _isDigit => num.tryParse(_current) != null;
  bool get _isLinebreak => _current == "\n" || _current == "\r";
  bool get _isPound => _current == "#";
  bool get _isSemicolon => _current == ";";
  bool get _isStar => _current == "*";
  bool get _isWhitespace => _current == " " || _current == "\t";

  String _next() => _decoder.convert([_bytes.elementAt(++_index)]);
  String _prev() => _decoder.convert([_bytes.elementAt(--_index)]);

  void reset() => _index = -1;

  TokenLiteral scan() {
    var literal = _next();

    if (_isColon) {
      return TokenLiteral(Token.COLON, literal);
    }
    if (_isDigit) {
      return _scanDigit();
    }
    if (_isLinebreak) {
      if (eof) {
        return TokenLiteral.eof();
      }
      return _scanLinebreak();
    }
    if (_isPound) {
      return TokenLiteral(Token.POUND, literal);
    }
    if (_isSemicolon) {
      return TokenLiteral(Token.SEMICOLON, literal);
    }
    if (_isStar) {
      return TokenLiteral(Token.STAR, literal);
    }
    if (_isWhitespace) {
      return _scanWhitespace();
    }

    return _scanIdentifier();
  }

  TokenLiteral _scanIdentifier() {
    var identifier = "";
    while (_isCharacter) {
      identifier += _current;
      _next();
    }
    _prev();
    return new TokenLiteral(Token.IDENT, identifier);
  }

  TokenLiteral _scanDigit() {
    var digits = "";
    while (_isDigit) {
      digits += _current;
      _next();
    }
    _prev();
    return new TokenLiteral(Token.UNIT, digits);
  }

  TokenLiteral _scanLinebreak() {
    while (_isLinebreak) { _next(); }
    _prev();
    return new TokenLiteral(Token.LINEBREAK, "");
  }

  TokenLiteral _scanWhitespace() {
    while (_isWhitespace) { _next(); }
    _prev();
    return new TokenLiteral(Token.WHITESPACE, "");
  }
}

class Metadata {
  Map<String, String> kvps = {};
  List<String> notes = [];

  void addKVP(String key, String value) => kvps.putIfAbsent(key, () => value);
  void addNote(String note) => notes.add(note);
}

class Movement {
  String name;
  List<Performance> performances = [];

  Movement(this.name);

  @override String toString() {
    return "$name:\n  ${performances.join('\n  ')}\n";
  }
}

class Performance {
  int load = 0;
  int repeat = 1;
  int reps = 1;
  String unit = "";

  @override String toString() => "$load $unit for $repeat sets of $reps reps.";
}

class Parser {
  Metadata metadata = Metadata();
  List<Movement> movements = [];

  Scanner _scanner;

  Parser(this._scanner);

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
      
      // TODO: Eventually need to support line breaks in movements...
      if (tokenLiteral.token == Token.LINEBREAK) { break; }
      if (tokenLiteral.token == Token.WHITESPACE) {
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
        performance = Performance();
        mustUnit = true;
        continue;
      }

      // This should indicate end of movement...
      if (mustUnit && tokenLiteral.token != Token.UNIT) {
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
        performance = Performance();
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

  void parse() {
    if (_scanner == null) { throw "Needs a scanner, dummy"; }

    while (!_scanner.eof) {
      var tokenLiteral = _scanner.scan();
      
      if (tokenLiteral.token == Token.POUND) { _handleKVP(); }
      else if (tokenLiteral.token == Token.STAR) { _handleNote(); }
      else { _handleMovement(tokenLiteral); }
    }
  }
}

abstract class ParserPresenter {
  Parser _parser;
  ParserPresenter(this._parser);
  String call();
}

class ConsolePresenter implements ParserPresenter {
  Parser _parser;
  ConsolePresenter(this._parser);

  Map get kvps => _parser.metadata.kvps;
  List<Movement> get movements => _parser.movements;
  List<String> get notes => _parser.metadata.notes;

  String call() {
    var string = StringBuffer("** Metadata **\n");
    for (var mapEntry in kvps.entries) {
      string.write("${mapEntry.key}: ${mapEntry.value}\n");
    }
    string.write("\n\n** Notes **\n");
    for (var note in notes) {
      string.write(" - $note\n");
    }
    string.write("\n\n** Movements **\n");
    for (var movement in movements) {
      string.write("$movement\n");
    }

    return string.toString();
  }
}

void main() {
  var scanner = Scanner("./test.traindown");
  var parser = Parser(scanner);
  var presenter = ConsolePresenter(parser);
  parser.parse();
  print(presenter.call());
}
