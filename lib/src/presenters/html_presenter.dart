import "package:traindown/src/parser.dart";
import "package:traindown/src/presenter.dart";

final String style =
    "html{line-height:1.15;-webkit-text-size-adjust:100%}body{margin:0}main{display:block}h1{font-size:2em;margin:.67em 0}hr{box-sizing:content-box;height:0;overflow:visible}pre{font-family:monospace,monospace;font-size:1em}a{background-color:transparent}abbr[title]{border-bottom:none;text-decoration:underline;text-decoration:underline dotted}b,strong{font-weight:bolder}code,kbd,samp{font-family:monospace,monospace;font-size:1em}small{font-size:80%}sub,sup{font-size:75%;line-height:0;position:relative;vertical-align:baseline}sub{bottom:-.25em}sup{top:-.5em}img{border-style:none}button,input,optgroup,select,textarea{font-family:inherit;font-size:100%;line-height:1.15;margin:0}button,input{overflow:visible}button,select{text-transform:none}[type=button],[type=reset],[type=submit],button{-webkit-appearance:button}[type=button]::-moz-focus-inner,[type=reset]::-moz-focus-inner,[type=submit]::-moz-focus-inner,button::-moz-focus-inner{border-style:none;padding:0}[type=button]:-moz-focusring,[type=reset]:-moz-focusring,[type=submit]:-moz-focusring,button:-moz-focusring{outline:1px dotted ButtonText}fieldset{padding:.35em .75em .625em}legend{box-sizing:border-box;color:inherit;display:table;max-width:100%;padding:0;white-space:normal}progress{vertical-align:baseline}textarea{overflow:auto}[type=checkbox],[type=radio]{box-sizing:border-box;padding:0}[type=number]::-webkit-inner-spin-button,[type=number]::-webkit-outer-spin-button{height:auto}[type=search]{-webkit-appearance:textfield;outline-offset:-2px}[type=search]::-webkit-search-decoration{-webkit-appearance:none}::-webkit-file-upload-button{-webkit-appearance:button;font:inherit}details{display:block}summary{display:list-item}template{display:none}[hidden]{display:none} *,*:after,*:before{box-sizing:inherit}html{box-sizing:border-box;font-size:62.5%}body{margin:1em auto;max-width:960px;color:#606c76;font-family:'Roboto','Helvetica Neue','Helvetica','Arial',sans-serif;font-size:1.6em;font-weight:300;letter-spacing:.01em;line-height:1.6;padding:.5rem}hr{border:0;border-top:.1rem solid #f4f5f6;margin:3rem 0}hr.flat-top{margin-top:1rem}pre{background:#f4f5f6;border-left:.3rem solid #666;padding:1.25rem 1.5rem;overflow-y:hidden;white-space:pre-wrap}pre.wrong{border-left:.3rem solid red;margin-bottom:0}h1,h2,h3,h4,h5,h6{font-weight:300;letter-spacing:-.1rem;margin-bottom:2rem;margin-top:0}h1{font-size:4.6rem;line-height:1;margin-bottom:.5rem}h2{font-size:3.6rem;line-height:1.25}h3{font-size:2.8rem;line-height:1.3}h4{font-size:2rem}";

class HtmlPresenter extends Presenter {
  HtmlPresenter(Parser parser) : super(parser);

  @override
  StringBuffer initString() {
    StringBuffer string = StringBuffer();

    string.write("<style>$style</style>");
    string.write("<h1>Training Session on $occurred</h1>");

    return string;
  }

  @override
  void writeMetadata() {
    result.write("<h2>Metadata</h2>");

    if (kvps.entries.isEmpty) {
      result.write("<strong>No metadata for this session.</strong>");
      return;
    }

    result.write("<dl>");

    for (var mapEntry in kvps.entries) {
      result.write("<dt>${mapEntry.key}</dt><dd>${mapEntry.value}</dd>");
    }

    result.write("</dl>");
  }

  @override
  void writeMovements() {
    result.write("<h2>Movements</h2>");
    result.write(
        "<table><thead><tr><th>Movement</th><th>Load</th><th>Unit</th><th>Sets</th><th>Reps</th></tr></thead><tbody>");

    for (var movement in movements) {
      result.write("<tr><td colspan=\"5\">${movement.name}</td></tr>");
      for (var p in movement.performances) {
        result.write(
            "<tr><td></td><td>${p.load}</td><td>${p.unit}</td><td>${p.repeat}</td><td>${p.reps}</td></tr>");
      }
    }

    result.write("</table>");
  }

  @override
  void writeNotes() {
    result.write("<h2>Notes</h2>");

    if (notes.isEmpty) {
      result.write("<strong>No notes for this session.</strong>");
      return;
    }

    result.write("<ul>");

    for (var note in notes) {
      result.write("<li>$note</li>");
    }

    result.write("</ul>");
  }
}
