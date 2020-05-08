import "dart:io";
import "package:args/command_runner.dart";

import "package:traindown/src/cli/parse_command.dart";
import "package:traindown/src/cli/serve_command.dart";

final String title =
    "Traindown: A language to help athletes express their training.";

void main(List<String> arguments) {
  String border = "*" * (title.length + 4);
  CommandRunner runner =
      CommandRunner("traindown", "$border\n* $title *\n$border")
        ..addCommand(ParseCommand())
        ..addCommand(ServeCommand());

  runner.run(arguments).catchError((error) {
    if (error is! UsageException) throw error;
    print(error);
    exit(64);
  });
}
