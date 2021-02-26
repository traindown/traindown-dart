import 'package:test/test.dart';

import 'package:traindown/src/token.dart';

void main() {
  group('Tokens and their Strings', () {
    test('They align', () {
      TokenType.values.forEach((tt) {
        String label = Token.StringTokenType[tt];
        expect(Token.TokenTypeString[label], equals(tt));
      });
    });
  });

  group('tokensFromString', () {
    test('Basic functionality', () {
      String example =
          '[Date / Time] 2020-01-01 1:23pm, [Metadata Key] unit, [Metadata Value] lbs';
      List<Token> tokens = Token.tokensFromString(example);
      expect(tokens[0], equals(Token(TokenType.DateTime, '2020-01-01 1:23pm')));
      expect(tokens[1], equals(Token(TokenType.MetaKey, 'unit')));
      expect(tokens[2], equals(Token(TokenType.MetaValue, 'lbs')));
    });
  });
}
