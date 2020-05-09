import "dart:io";

import "package:args/command_runner.dart";

import "package:traindown/src/parser.dart";
import "package:traindown/src/presenter.dart";
import "package:traindown/src/presenters/console_presenter.dart";
import "package:traindown/src/presenters/html_presenter.dart";
import "package:traindown/src/presenters/json_presenter.dart";
import "package:traindown/src/scanner.dart";

class ParseCommand extends Command {
  final name = "parse";
  final description = "Parse Traindown files and output the result.";

  ParseCommand() {
    argParser.addOption("format",
        abbr: "f",
        allowed: ["html", "json", "text"],
        defaultsTo: "text",
        help: "The output format you would like to see",
        valueHelp: "html|json|text");

    argParser.addOption("output",
        abbr: "o",
        help:
            "File into which you would like to write the result if you can't just pipe it. Default is to send to stdout.",
        valueHelp: "filename");

    argParser.addOption("source",
        abbr: "s",
        help: "Traindown source file to be used instead of stdin",
        valueHelp: "filename");
  }

  void run() {
    Scanner scanner;
    try {
      if (argResults["source"] != null) {
        scanner = Scanner(filename: argResults["source"]);
      } else {
        scanner = Scanner(string: argResults.rest.join(" "));
      }
    } catch (FileSystemException) {
      return stderr.write(
          "Traindown file does not exist. Are you sure ${argResults["source"]} is there?");
    }

    Parser tParser = Parser(scanner);
    tParser.parse();

    Presenter presenter;
    if (argResults["format"] == "html") {
      presenter = HtmlPresenter(tParser);
    } else if (argResults["format"] == "json") {
      presenter = JsonPresenter(tParser);
    } else {
      presenter = ConsolePresenter(tParser);
    }

    String output = presenter.call();

    if (argResults["output"] == null) {
      stdout.write(output);
    } else {
      File(argResults["output"])
          .writeAsStringSync(output, mode: FileMode.write);
    }
  }
}
