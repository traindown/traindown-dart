import 'package:traindown/src/token.dart';

class Formatter {
  String indenter, linebreaker, spacer;

  bool _pastSession = false;
  bool _pastMovement = false;
  bool _movementHasPerformanced = false;
  bool _performanceNeedsLoad = false;

  Formatter(
      {this.indenter = '  ', this.linebreaker = '\r\n', this.spacer = ' '});

  String format(List<Token> tokens) {
    _reset();
    StringBuffer buffer = StringBuffer();

    tokens.forEach((t) => buffer.write(stringFor(t)));

    return buffer.toString();
  }

  void _reset() {
    _pastSession = false;
    _pastMovement = false;
    _movementHasPerformanced = false;
    _performanceNeedsLoad = false;
  }

  String stringFor(Token t) {
    String ret = '';

    switch (t.tokenType) {
      case TokenType.DateTime:
        ret = "@ ${t.literal}$linebreaker";
        break;
      case TokenType.Fail:
        _pastMovement = true;
        _performanceNeedsLoad = _performanceNeedsLoad || true;
        String pre = (_performanceNeedsLoad || !_movementHasPerformanced)
            ? spacer
            : "$linebreaker$spacer";
        ret = "$pre${t.literal}f";
        break;
      case TokenType.Load:
        _pastMovement = true;
        String pre = (_performanceNeedsLoad && !_movementHasPerformanced)
            ? indenter
            : "$linebreaker$indenter";
        _movementHasPerformanced = true;
        _performanceNeedsLoad = false;
        ret = "$pre${t.literal}";
        break;
      case TokenType.MetaKey:
        int iter = (_pastMovement) ? 2 : (_pastSession) ? 1 : 0;
        ret = "$linebreaker${indenter * iter}# ${t.literal}:";
        break;
      case TokenType.MetaValue:
        ret = "$spacer${t.literal}";
        break;
      case TokenType.Movement:
        _pastSession = true;
        _pastMovement = false;
        _movementHasPerformanced = false;
        _performanceNeedsLoad = false;
        String pre = (t.literal.startsWith(RegExp(r'\d'))) ? "'" : '';
        ret = "${linebreaker * 2}$pre${t.literal}:";
        break;
      case TokenType.Note:
        int iter = (_pastMovement) ? 2 : (_pastSession) ? 1 : 0;
        ret = "$linebreaker${indenter * iter}*$spacer${t.literal}";
        break;
      case TokenType.Rep:
        _pastMovement = true;
        _performanceNeedsLoad = _performanceNeedsLoad || true;
        String pre = (_performanceNeedsLoad || !_movementHasPerformanced)
            ? spacer
            : "$linebreaker$spacer";
        ret = "$pre${t.literal}r";
        break;
      case TokenType.Set:
        _pastMovement = true;
        _performanceNeedsLoad = _performanceNeedsLoad || true;
        String pre = (_performanceNeedsLoad || !_movementHasPerformanced)
            ? spacer
            : "$linebreaker$spacer";
        ret = "$pre${t.literal}s";
        break;
      case TokenType.SupersetMovement:
        _pastSession = true;
        _pastMovement = false;
        _performanceNeedsLoad = false;
        String pre = (t.literal.startsWith(RegExp(r'\d'))) ? "'" : '';
        ret = "${linebreaker * 2}+$spacer$pre${t.literal}:";
        break;
    }

    return ret;
  }
}
