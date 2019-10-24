import "dart:convert";
import "dart:io";

import "package:traindown/src/token.dart";

class Scanner {
  List<int> _bytes;
  Utf8Decoder _decoder;
  int _index = -1;
  int _lastIndex = -1;

  Scanner({String filename, String string}) {
    if (filename != null && string != null) {
      throw "You may only pass a filename OR a string";
    }

    _decoder = Utf8Decoder();

    if (filename != null) {
      var file = File(filename);
      _bytes = file.readAsBytesSync();
      return;
    } else if (string != null) {
      var trimmedString = string.trim();
      if (trimmedString.isEmpty) {
        trimmedString = string;
      }
      _bytes = utf8.encode(trimmedString);
      return;
    }

    throw "You must pass either a filename or string";
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
    if (eof) { return TokenLiteral.eof(); }

    var literal = _next();
    _lastIndex = _index - 1;

    if (_isColon) {
      return TokenLiteral(Token.COLON, literal);
    }
    if (_isDigit) {
      return _scanDigit();
    }
    if (_isLinebreak) {
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
    if (_isCharacter) {
      return _scanIdentifier();
    }

    return TokenLiteral.illegal();
  }

  TokenLiteral _scanIdentifier() {
    var identifier = "";
    while (_isCharacter && !eof) {
      identifier += _current;
      _next();
    }
    if (_isCharacter && eof) {
      identifier += _current;
    } else {
      _prev();
    }
    return TokenLiteral(Token.IDENT, identifier);
  }

  TokenLiteral _scanDigit() {
    var digits = "";
    while (_isDigit && !eof) {
      digits += _current;
      _next();
    }
    if (_isDigit && eof) {
      digits += _current;
    } else {
      _prev();
    }
    return TokenLiteral(Token.UNIT, digits);
  }

  TokenLiteral _scanLinebreak() {
    var hasNexted = false;
    while (_isLinebreak && !eof) {
      hasNexted = true;
      _next();
    }
    if (hasNexted) { _prev(); }

    return TokenLiteral(Token.LINEBREAK, "");
  }

  TokenLiteral _scanWhitespace() {
    var hasNexted = false;
    while (_isWhitespace && !eof) {
      hasNexted = true;
      _next();
    }
    if (hasNexted) { _prev(); }

    return TokenLiteral(Token.WHITESPACE, "");
  }

  void unscan() {
    _index = _lastIndex;
  }
}

