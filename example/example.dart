import "package:traindown/src/formatter.dart";
import "package:traindown/src/parser.dart";
import "package:traindown/src/presenters/console_presenter.dart";
import "package:traindown/src/scanner.dart";

void main() {
  // Here is an example Traindown string that could be polished that is being
  // passed into a Scanner for formatting.
  Scanner scanner = Scanner(string: """
    @ 2019-10-21
    # unit:lbs
    Squat: 500 #rir:10 550 2r 600 3r 3s * Was hard""");

  // Let's see what our Formatter can do!
  Formatter formatter = Formatter(scanner);

  // There are no accidents, only happy mistakes.
  formatter.format();

  // Ah, much better.
  print(formatter.output);
  print("\n\n---\n\n");

  // So here is our Parser. This little thing is responsible for turning
  // Traindown into fantastic data. Let's try sending it our wonderfully
  // formatted Traindown.
  Parser parser = Parser(Scanner(string: formatter.output.toString()));

  // And look here--a presenter! Presenters paint a picture of our training
  // data. This one speaks console.
  ConsolePresenter presenter = ConsolePresenter(parser);

  // Let's now parse that string...
  parser.parse();

  // And show it to the world!
  print(presenter.call());

  print("\n\n---\n\n");

  // Here is a Scanner that is reading from a file.
  Scanner scanner1 = Scanner(filename: "./example.traindown");

  // Let's recycle our Parser. Only you can save the planet!
  parser.scanner = scanner1;

  // And parse...
  parser.parse();

  // to present!
  print(presenter.call());
}
