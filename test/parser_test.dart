import 'package:test/test.dart';

import 'package:traindown/src/parser.dart';
import 'package:traindown/src/token.dart';

void main() {
  final String stressTest = """
    @ 1/1/2021 1:23pm

    # session meta key 1: session meta "value" 1
    # session meta key '2': session meta value 2
    # 3rd session meta key: 3rd session meta value

    * session note 1
    * 2nd session note
    * "Third" session note

    movement 1: 100 101.1; 102

    '2nd movement: 
      # 2nd movement meta key 1: 2nd movement meta value 1
      # Movement 2 meta key 2: Movement 2 meta key 2

      * 2nd movement note 1
      * Movment 2 note 2

      201
      202 2r
      203 2s
      204 2r 2s
      205 2f

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

    Fifth movement: 5r 5f 5s 500""";

  List<String> expected = [
    "[Date / Time] 1/1/2021 1:23pm",
    "[Metadata Key] session meta key 1",
    "[Metadata Value] session meta \"value\" 1",
    "[Metadata Key] session meta key '2'",
    "[Metadata Value] session meta value 2",
    "[Metadata Key] 3rd session meta key",
    "[Metadata Value] 3rd session meta value",
    "[Note] session note 1",
    "[Note] 2nd session note",
    "[Note] \"Third\" session note",
    "[Movement] movement 1",
    "[Load] 100",
    "[Load] 101.1",
    "[Load] 102",
    "[Movement] 2nd movement",
    "[Metadata Key] 2nd movement meta key 1",
    "[Metadata Value] 2nd movement meta value 1",
    "[Metadata Key] Movement 2 meta key 2",
    "[Metadata Value] Movement 2 meta key 2",
    "[Note] 2nd movement note 1",
    "[Note] Movment 2 note 2",
    "[Load] 201",
    "[Load] 202",
    "[Reps] 2",
    "[Load] 203",
    "[Sets] 2",
    "[Load] 204",
    "[Reps] 2",
    "[Sets] 2",
    "[Load] 205",
    "[Fails] 2",
    "[Movement] Third movement",
    "[Load] 301",
    "[Note] 301 note 1",
    "[Note] Second 301 note",
    "[Load] 302",
    "[Metadata Key] 302 meta key 1",
    "[Metadata Value] 302 meta value 1",
    "[Metadata Key] Meta key 2 for 302",
    "[Metadata Value] Meta value 2 for 302",
    "[Superset Movement] 4th movement",
    "[Metadata Key] unit",
    "[Metadata Value] 4th unit movement",
    "[Load] 400.456",
    "[Load] 401",
    "[Metadata Key] unit",
    "[Metadata Value] 401 unit",
    "[Load] bw",
    "[Load] bw+4",
    "[Movement] Fifth movement",
    "[Reps] 5",
    "[Fails] 5",
    "[Sets] 5",
    "[Load] 50",
  ];

  group('parse()', () {
    Parser parser = Parser(stressTest);

    test('Stress test', () {
      List<Token> tokens = parser.tokens();
      var tokenStrs = tokens.map((t) => t.toString());
      tokenStrs == expected;
    });
  });
}
