import "package:traindown/src/parser.dart";
import "package:traindown/src/presenters.dart";
import "package:traindown/src/scanner.dart";

void main() {
  var scanner = Scanner(filename: "./test.traindown");
  var scanner1 = Scanner(filename: "./test1.traindown");
  var scanner2 = Scanner(string: """
    # Date: 20191021
    Squat: 500; 550 2r; 600 3r 3s;""");

  var parser = Parser(scanner);
  var presenter = ConsolePresenter(parser);

  parser.parse();
  print(parser.movements);
  print(presenter.call());

  parser.scanner = scanner1;
  parser.parse();
  print(presenter.call());

  parser.scanner = scanner2;
  parser.parse();
  print(presenter.call());

}
