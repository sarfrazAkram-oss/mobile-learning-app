import 'package:flutter/material.dart';
import '../services/quran_api_service.dart';
import 'surah_detail_screen.dart';

class SurahListScreen extends StatefulWidget {
  const SurahListScreen({super.key});

  @override
  _SurahListScreenState createState() => _SurahListScreenState();
}

class _SurahListScreenState extends State<SurahListScreen> {
  List<dynamic> surahs = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    fetchSurahList();
  }

  Future<void> fetchSurahList() async {
    final apiService = QuranApiService();
    try {
      final data = await apiService.fetchSurahList();
      debugPrint('Raw Surah List JSON: ${data.toString()}');
      if (data.isNotEmpty) {
        debugPrint('First Surah: ${data[0].toString()}');
      }
      setState(() {
        surahs = data;
        loading = false;
      });
    } catch (e, st) {
      debugPrint('Error fetching Surah list: $e\n$st');
      setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Al Quran'),
        backgroundColor: Colors.green,
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : surahs.isEmpty
          ? const Center(child: Text('No Surahs found'))
          : ListView.builder(
              itemCount: surahs.length,
              itemBuilder: (context, index) {
                final surah = surahs[index];
                return Card(
                  elevation: 3,
                  margin: const EdgeInsets.all(8),
                  child: ListTile(
                    title: Text((surah['name'] ?? 'No Name').toString()),
                    subtitle: Text(
                      'Verses: ${(surah['ayah_count'] ?? 0).toString()}',
                    ),
                    trailing: Text((surah['number'] ?? '').toString()),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => SurahDetailScreen(
                            surahNumber: surah['number'] ?? 0,
                            surahName: surah['name'] ?? 'Surah',
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
    );
  }
}
