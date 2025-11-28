// This file is no longer in use and can be safely removed.
// It was used for testing API responses from alquran.cloud.
// Consider removing this file if it is no longer needed.

import 'package:http/http.dart' as http;
import 'dart:convert';

void main() async {
  try {
    final url = Uri.parse('https://api.alquran.cloud/v1/juz/1/quran-uthmani');
    final response = await http.get(url).timeout(const Duration(seconds: 10));

    if (response.statusCode == 200) {
      final data = json.decode(response.body) as Map<String, dynamic>;
      print('Status: ${data['status']}');

      if (data['data'] != null) {
        final juzData = data['data'] as Map<String, dynamic>;
        final ayahs = juzData['ayahs'] as List<dynamic>?;

        if (ayahs != null) {
          print('Total Ayahs: ${ayahs.length}');
          print('\nFirst 3 Ayahs:');
          for (int i = 0; i < (ayahs.length > 3 ? 3 : ayahs.length); i++) {
            final ayah = ayahs[i] as Map<String, dynamic>;
            print('Ayah ${i + 1}:');
            print('  Text: ${ayah['text']}');
            print('  Surah: ${ayah['surah']?['number']}');
            print('  Ayah in Surah: ${ayah['numberInSurah']}');
          }
        }
      }
    } else {
      print('Failed: ${response.statusCode}');
      print(response.body);
    }
  } catch (e) {
    print('Error: $e');
  }
}
