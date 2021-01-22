import "dart:io";

import "package:test/test.dart";

import "package:traindown/src/formatter.dart";
import "package:traindown/src/parser.dart";
import "package:traindown/src/token.dart";

class Expected {
  String desc;
  List<Token> tokens;
  String result;

  Expected(this.desc, this.tokens, this.result);
}

void main() {
  // TODO: Finish this.
  group("Atomic formatting", () {
    List<Expected> pairs = [
      Expected("Date / Time", [Token(TokenType.DateTime, "2020-05-20")],
          "@ 2020-05-20\r\n"),
    ];

    pairs.forEach((p) {
      test(p.desc, () {
        expect(format(p.tokens), equals(p.result));
      });
    });
  });

  group("Stress test", () {
    File file = File("./example/example.traindown");
    String src = file.readAsStringSync();

    Parser parser = Parser(src);
    print(format(parser.tokens()));
  });
}
