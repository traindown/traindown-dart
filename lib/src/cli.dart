import "dart:io";

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
      help: "File into which you would like to write the result if you can't just pipe it. Default is to send to stdout.",
      valueHelp: "filename")
    ..addOption(
      "source",
      abbr: "s",
      help: "Traindown source file to be used instead of stdin",
      valueHelp: "filename");

  var results = parser.parse(arguments);

  // TODO: Better man page
  if (results["help"]) {
    stdout.write("** Traindown CLI v1.0 **\n\n");
    return stdout.write(parser.usage);
  }

  Scanner scanner;
  try {
    if (results["source"] != null) {
      scanner = Scanner(filename: results["source"]);
    } else {
      scanner = Scanner(string: results.rest.join(" "));
    }
  } catch(FileSystemException) {
    return stderr.write("Traindown file does not exist. Are you sure ${results["source"]} is there?");
  }

  var tParser = Parser(scanner);
  tParser.parse();

  ParserPresenter presenter;
  if (results["format"] == "html") {
    presenter = HTMLPresenter(tParser);
  } else if (results["format"] == "json") {
    presenter = JSONPresenter(tParser);
  } else {
    presenter = ConsolePresenter(tParser);
  }

  var output = presenter.call();

  if (results["output"] == null) {
    stdout.write(output);
  } else {
    File(results["output"]).writeAsStringSync(output, mode: FileMode.write);
  }
}
