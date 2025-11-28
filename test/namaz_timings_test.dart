import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:my_project/screens/namaz_timings_screen.dart';
import 'package:audioplayers/audioplayers.dart';

void main() {
  group('Namaz Timings Screen Tests', () {
    testWidgets('Calculate next namaz correctly', (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(home: NamazTimingsScreen()));

      final timings = {
        'Tahajud': '01:07 AM',
        'Fajr': '05:10 AM',
        'Sunrise': '06:34 AM',
        'Dhuhr': '11:49 AM',
        'Asr': '02:42 PM',
        'Maghrib': '05:03 PM',
        'Isha': '06:22 PM',
      };

      await tester.runAsync(() async {
        final state = tester.state(find.byType(NamazTimingsScreen)) as dynamic;
        state.setNamazTimings(timings);

        state.calculateNextNamaz();

        expect(state.nextNamaz, 'Asr');
        expect(state.timeUntilNextNamaz, isNotNull);
      });
    });

    test('Play Azan sound', () async {
      final player = AudioPlayer();
      final url = 'https://example.com/default.mp3';

      expect(() async => await player.play(UrlSource(url)), returnsNormally);
    });
  });
}
