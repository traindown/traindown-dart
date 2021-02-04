import 'package:traindown/src/formatter.dart';
import 'package:traindown/src/parser.dart';
import 'package:traindown/src/session.dart';

void main() {
  // Here is an example Traindown string that could be polished that is being
  // passed into a Parser for parsing.
  Parser parser = Parser("""
    @ 2019-10-21
    # unit:lbs
    Squat: 500 #rir:10; 550 2r; 600 3r 3s; * Was hard""");

  // The result of the parsing is a List<Token> that we can then hand off
  // to things like our Formatter.
  Formatter formatter = Formatter();

  // Let's see what our Formatter can do! Here we make a new one that uses
  // just the default output options.
  String formatted = formatter.format(parser.tokens());

  // Ah, much better.
  print('Enjoy this formatted Traindown!\n');
  print(formatted);
  print('\n\n---\n\n');

  // With the Formatter, you can alter the output to suit your specific needs.
  // Here is an example where we open up some breathing room.
  formatter.indenter = '    ';

  print('Very space. Much wow\n');
  print(formatter.format(parser.tokens()));
  print('\n\n---\n\n');

  // Once we parse, we typically want to do *stuff* with the data. That's where
  // Sessions come in. Let's take one for a test drive.

  Session session = Session(parser.tokens());

  print(session);
}
