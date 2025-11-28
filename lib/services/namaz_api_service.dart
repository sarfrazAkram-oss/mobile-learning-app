import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

class NamazApiService {
  /// Fetches today's prayer timings for the given coordinates (defaults to Karachi)
  /// and returns the DateTime of the next upcoming prayer in local time.
  ///
  /// If no prayer remains for today, returns tomorrow's Fajr time.
  Future<DateTime> fetchNextPrayerTime({
    double lat = 24.8607,
    double lon = 67.0011,
  }) async {
    final now = DateTime.now();
    final url = Uri.parse(
      'https://api.aladhan.com/v1/timings/${now.millisecondsSinceEpoch}?latitude=$lat&longitude=$lon&method=2',
    );

    final response = await http.get(url);
    if (response.statusCode != 200) {
      throw Exception('Failed to fetch prayer timings: ${response.statusCode}');
    }

    final body = json.decode(response.body);
    if (body == null || body['code'] != 200 || body['data'] == null) {
      throw Exception('Unexpected response from timings API');
    }

    final timings = body['data']['timings'] as Map<String, dynamic>;

    // Map of prayer keys we care about in order.
    final prayerKeys = ['Fajr', 'Sunrise', 'Dhuhr', 'Asr', 'Maghrib', 'Isha'];

    late DateTime next;
    bool found = false;
    for (final key in prayerKeys) {
      final timeStr = (timings[key] ?? '').toString();
      if (timeStr.isEmpty) continue;

      // timings may contain extra annotations like "05:10 (PST)"; strip to HH:mm
      final hhmm = timeStr.split(' ').first;
      final parts = hhmm.split(':');
      if (parts.length < 2) continue;

      final hour = int.tryParse(parts[0]) ?? 0;
      final minute = int.tryParse(parts[1]) ?? 0;

      final candidate = DateTime(now.year, now.month, now.day, hour, minute);
      if (candidate.isAfter(now)) {
        next = candidate;
        found = true;
        break;
      }
    }

    // If no next prayer found today, return tomorrow's Fajr by requesting next day's timings
    if (!found) {
      final tomorrow = now.add(const Duration(days: 1));
      final url2 = Uri.parse(
        'https://api.aladhan.com/v1/timings/${tomorrow.millisecondsSinceEpoch}?latitude=$lat&longitude=$lon&method=2',
      );
      final resp2 = await http.get(url2);
      if (resp2.statusCode == 200) {
        final body2 = json.decode(resp2.body);
        final timings2 = body2['data']['timings'] as Map<String, dynamic>;
        final fajrStr = (timings2['Fajr'] ?? '').toString().split(' ').first;
        final parts = fajrStr.split(':');
        final hour = int.tryParse(parts[0]) ?? 0;
        final minute = int.tryParse(parts[1]) ?? 0;
        next = DateTime(
          tomorrow.year,
          tomorrow.month,
          tomorrow.day,
          hour,
          minute,
        );
      } else {
        throw Exception(
          'Failed to fetch tomorrow timings: ${resp2.statusCode}',
        );
      }
    }

    return next;
  }

  static Future<List<Map<String, String>>> fetchNamazContent() async {
    const String apiUrl =
        'https://raw.githubusercontent.com/sarfrazdev/IslamicData/main/namaz_content.json'; // Replace with the actual API URL

    try {
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['namaz'] != null && data['namaz'].isNotEmpty) {
          return List<Map<String, String>>.from(data['namaz']);
        } else {
          return _loadLocalNamazContent();
        }
      } else {
        return _loadLocalNamazContent();
      }
    } catch (e) {
      return _loadLocalNamazContent();
    }
  }

  static Future<List<Map<String, String>>> _loadLocalNamazContent() async {
    final String jsonString = await rootBundle.loadString(
      'assets/namaz_content.json',
    );
    print("JSON loaded: $jsonString"); // Debug print to ensure JSON is loaded

    final Map<String, dynamic> jsonData = json.decode(jsonString);
    final List<dynamic> namazList = jsonData['namaz'];

    // Map each item to Map<String, String>
    final List<Map<String, String>> mappedNamazList = namazList.map((e) {
      return {
        'title': e['title']?.toString() ?? '',
        'text': e['text']?.toString() ?? '',
      };
    }).toList();

    print(
      "Mapped Namaz List: $mappedNamazList",
    ); // Debug print to verify mapping

    return mappedNamazList;
  }
}
