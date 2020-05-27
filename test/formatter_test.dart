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
      formatter.format();
      expect(formatter.output.toString(), equals("@ 2020-05-20"));
    });

    test("With a somewhat complex string", () {
      String test = "@ 2020-05-20 Squat: 500 10r 600 2r 700 Pulldowns: 200 10r";
      String result =
          '@ 2020-05-20\r\nSquat:\r\n  500 10r\r\n  600 2r\r\n  700\r\nPulldowns:\r\n  200 10r';
      Formatter formatter = Formatter.for_string(test);
      formatter.format();
      expect(formatter.output.toString(), equals(result));
    });
  });
}
