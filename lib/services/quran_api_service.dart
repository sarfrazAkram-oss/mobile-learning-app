import 'dart:convert';
import 'package:http/http.dart' as http;

class QuranApiService {
  final String baseUrl = 'https://api.alquran.cloud/v1';

  Future<List<Map<String, dynamic>>> fetchSurahList() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/surah'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body)['data'];
        return List<Map<String, dynamic>>.from(
          data.map(
            (surah) => {
              'name': surah['englishName'] ?? 'No Name',
              'ayah_count': surah['numberOfAyahs'] ?? 0,
              'number': surah['number'] ?? 0,
            },
          ),
        );
      } else {
        throw Exception('Failed to load Surah list: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching Surah list: $e');
    }
  }

  Future<List<Map<String, dynamic>>> fetchSurahDetails(int surahNumber) async {
    try {
      // Request the Uthmani edition to get full Arabic ayahs
      final response = await http.get(
        Uri.parse('$baseUrl/surah/$surahNumber/quran-uthmani'),
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body)['data']['ayahs'];
        return List<Map<String, dynamic>>.from(
          data.map(
            (ayah) => {
              'text': ayah['text'] ?? '',
              'number': ayah['number'] ?? 0,
            },
          ),
        );
      } else {
        throw Exception('Failed to load Surah details: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching Surah details: $e');
    }
  }
}

void main() async {
  final apiService = QuranApiService();

  try {
    final surahList = await apiService.fetchSurahList();
    print('Surah List: $surahList');

    final surahDetails = await apiService.fetchSurahDetails(1);
    print('Surah Details: $surahDetails');
  } catch (e) {
    print('Error: $e');
  }
}
