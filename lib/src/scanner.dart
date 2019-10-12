import "dart:convert";
import "dart:io";

import "./token.dart";

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


