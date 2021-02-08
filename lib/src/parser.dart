import "package:traindown/src/lexer.dart";
import "package:traindown/src/token.dart";

class Parser {
  Lexer lexer;

  Parser(String source) {
    lexer = Lexer(source, idleState);
  }

  // TODO: Error handling
  List<Token> tokens() {
    lexer.run();
    return lexer.tokens;
  }
}

Function idleState(Lexer lexer) {
  String chr = lexer.peek();

  if (chr == Token.EOF) {
    return null;
  }

  if (isWhitespace(chr) || isLineTerminator(chr)) {
    lexer.next();
    lexer.ignore();

    return idleState;
  }

  switch (chr) {
    case "@":
      return dateTimeState;
    case "#":
      return metaKeyState;
    case "*":
      return noteState;
    default:
      return valueState;
  }
}

Function dateTimeState(Lexer lexer) {
  lexer.take(["@", " "]);
  lexer.ignore();

  String chr = lexer.next();

  while (!isLineTerminator(chr)) {
    chr = lexer.next();
  }

  lexer.rewind();
  lexer.emit(TokenType.DateTime);

  return idleState;
}

Function metaKeyState(Lexer lexer) {
  lexer.take(["#", " "]);
  lexer.ignore();

  String chr = lexer.next();

  while (chr != ":") {
    chr = lexer.next();
  }

  lexer.rewind();
  lexer.emit(TokenType.MetaKey);

  return metaValueState;
}

Function metaValueState(Lexer lexer) {
  lexer.take([":", " "]);
  lexer.ignore();

  String chr = lexer.next();

  while (!isLineTerminator(chr)) {
    chr = lexer.next();
  }

  lexer.rewind();
  lexer.emit(TokenType.MetaValue);

  return idleState;
}

Function movementState(Lexer lexer) {
  bool superset = false;

  String chr = lexer.next();

  if (chr == "+") {
    superset = true;
    lexer.take([" "]);
    lexer.ignore();
    chr = lexer.next();
  }

  if (chr == "'") {
    lexer.ignore();
    chr = lexer.next();
  }

  while (chr != ":") {
    chr = lexer.next();
  }

  lexer.rewind();

  if (superset) {
    lexer.emit(TokenType.SupersetMovement);
  } else {
    lexer.emit(TokenType.Movement);
  }

  lexer.take([":"]);
  lexer.ignore();

  return idleState;
}

Function noteState(Lexer lexer) {
  lexer.take(["*", " "]);
  lexer.ignore();

  String chr = lexer.next();

  while (!isLineTerminator(chr)) {
    chr = lexer.next();
  }

  lexer.rewind();
  lexer.emit(TokenType.Note);

  return idleState;
}

Function numberState(Lexer lexer) {
  lexer.take(["0", "1", "2", "3", "4", "5", "6", "7", "8", "9", "."]);

  switch (lexer.peek()) {
    case "f":
    case "F":
      lexer.emit(TokenType.Fail);
      break;
    case "r":
    case "R":
      lexer.emit(TokenType.Rep);
      break;
    case "s":
    case "S":
      lexer.emit(TokenType.Set);
      break;
    default:
      lexer.emit(TokenType.Load);
  }

  lexer.take(["f", "F", "r", "R", "s", "S"]);
  lexer.ignore();

  return idleState;
}

Function valueState(Lexer lexer) {
  String chr = lexer.next();

  if (chr == "+" || chr == "'") {
    lexer.rewind();
    return movementState;
  }

  if (int.tryParse(chr) != null) {
    return numberState;
  }

  if (chr != "b" && chr != "B") {
    lexer.rewind();
    return movementState;
  }

  String p = lexer.peek();

  if (p != "w" && p != "W") {
    lexer.rewind();
    return movementState;
  }

  while (!isWhitespace(chr)) {
    chr = lexer.next();
  }

  lexer.rewind();
  lexer.emit(TokenType.Load);

  return idleState;
}

bool isLineTerminator(String chr) {
  List<int> codeUnits = chr.codeUnits;

  if (chr == Token.EOF ||
      // NOTE: This is a secondary test for EOF.
      (codeUnits.isNotEmpty && codeUnits[0] == 0) ||
      (codeUnits.isNotEmpty && codeUnits[0] == 59) ||
      (codeUnits.isNotEmpty && codeUnits[0] == 10) ||
      (codeUnits.isNotEmpty && codeUnits[0] == 13) ||
      (codeUnits.length == 2 && codeUnits[0] == 13 && codeUnits[1] == 10)) {
    return true;
  }

  return false;
}

bool isWhitespace(String chr) => chr.trim().isEmpty;
