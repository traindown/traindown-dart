import 'package:characters/characters.dart';

import "package:traindown/src/token.dart";
import "package:traindown/src/vcr.dart";

/// Lexer is the most low level of the language pieces and it is responsible
/// for processing a list of characters into Tokens. It exposes an API that
/// is to be used by a Parser for a given language. You could generalize this
/// Lexer for use on any language.
class Lexer {
  Function errorHandler = (String msg) => throw msg;
  int position = 0;
  int start = 0;

  late Characters source;
  late Function? state;
  late List<Token> tokens;
  late VCR vcr;

  Lexer(String src, Function initialState) {
    source = Characters(src.trim());
    state = initialState;
    tokens = [];
    vcr = VCR();
  }

  /// Returns the segment of the source character list that is currently
  /// in the buffer as a String.
  String current() => source.skip(start).take(position - start).toString();

  /// Adds a Token of TokenType t containing the current buffer to the tokens
  /// and then clears the buffer as well as the character history.
  void emit(TokenType t) {
    Token token = Token(t, current());
    tokens.add(token);
    start = position;
    vcr.clear();
  }

  void error(String msg) {
    errorHandler(msg);
  }

  /// Dumps the current history and clears the buffer.
  void ignore() {
    vcr.clear();
    start = position;
  }

  /// Grabs the next valid character and if none exists it returns the EOF
  /// token to signal the end of the file.
  String next() {
    if (source.length - 1 == start) {
      vcr.push(Token.EOF);
      return Token.EOF;
    }

    Characters sub = source.skip(position);
    position++;

    if (sub.isEmpty) {
      vcr.push(Token.EOF);
      return Token.EOF;
    } else {
      vcr.push(sub.first);
      return sub.first;
    }
  }

  /// Like next() but it does NOT move the cursor forward in the source. It
  /// allows "peeking" to see what is ahead.
  String peek() {
    String chr = next();
    rewind();

    return chr;
  }

  /// The inverse of next(), this moves the cursor back one character in
  /// the source.
  void rewind() {
    String chr = vcr.pop();

    if (chr != Token.EOF) {
      position--;

      if (position < start) {
        position = start;
      }
    }
  }

  /// This requires a Parser to specify the states. The intent is for the
  /// Parser to call this after defining all possible states and transitions
  /// so that it may produce a list of tokens.
  bool run() {
    while (state != null) {
      state = state!(this);
    }

    return true;
  }

  /// Allows specifying a list of characters to consume. Once the Lexer
  /// encounters a character not on the take list, it returns control back
  /// to the controlling Parser.
  void take(List<String> chrArray) {
    String chr = next();

    while (chrArray.contains(chr)) {
      chr = next();
    }

    rewind();
  }
}
