import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  final String baseUrl = 'https://api.alquran.cloud/v1';

  /// Returns the raw API response as a Map, e.g. {"data": {"ayahs": [...]} }
  /// Request the `quran-uthmani` edition to ensure Uthmani script (full Arabic ayahs) is returned.
  Future<Map<String, dynamic>> getSurah(int surahNumber) async {
    final response = await http.get(
      Uri.parse('$baseUrl/surah/$surahNumber/quran-uthmani'),
    );
    if (response.statusCode == 200) {
      return json.decode(response.body) as Map<String, dynamic>;
    }
    throw Exception('Failed to load surah: ${response.statusCode}');
  }
}
