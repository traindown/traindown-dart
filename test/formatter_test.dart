import "dart:io";

import "package:test/test.dart";

import "package:traindown/src/formatter.dart";
import "package:traindown/src/parser.dart";

final String expected = """
@ 2020-01-01 1:23pm

# unit: lbs
# bw: 230
# session meta key 1: session meta "value" 1
# session meta key '2': session meta value 2
# 3rd session meta key: 3rd session meta value
* session note 1
* 2nd session note
* "Third" session note

movement 1:
  100
  101.1
  102

'2nd movement:
  # 2nd movement meta key 1: 2nd movement meta value 1
  # Movement 2 meta key 2: Movement 2 meta key 2
  * 2nd movement note 1
  * Movment 2 note 2
  201
  202 2r
  203 2s
  204 2r 2s
  205 2r 2f

Third movement:
  301
    * 301 note 1
    * Second 301 note
  302
    # 302 meta key 1: 302 meta value 1
    # Meta key 2 for 302: Meta value 2 for 302

+ '4th movement:
  # unit: 4th unit movement
  400.456
  401
    # unit: 401 unit
  bw
  bw+4

Fifth movement: 5r 5f 5s  500""";

void main() {
  test("Stress test", () {
    File file = File("./example/example.traindown");
    String src = file.readAsStringSync();

    // TODO: Use the system default line endings.
    Formatter formatter = Formatter(linebreaker: '\n');
    Parser parser = Parser(src);

    expect(expected, formatter.format(parser.tokens()));
  });
}
