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

class Token {
  static final String EOF = r"\0";

  String literal;
  final TokenType _token;

  Token(this._token, this.literal);

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
}
