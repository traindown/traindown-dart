import 'package:test/test.dart';
import 'package:traindown/src/importer.dart';
import 'package:traindown/src/movement.dart';
import 'package:traindown/src/session.dart';

void main() {
  group('init', () {
    test('Basic init', () {
      String sessionsText =
          "@ 2020-01-01; Squat: 500; @ 2020-01-02; Press: 500;";
      Importer importer = Importer(sessionsText);

      expect(importer.sessions.length, 2);

      Session session1 = importer.sessions[0];
      expect(session1.movements.length, 1);

      Movement squat = session1.movements[0];
      expect(squat.name, "Squat");
      expect(squat.volume, 500);

      Session session2 = importer.sessions[1];
      expect(session2.movements.length, 1);

      Movement press = session2.movements[0];
      expect(press.name, "Press");
      expect(press.volume, 500);
    });
  });
}
