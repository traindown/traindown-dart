import "package:traindown/src/token.dart";

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
