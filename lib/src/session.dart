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

  double defaultBW;

  Session(this.tokens, {this.defaultBW = 100}) {
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
          DateTime maybeOccurred = DateTime.tryParse(t.literal);
          if (maybeOccurred != null) {
            occurred = maybeOccurred;
          }
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

          if (t.literal.startsWith(RegExp(r'[bB][wW]'))) {
            double baseAmount =
                double.tryParse(metadata.kvps[t.literal.substring(0, 2)]);
            baseAmount ??= defaultBW;

            if (t.literal.length > 2) {
              String bwLoad = t.literal.substring(2);
              String dir = bwLoad.substring(0, 1);
              double ld = double.parse(bwLoad.substring(1));

              // NOTE: Do NOT use mirrors for this.
              if (dir == '+') {
                _currentPerformance.load = baseAmount + ld;
              } else {
                _currentPerformance.load = baseAmount - ld;
              }
            } else {
              _currentPerformance.load = baseAmount;
            }
          } else {
            _currentPerformance.load = double.parse(t.literal);
          }

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
          if (_currentPerformance?.load != null) {
            _currentMovement.performances.add(_currentPerformance);
            _currentPerformance = _newPerformance(skipMovementUnit: true);
          }
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

  Performance _newPerformance({bool skipMovementUnit = false}) {
    String unit = Performance.unknownUnit;

    List<Metadata> scopes = [metadata];

    if (!skipMovementUnit) {
      scopes.insert(0, _currentMovement?.metadata ?? Metadata());
    }

    for (Metadata scope in scopes) {
      for (String unitKeyword in Performance.unitKeywords) {
        if (scope.kvps.containsKey(unitKeyword)) {
          unit = scope.kvps[unitKeyword];
          break;
        }
      }

      if (unit != Performance.unknownUnit) break;
    }

    return Performance(unit: unit);
  }
}
