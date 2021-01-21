import 'package:characters/characters.dart';

import "package:traindown/src/token.dart";
import "package:traindown/src/vcr.dart";

class Lexer {
  Function errorHandler = (String msg) => throw msg;
  int position = 0;
  int start = 0;

  Characters source;
  Function state;
  List<Token> tokens;
  VCR vcr;

  Lexer(String src, Function initialState) {
    source = Characters(src);
    state = initialState;
    tokens = [];
    vcr = VCR();
  }

  String current() => source.skip(start).take(position).toString();

  void emit(TokenType t) {
    Token token = Token(t, current());
    tokens.add(token);
    start = position;
    vcr.clear();
  }

  void error(String msg) {
    errorHandler(msg);
  }

  void ignore() {
    vcr.clear();
    start = position;
  }

  String next() {
    if (source.length - 1 == start) {
      vcr.push(Token.EOF);
      return Token.EOF;
    }

    Characters sub = source.skip(position);

    if (sub.isEmpty) {
      vcr.push(Token.EOF);
      return Token.EOF;
    } else {
      position++;
      vcr.push(sub.first);

      return sub.first;
    }
  }

  String peek() {
    String chr = next();
    rewind();

    return chr;
  }

  void rewind() {
    String chr = vcr.pop();

    if (chr != Token.EOF) {
      position--;

      if (position < start) {
        position = start;
      }
    }
  }

  bool run() {
    while (state != null) {
      state = state(this);
    }

    return true;
  }

  void take(List<String> chrArray) {
    String chr = next();

    while (chrArray.contains(chr)) {
      chr = next();
    }

    rewind();
  }
}
