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

  String literal;
  final TokenType _token;

  Token(this._token, this.literal);

  /// Tokens are consider equivilent if both the type and the literal match.
  @override
  bool operator ==(t) => t.token == token && t.literal == literal;

  @override
  String toString() => "[$token] $literal";

  TokenType get tokenType => _token;

  String get token {
    String title = "Invalid";

    switch (_token) {
      case TokenType.DateTime:
        title = "Date / Time";
        break;
      case TokenType.Fail:
        title = "Fails";
        break;
      case TokenType.Load:
        title = "Load";
        break;
      case TokenType.MetaKey:
        title = "Metadata Key";
        break;
      case TokenType.MetaValue:
        title = "Metadata Value";
        break;
      case TokenType.Movement:
        title = "Movement";
        break;
      case TokenType.Note:
        title = "Note";
        break;
      case TokenType.Rep:
        title = "Reps";
        break;
      case TokenType.Set:
        title = "Sets";
        break;
      case TokenType.SupersetMovement:
        title = "Superset Movement";
        break;
    }

    return title;
  }

  bool get isMovement =>
      _token == TokenType.Movement || _token == TokenType.SupersetMovement;

  bool get isPerformance =>
      _token == TokenType.Load ||
      _token == TokenType.Fail ||
      _token == TokenType.Rep ||
      _token == TokenType.Set;
}
