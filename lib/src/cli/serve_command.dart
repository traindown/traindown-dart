import "package:shelf/shelf.dart";
import "package:shelf/shelf_io.dart";

import "dart:io";

import "package:args/args.dart";
import "package:args/command_runner.dart";

import "package:traindown/src/parser.dart";
import "package:traindown/src/presenters/html_presenter.dart";
import "package:traindown/src/scanner.dart";

final String style =
    "*,*:after,*:before{box-sizing:inherit}html{box-sizing:border-box;font-size:62.5%}body{margin:1em auto;max-width:960px;color:#606c76;font-family:'Roboto','Helvetica Neue','Helvetica','Arial',sans-serif;font-size:1.6em;font-weight:300;letter-spacing:.01em;line-height:1.6;padding:.5rem}hr{border:0;border-top:.1rem solid #f4f5f6;margin:3rem 0}hr.flat-top{margin-top:1rem}h1,h2,h3,h4,h5,h6{font-weight:300;letter-spacing:-.1rem;margin-bottom:2rem;margin-top:1rem}h1{font-size:3rem;line-height:1;}h2{font-size:2rem;line-height:1.25}h3{font-size:1.5rem;line-height:1.3}h4{font-size:1rem} table{border-collapse:collapse;border-spacing:0;empty-cells:show;border:1px solid #cbcbcb;width:100%;}table td,table th{border-left:1px solid #cbcbcb;border-width:0 0 0 1px;font-size:inherit;margin:0;overflow:visible;padding:.5em 1em}table thead{background-color:#fafafa;text-align:left;vertical-align:bottom}table td, table th{background-color:transparent;border-bottom:1px solid #cbcbcb}table tbody>tr:last-child>td{border-bottom-width:0}table tbody>tr.highlighted{background-color:#fafafa;}.metadata,.notes{font-size:70%}";

class ServeCommand extends Command {
  final name = "serve";
  final description = "View your Traindown files in a browser.";

  Directory _directory;

  ServeCommand() {
    argParser.addOption("path",
        abbr: "p",
        help:
            "The path where your Traindown files live. Default is current directory.",
        valueHelp: "path");
  }

  void _ensureDirectory(ArgResults result) {
    if (result.options.contains("path")) {
      _directory = Directory(result["path"]);
    } else {
      _directory = Directory.current;
    }

    if (!_directory.existsSync()) {
      print("Directory does not exist. Please double check your input.");
      exit(64);
    }
  }

  void run() {
    _ensureDirectory(argResults);

    Handler handler =
        const Pipeline().addMiddleware(_headers).addHandler(_router);

    serve(handler, "localhost", 1337).then((server) {
      print(
          "Viewing your files from $_directory at http://${server.address.host}:${server.port}\nCtrl C to Stop");
    });
  }

  Middleware _headers = createMiddleware(
      responseHandler: (Response response) =>
          response.change(headers: {"Content-Type": "text/html"}));

  Response _router(Request request) {
    if (request.url.hasEmptyPath) {
      return _handleIndex(request);
    } else {
      return _handleShow(request);
    }
  }

  Response _handleIndex(Request request) {
    String header = "<h1>Traindown files</h1>";
    String listItems = _directory
        .listSync(recursive: true, followLinks: false)
        .where((FileSystemEntity entity) => entity.path.endsWith("traindown"))
        .map((FileSystemEntity entity) {
      String path = entity.path.split("/").last;
      path = path.split(".traindown").first;
      return "<li><a href='$path'>$path</a></li>";
    }).join();

    if (listItems.isEmpty) {
      listItems =
          "<li>Hmmm...this directory doesn't appear to have any Traindown files</li>";
    }

    return Response.ok("$_styles$header<ul>$listItems</ul>");
  }

  Response _handleShow(Request request) {
    FileSystemEntity file = _directory
        .listSync(recursive: true, followLinks: false)
        .where((FileSystemEntity entity) => entity.path.endsWith("traindown"))
        .singleWhere((FileSystemEntity entity) =>
            entity.path.contains(request.url.toString()));

    String response = "$_styles<div><a href='/'>Back to list</a></div>";

    if (!file.existsSync()) {
      response +=
          "<p>Can't seem to locate this file. Are you sure you have the right URL?</p>";
    } else {
      Scanner scanner = Scanner(filename: file.path);
      Parser tParser = Parser(scanner);
      tParser.parse();
      HtmlPresenter presenter = HtmlPresenter(tParser);
      response += presenter.call();
    }

    return Response.ok(response);
  }

  String get _styles => "<style>$style</style>";
}
