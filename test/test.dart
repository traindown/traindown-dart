import "package:traindown/src/parser.dart";
import "package:traindown/src/presenters.dart";
import "package:traindown/src/scanner.dart";

void main() {
  var scanner = Scanner(string: """
    @ 20191021
    # unit: lbs
    Squat: 500 550 2r 600 3r 3s""");
  var scanner1 = Scanner(filename: "./test.traindown");

  var parser = Parser(scanner);
  var presenter = ConsolePresenter(parser);

  parser.parse();
  print(presenter.call());

  print("\n\n---\n\n");

  parser.scanner = scanner1;
  parser.parse();
  print(presenter.call());
}
