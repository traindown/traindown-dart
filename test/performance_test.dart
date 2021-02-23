import "package:test/test.dart";

import "package:traindown/src/performance.dart";

void main() {
  group('addKVP', () {
    Performance performance;

    setUp(() => performance = Performance());

    group('with a non-unit kvp', () {
      test('it adds a kvp', () {
        performance.addKVP('your', 'mom');
        expect(performance.metadata.kvps.isNotEmpty, equals(true));
        expect(performance.metadata.kvps['your'], equals('mom'));
      });

      test('it sets a kvp', () {
        performance.setKVP('your', 'mom');
        expect(performance.metadata.kvps.isNotEmpty, equals(true));
        expect(performance.metadata.kvps['your'], equals('mom'));
      });
    });

    group('setting the unit', () {
      test('it sets and marks touched', () {
        performance.unit = 'your mom';
        expect(performance.metadata.kvps.isEmpty, equals(true));
        expect(performance.unit, equals('your mom'));
      });
    });
  });

  group('successfulReps', () {
    test('no failures', () {
      Performance performance = Performance(reps: 10);
      expect(performance.successfulReps, equals(10));
    });

    test('reps greater than failures', () {
      Performance performance = Performance(reps: 10, fails: 5);
      expect(performance.successfulReps, equals(5));
    });

    test('failures equal to reps', () {
      Performance performance = Performance(reps: 5, fails: 5);
      expect(performance.successfulReps, equals(0));
    });
  });

  group('volume', () {
    test('computes volume as successfulReps * load * sets', () {
      Performance performance =
          Performance(reps: 10, fails: 5, sets: 5, load: 4);
      expect(performance.volume, equals(100));

      performance = Performance(reps: 5, fails: 5, sets: 5, load: 4);
      expect(performance.volume, equals(0));
    });
  });

  group('toString', () {
    test('builds summary string', () {
      Performance performance = Performance(reps: 10);
      expect(performance.toString(),
          equals('unknown load unknown unit for 1.0 sets of 10.0 reps.'));
    });
  });
}
