import 'package:flutter/material.dart';
import '../services/quran_api_service.dart';

class SurahDetailScreen extends StatefulWidget {
  final int surahNumber;
  final String surahName;

  const SurahDetailScreen({
    super.key,
    required this.surahNumber,
    required this.surahName,
  });

  @override
  _SurahDetailScreenState createState() => _SurahDetailScreenState();
}

class _SurahDetailScreenState extends State<SurahDetailScreen> {
  List<dynamic> verses = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    fetchSurahDetails();
  }

  Future<void> fetchSurahDetails() async {
    final apiService = QuranApiService();
    try {
      final data = await apiService.fetchSurahDetails(widget.surahNumber);
      debugPrint('Raw Surah Details JSON: ${data.toString()}');
      if (data.isNotEmpty) {
        debugPrint('First 2 Verses: ${data.take(2).toList().toString()}');
      }
      setState(() {
        verses = data;
        loading = false;
      });
    } catch (e, st) {
      debugPrint('Error fetching Surah details: $e\n$st');
      setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.surahName),
        backgroundColor: Colors.green,
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : verses.isEmpty
          ? const Center(child: Text('No verses found'))
          : ListView.builder(
              itemCount: verses.length,
              itemBuilder: (context, index) {
                final verse = verses[index];
                final verseText =
                    (verse['text'] ??
                            verse['text_uthmani'] ??
                            verse['arab'] ??
                            verse['verse'] ??
                            '')
                        .toString();
                return Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        verseText,
                        textAlign: TextAlign.right,
                        style: const TextStyle(
                          fontSize: 24,
                          fontFamily: 'Amiri',
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Ayah ${(verse['number'] ?? '').toString()}',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                      const Divider(),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
