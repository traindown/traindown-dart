import "../lib/src/parser.dart";
import "../lib/src/presenters.dart";
import "../lib/src/scanner.dart";

void main() {
  var scanner = Scanner("./test.traindown");
  var scanner1 = Scanner("./test1.traindown");

  var parser = Parser(scanner);
  var presenter = ConsolePresenter(parser);

  parser.parse();
  print(presenter.call());

  parser.scanner = scanner1;
  parser.parse();
  print(presenter.call());
}
