import "package:traindown/src/token.dart";

/// VCR is a stack based history of the characters previously seen by the
/// Lexer. It allows for features like rewind.
class VCR {
  List<String> _stack = [];

  void clear() => _stack = [];

  String pop() {
    if (_stack.isEmpty) {
      return Token.EOF;
    }

    return _stack.removeLast();
  }

  void push(String chr) => _stack = [chr] + _stack;
}
