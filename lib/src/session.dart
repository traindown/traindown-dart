import 'package:traindown/src/metadata.dart';
import 'package:traindown/src/movement.dart';
import 'package:traindown/src/performance.dart';
import 'package:traindown/src/token.dart';

class Session extends Metadatable {
  List<Movement> movements = [];
  DateTime occurred = DateTime.now();
  List<Token> tokens = [];

  String _currentMeta;
  Movement _currentMovement;
  Performance _currentPerformance;
  Metadatable _currentTarget;

  Session(this.tokens) {
    _currentTarget = this;
    _build();
  }

  @override
  String toString() {
    String mvStr = movements.map((m) => "$m").join("\n");

    return "Session occurred $occurred\n\n$mvStr";
  }

  void _build() {
    tokens.forEach((t) {
      switch (t.tokenType) {
        case TokenType.DateTime:
          occurred = DateTime.tryParse(t.literal);
          break;
        case TokenType.Fail:
          _currentPerformance ??= _newPerformance();
          _currentPerformance.fails = double.parse(t.literal);
          break;
        case TokenType.Load:
          _currentPerformance ??= _newPerformance();

          if (_currentPerformance?.load != null) {
            _currentMovement.performances.add(_currentPerformance);
            _currentPerformance = _newPerformance();
          }

          _currentPerformance.load = double.parse(t.literal);
          _currentTarget = _currentPerformance;
          break;
        case TokenType.MetaKey:
          _currentMeta = t.literal;
          break;
        case TokenType.MetaValue:
          _currentTarget.addKVP(_currentMeta, t.literal);
          _currentMeta = null;
          break;
        case TokenType.Movement:
        case TokenType.SupersetMovement:
          if (_currentMovement != null) {
            movements.add(_currentMovement);
          }
          _currentMovement =
              Movement(t.literal, t.tokenType == TokenType.SupersetMovement);
          _currentTarget = _currentMovement;
          break;
        case TokenType.Note:
          _currentTarget.addNote(t.literal);
          break;
        case TokenType.Rep:
          _currentPerformance ??= _newPerformance();
          _currentPerformance.reps = double.parse(t.literal);
          break;
        case TokenType.Set:
          _currentPerformance ??= _newPerformance();
          _currentPerformance.sets = double.parse(t.literal);
          break;
      }
    });

    if (_currentPerformance?.load != null) {
      _currentMovement.performances.add(_currentPerformance);
    }

    if (_currentMovement != null) {
      movements.add(_currentMovement);
    }
  }

  Performance _newPerformance() {
    String unit = 'unknown unit';
    for (Metadata scope in [
      _currentMovement?.metadata ?? Metadata(),
      metadata
    ]) {
      for (String unitKeyword in Performance.unitKeywords) {
        if (scope.kvps.containsKey(unitKeyword)) {
          unit = scope.kvps[unitKeyword];
          break;
        }
      }
      if (unit != 'unknown unit') break;
    }

    return Performance(unit: unit);
  }
}
