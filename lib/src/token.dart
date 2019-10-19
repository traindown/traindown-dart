class Token {
  static const COLON = "Colon";
  static const EOF = "EOF";
  static const IDENT = "Identifier";
  static const ILLEGAL = "Illegal";
  static const LINEBREAK = "Linebreak";
  static const POUND = "Pound";
  static const SEMICOLON = "Semicolon";
  static const STAR = "Star";
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

  bool get isEmpty => token == Token.LINEBREAK || token == Token.WHITESPACE;

  @override String toString() => "$token: $literal";
}
