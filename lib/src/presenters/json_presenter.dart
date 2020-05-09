import "dart:convert";

import "package:traindown/src/parser.dart";
import "package:traindown/src/presenter.dart";

class JsonPresenter extends Presenter {
  JsonPresenter(Parser parser) : super(parser);

  @override
  String call() {
    return jsonEncode(
        {"metadata": kvps, "movements": _movementsHash(), "notes": notes});
  }

  List _movementsHash() {
    return movements.fold(List(), (acc, movement) {
      acc.add({
        "name": movement.name,
        "performances": movement.performances.fold(List(), (pacc, performance) {
          pacc.add({
            "load": performance.load,
            "reps": performance.reps,
            "sets": performance.repeat,
            "unit": performance.unit
          });
          return pacc;
        })
      });
      return acc;
    });
  }
}
