/// All possible types of Traindown tokens.
enum TokenType {
  DateTime,
  Fail,
  Load,
  MetaKey,
  MetaValue,
  Movement,
  Note,
  Rep,
  Set,
  SupersetMovement,
}

/// A Token has a type and a literal. It is the intermediate form of the source
/// that is used by things like the Formatter or Session to understand how
/// to interpret the source.
class Token {
  /// Null terminator
  static final String EOF = "\x00";

  /// The snippet of the source material.
  final String literal;

  /// The kind of token.
  final TokenType tokenType;

  Token(this.tokenType, this.literal);

  static const String DateTime = "Date / Time";
  static const String Fail = "Fails";
  static const String Load = "Load";
  static const String MetaKey = "Metadata Key";
  static const String MetaValue = "Metadata Value";
  static const String Movement = "Movement";
  static const String Note = "Note";
  static const String Rep = "Reps";
  static const String Set = "Sets";
  static const String SupersetMovement = "Superset Movement";

  /// Exchange your String for a TokenType.
  static const Map<String, TokenType> TokenTypeString = {
    DateTime: TokenType.DateTime,
    Fail: TokenType.Fail,
    Load: TokenType.Load,
    MetaKey: TokenType.MetaKey,
    MetaValue: TokenType.MetaValue,
    Movement: TokenType.Movement,
    Note: TokenType.Note,
    Rep: TokenType.Rep,
    Set: TokenType.Set,
    SupersetMovement: TokenType.SupersetMovement,
  };

  /// Exchange your TokenType for a String.
  static const Map<TokenType, String> StringTokenType = {
    TokenType.DateTime: DateTime,
    TokenType.Fail: Fail,
    TokenType.Load: Load,
    TokenType.MetaKey: MetaKey,
    TokenType.MetaValue: MetaValue,
    TokenType.Movement: Movement,
    TokenType.Note: Note,
    TokenType.Rep: Rep,
    TokenType.Set: Set,
    TokenType.SupersetMovement: SupersetMovement,
  };

  /// Useful for debugging purposes. Accepts a stringified list of Tokens and
  /// returns back a List<Token>.
  static List<Token> tokensFromString(String tokensString) {
    return tokensString.split(",").map((pair) {
      List<String> tuple = pair.split("]");
      TokenType tokenType = TokenTypeString[tuple.first.trim().substring(1)];
      String literal = tuple.last.trim();
      return Token(tokenType, literal);
    }).toList();
  }

  /// Tokens are consider equivilent if both the type and the literal match.
  @override
  bool operator ==(t) => t.tokenType == tokenType && t.literal == literal;

  @override
  String toString() => "[${StringTokenType[tokenType]}] $literal";

  /// Returns the Stringified version of a Token.
  String get token => StringTokenType[tokenType] ?? "Invalid";

  /// True if the Token has to do with Movements.
  bool get isMovement =>
      tokenType == TokenType.Movement ||
      tokenType == TokenType.SupersetMovement;

  /// True if the Token has to do with Performances.
  bool get isPerformance =>
      tokenType == TokenType.Load ||
      tokenType == TokenType.Fail ||
      tokenType == TokenType.Rep ||
      tokenType == TokenType.Set;
}
