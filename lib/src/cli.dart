// import "dart:io";

import "package:args/args.dart";
import "package:traindown/src/parser.dart";
import "package:traindown/src/presenters.dart";
import "package:traindown/src/scanner.dart";

void main(List<String> arguments) {
  final parser = ArgParser()
    ..addFlag(
      "help",
      abbr: "h",
      defaultsTo: false,
      help: "Displays the handy dandy help, ahem, man page you are likely reading RIGHT NOW",
      negatable: false)
    ..addFlag(
      "verbose",
      abbr: "v",
      defaultsTo: false,
      help: "Logs literally everything to stdout",
      negatable: false)
    ..addOption(
      "format",
      abbr: "f",
      allowed: ["html", "json", "text"],
      defaultsTo: "text",
      help: "The output format you would like to see",
      valueHelp: "html|json|text")
    ..addOption(
      "output",
      abbr: "o",
      help: "File into which you would like to write the result. Default is to send to stdout.",
      valueHelp: "filename")
    ..addOption(
      "source",
      abbr: "s",
      help: "Traindown source file to be used instead of stdin",
      valueHelp: "filename");

  var results = parser.parse(arguments);

  bool verbose = results["verbose"];

  // TODO: Better man page
  if (results["help"]) { return print(parser.usage); }

  // TODO: Pull into class...
  if (verbose) { print("Initializing scanner..."); }

  Scanner scanner;
  if (results["source"] != null) {
    scanner = Scanner(filename: results["source"]);
  } else {
    scanner = Scanner(string: results.rest.join(" "));
  }

  var tParser = Parser(scanner);
  tParser.parse();

  ParserPresenter presenter;
  if (results["format"] == "html") {
    presenter = ConsolePresenter(tParser);
  } else if (results["format"] == "json") {
    presenter = JSONPresenter(tParser);
  } else {
    presenter = ConsolePresenter(tParser);
  }

  print(presenter.call());
}
