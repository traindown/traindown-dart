import 'package:traindown/src/metadata.dart';
import 'package:traindown/src/movement.dart';
import 'package:traindown/src/performance.dart';
import 'package:traindown/src/token.dart';

/// Session represents a single instance of training. It contains data on
/// what was performed as well as notes and metadata.
class Session extends Metadatable {
  late List<Movement> movements = [];
  late DateTime occurred = DateTime.now();
  late List<Token> tokens = [];

  String? _currentMeta;
  Movement? _currentMovement;
  Performance? _currentPerformance;
  Metadatable? _currentTarget;

  /// Useful to set as a config option in your app.
  double defaultBW;

  Session(this.tokens,
      {this.defaultBW = 100, String unit = Metadata.unknownUnit}) {
    _currentTarget = this;
    unit = unit;
    _build();
  }

  /// Adds a Movement and ensures the units align at all levels. Care taken in
  /// case a Movement is rehomed.
  void addMovement(Movement movement) {
    if (movement.unit == Metadata.unknownUnit) {
      movement.unit = unit;
      movement.performances.forEach((p) => p.unit = unit);
    }

    movements.add(movement);
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
          _handleDateTime(t.literal);
          break;
        case TokenType.Fail:
          _handlePerformanceAttribute('fails', t.literal);
          break;
        case TokenType.Load:
          _handleLoad(t.literal);
          break;
        case TokenType.MetaKey:
          _currentMeta = t.literal;
          break;
        case TokenType.MetaValue:
          _currentTarget!.setKVP(_currentMeta!, t.literal);
          _currentMeta = null;
          break;
        case TokenType.Movement:
        case TokenType.SupersetMovement:
          _handleMovement(t.literal, t.tokenType == TokenType.SupersetMovement);
          break;
        case TokenType.Note:
          _currentTarget!.addNote(t.literal);
          break;
        case TokenType.Rep:
          _handlePerformanceAttribute('reps', t.literal);
          break;
        case TokenType.Set:
          _handlePerformanceAttribute('sets', t.literal);
          break;
      }
    });

    // NOTE: Always remember to store the dangling Movement.
    _storeMovement();
  }

  void _handleDateTime(String literal) {
    DateTime? maybeOccurred = DateTime.tryParse(literal);
    if (maybeOccurred != null) occurred = maybeOccurred;
  }

  void _handleLoad(String literal) {
    _currentPerformance ??= Performance();

    if (_currentPerformance?.load != null) {
      _currentMovement!.addPerformance(_currentPerformance!);
      _currentPerformance = Performance();
    }

    if (literal.startsWith(RegExp(r'[bB][wW]'))) {
      double? baseAmount =
          double.tryParse(metadata.kvps[literal.substring(0, 2)]!);
      baseAmount ??= defaultBW;

      if (literal.length > 2) {
        String bwLoad = literal.substring(2);
        String dir = bwLoad.substring(0, 1);
        double ld = double.parse(bwLoad.substring(1));

        // NOTE: Do NOT use mirrors for this.
        if (dir == '+') {
          _currentPerformance!.load = baseAmount + ld;
        } else {
          _currentPerformance!.load = baseAmount - ld;
        }
      } else {
        _currentPerformance!.load = baseAmount;
      }
    } else {
      _currentPerformance!.load = double.parse(literal);
    }

    _currentTarget = _currentPerformance;
  }

  // NOTE: Make sure to add the Movement first and retain the pointer to
  // it such that the added Performance picks up the cascade of units, if
  // applicable.
  void _handleMovement(String literal, bool superset) {
    _storeMovement();
    _currentMovement = Movement(literal, superset: superset, unit: unit);
    _currentTarget = _currentMovement;
  }

  void _handlePerformanceAttribute(String attr, String literal) {
    _currentPerformance ??= Performance();
    // TODO: Enums
    if (attr == 'reps' && _currentPerformance!.reps == null) {
      _currentPerformance![attr] = double.parse(literal);
    } else if (_currentPerformance!.load != 0.0) {
      _currentPerformance![attr] += double.parse(literal);
    } else {
      _currentPerformance![attr] = double.parse(literal);
    }
  }

  // NOTE: Store the Movement first to pick up any unit that needs to be passed
  // on down, then store the Performance.
  void _storeMovement() {
    if (_currentMovement != null) {
      addMovement(_currentMovement!);

      if (_currentPerformance?.load != null) {
        _currentMovement!.addPerformance(_currentPerformance!);
        _currentPerformance = Performance();
      }
    }
  }
}
