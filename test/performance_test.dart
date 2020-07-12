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
    });

    group('with a unit kvp', () {
      Performance.unitKeywords.forEach((unitKey) {
        test('with $unitKey', () {
          performance.addKVP(unitKey, 'lbs');
          expect(performance.metadata.kvps.isEmpty, equals(true));
          expect(performance.unit, equals('lbs'));
        });
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
    test('computes volume as successfulReps * load * repeat', () {
      Performance performance =
          Performance(reps: 10, fails: 5, repeat: 5, load: 4);
      expect(performance.volume, equals(100));

      performance = Performance(reps: 5, fails: 5, repeat: 5, load: 4);
      expect(performance.volume, equals(0));
    });
  });

  group('toString', () {
    test('builds summary string', () {
      Performance performance = Performance(reps: 10);
      expect(performance.toString(),
          equals('1 unknown unit for 1 sets of 10 reps.'));
    });
  });

  group('wasTouched', () {
    test('no touch', () {
      Performance performance = Performance();
      expect(performance.wasTouched, equals(false));
    });

    test('touch fails', () {
      Performance performance = Performance();
      expect(performance.wasTouched, equals(false));
      performance.fails = 9000;
      expect(performance.wasTouched, equals(true));
    });

    test('touch load', () {
      Performance performance = Performance();
      expect(performance.wasTouched, equals(false));
      performance.load = 9000;
      expect(performance.wasTouched, equals(true));
    });

    test('touch repeat', () {
      Performance performance = Performance();
      expect(performance.wasTouched, equals(false));
      performance.repeat = 9000;
      expect(performance.wasTouched, equals(true));
    });

    test('touch reps', () {
      Performance performance = Performance();
      expect(performance.wasTouched, equals(false));
      performance.reps = 9000;
      expect(performance.wasTouched, equals(true));
    });

    test('touch unit', () {
      Performance performance = Performance();
      expect(performance.wasTouched, equals(false));
      performance.unit = '9000';
      expect(performance.wasTouched, equals(true));
    });
  });
}