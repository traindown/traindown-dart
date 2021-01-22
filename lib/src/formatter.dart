import 'package:traindown/src/token.dart';

String format(List<Token> tokens, {String linebreak = '\r\n', int indent = 2}) {
  bool inM = false;
  bool inP = false;
  StringBuffer buffer = StringBuffer();

  tokens.fold(buffer, (b, t) {
    b.write(formatToken(t, linebreak, indent, inM, inP));
    return b;
  });

  return buffer.toString();
}

String formatToken(Token t, String lb, int i, bool inM, bool inP) {
  String ret = '';

  switch (t.tokenType) {
    case TokenType.DateTime:
      ret = "@ ${t.literal}$lb";
      break;
    case TokenType.Fail:
      ret = " ${leftPad(i)}${t.literal}f";
      break;
    case TokenType.Load:
      ret = " ${leftPad(i)}${t.literal}";
      break;
    case TokenType.MetaKey:
      int iter = (inP) ? 4 : (inM) ? 2 : 0;
      ret = "${leftPad(i * iter)}# ${t.literal}:";
      break;
    case TokenType.MetaValue:
      ret = " ${t.literal}$lb";
      break;
    case TokenType.Movement:
      String pre = (t.literal.startsWith(RegExp(r'\d'))) ? "'" : '';
      ret = "$pre${t.literal}:$lb";
      break;
    case TokenType.Note:
      int iter = (inP) ? 4 : (inM) ? 2 : 0;
      ret = "${leftPad(i * iter)}* ${t.literal}$lb";
      break;
    case TokenType.Rep:
      ret = " ${leftPad(i)}${t.literal}r";
      break;
    case TokenType.Set:
      ret = " ${leftPad(i)}${t.literal}s";
      break;
    case TokenType.SupersetMovement:
      ret = "+ ${t.literal}:$lb";
      break;
  }

  return ret;
}

String leftPad([int count = 2]) => ' ' * count;
