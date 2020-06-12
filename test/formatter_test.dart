import "package:test/test.dart";

import "package:traindown/src/formatter.dart";

void main() {
  group("Constructor", () {
    test("No args causes an exception", () {
      try {
        Formatter(null);
      } catch (e) {
        expect(e, "Needs a scanner, dummy");
        return;
      }
      throw "Should have failed init";
    });
  });

  group("format()", () {
    test("With a date missing a space after the operator", () {
      Formatter formatter = Formatter.for_string("@2020-05-20");
      expect(formatter.format(), equals("@ 2020-05-20"));
    });

    test("With a somewhat complex string", () {
      String test =
          "@ 2020-05-20 # session meta: true * Session note.\nSquat: # movement meta: true * Movement note.\n500 10r # performance meta: true * Performance note. 600 2r 700 Pulldowns: 200 10r";
      String result =
          '@ 2020-05-20\r\n# session meta: true\r\n* Session note.\r\n\r\nSquat:\r\n  # movement meta: true\r\n  * Movement note.\r\n  500 10r\r\n    # performance meta: true\r\n    * Performance note.\r\n  600 2r\r\n  700\r\nPulldowns:\r\n  200 10r';
      Formatter formatter = Formatter.for_string(test);
      expect(formatter.format(), equals(result));
    });

    test("With an identified pathological string stripping colons", () {
      String test =
          "@2020-06-10\n# unit: lbs\nSquat: 500 10r 4s\n+ Pullover: 100 10r 4s";
      String result =
          "@ 2020-06-10\r\n# unit: lbs\r\n\r\nSquat:\r\n  500 10r 4s\r\n\r\n+ Pullover:\r\n  100 10r 4s";
      Formatter formatter = Formatter.for_string(test);
      expect(formatter.format(), equals(result));
    });

    test("With another identified pathological string stripping colons", () {
      String test =
          "@2020-06-10\n# unit: lbs\nSquat: 500 10r 4s * Note\nPullover: 100 10r 4s";
      String result =
          "@ 2020-06-10\r\n# unit: lbs\r\n\r\nSquat:\r\n  500 10r 4s\r\n    * Note\r\n\r\nPullover:\r\n  100 10r 4s";
      Formatter formatter = Formatter.for_string(test);
      expect(formatter.format(), equals(result));
    });

    test("With a string known to produce too many linebreaks", () {
      String test =
          "@2020-06-12\n# unit: lbs\nSquat: 500 10r 4s\n 600 5r\n 700";
      String result =
          "@ 2020-06-12\r\n# unit: lbs\r\n\r\nSquat:\r\n  500 10r 4s\r\n  600 5r\r\n  700";
      Formatter formatter = Formatter.for_string(test);
      expect(formatter.format(), equals(result));
    });
  });
}
