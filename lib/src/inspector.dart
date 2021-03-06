import 'package:traindown/src/formatter.dart';
import 'package:traindown/src/metadata.dart';
import 'package:traindown/src/movement.dart';
import 'package:traindown/src/performance.dart';
import 'package:traindown/src/session.dart';

/// A search result that contains a DateTime and a Movement.
class MovementSearchResult {
  DateTime occurred;
  Movement movement;
  MovementSearchResult(this.occurred, this.movement);
}

/// Scope levels useful for querying
enum TraindownScope { session, movement, performance }

/// Inspector provides tools for analyzing Sessions.
class Inspector {
  List<Session> sessions;

  Inspector(this.sessions) {
    sessions.sort((a, b) => b.occurred.compareTo(a.occurred));
  }

  /// Stack rank of scopes in terms of depth priority.
  static const Map<TraindownScope, int> ScopePriority = {
    TraindownScope.session: 0,
    TraindownScope.movement: 1,
    TraindownScope.performance: 2
  };

  /// Export all Sessions as a single Traindown string. Good for dumping
  /// and sharing.
  ///
  /// For details on the optional parameters, see Formatter.
  String export(
      {String indenter = '  ',
      String linebreaker = '\r\n',
      String spacer = ' '}) {
    Formatter formatter =
        Formatter(indenter: indenter, linebreaker: linebreaker, spacer: spacer);
    StringBuffer buffer = StringBuffer();
    sessions.forEach((s) => buffer
        .write('${formatter.format(s.tokens)}${formatter.linebreaker * 2}'));
    return buffer.toString().trim();
  }

  /// Map keyed by string that contains all seen values of the given key.
  Map<String, Set<String>> metadataByKey(
      [TraindownScope scope = TraindownScope.session]) {
    Map<String, Set<String>> result = {};

    for (Session session in sessions) {
      Metadata metadata = session.metadata;
      for (String key in metadata.kvps.keys) {
        result[key] ??= <String>{};
        result[key]!.add(metadata.kvps[key]!);
      }

      if (ScopePriority[scope]! > ScopePriority[TraindownScope.session]!) {
        for (Movement movement in session.movements) {
          metadata = movement.metadata;
          for (String key in metadata.kvps.keys) {
            result[key] ??= <String>{};
            result[key]!.add(metadata.kvps[key]!);
          }

          if (ScopePriority[scope]! > ScopePriority[TraindownScope.movement]!) {
            for (Performance performance in movement.performances) {
              metadata = performance.metadata;
              for (String key in metadata.kvps.keys) {
                result[key] ??= <String>{};
                result[key]!.add(metadata.kvps[key]!);
              }
            }
          }
        }
      }
    }

    return result;
  }

  /// List of unique Movement names in the Sessions.
  List<String> get movementNames => sessions
      .expand((s) => s.movements.map((m) => m.name.toLowerCase()))
      .toSet()
      .toList();

  /// Fetch all occurrances of a Movement as queried by a fuzzy name match.
  List<MovementSearchResult> movementOccurances(String movementName) {
    List<MovementSearchResult> result = [];

    for (Session session in sessions) {
      session.movements
          .where(
              (m) => m.name.toLowerCase().contains(movementName.toLowerCase()))
          .forEach(
              (m) => result.add(MovementSearchResult(session.occurred, m)));
    }

    return result;
  }

  /// List of Sessions matching the search criteria.
  /// [metaLike] will match against all key value pairs provided in a case
  /// insensitve manner.
  // TODO: Add date filters
  List<Session> sessionQuery({Map<String, String> metaLike = const {}}) {
    List<Session> result = sessions;

    if (metaLike.isNotEmpty) {
      metaLike = metaLike.map((k, v) => MapEntry(k.toLowerCase(), v));
      result = result.where((s) {
        if (s.kvps.isEmpty) return false;
        Map<String, String> lowerMeta =
            s.kvps.map((k, v) => MapEntry(k.toLowerCase(), v));

        bool match = false;
        for (String key in lowerMeta.keys) {
          if (match) break;
          if (!metaLike.keys.contains(key)) continue;

          match = (metaLike[key] ?? "NOPE").toLowerCase() ==
              (lowerMeta[key] ?? "YUP").toLowerCase();
        }

        return match;
      }).toList();
    }

    return result;
  }
}
