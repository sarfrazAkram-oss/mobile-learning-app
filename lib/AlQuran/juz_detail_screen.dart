import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'surah_range_page.dart';

class JuzDetailScreen extends StatefulWidget {
  final int juzNumber;

  const JuzDetailScreen({super.key, required this.juzNumber});

  @override
  State<JuzDetailScreen> createState() => _JuzDetailScreenState();
}

class _JuzDetailScreenState extends State<JuzDetailScreen> {
  bool _isLoading = true;
  List<Map<String, dynamic>> _surahs = [];
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchJuzSurahs();
  }

  Future<void> _fetchJuzSurahs() async {
    try {
      setState(() => _isLoading = true);
      // Special-case mapping: ensure Juz 1 contains only Surah Al-Fatiha (1–7)
      if (widget.juzNumber == 1) {
        _surahs = [
          {
            'number': 1,
            'name': 'Al-Fatiha',
            'arabicName': 'الفاتحة',
            'startAyah': 1,
            'endAyah': 7,
          },
        ];
        setState(() => _isLoading = false);
        return;
      }

      // Default: fetch juz data and compute surah ranges
      final url = Uri.parse(
        'https://api.alquran.cloud/v1/juz/${widget.juzNumber}/quran-uthmani',
      );
      final response = await http.get(url).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        if (data['status'] == 'OK' && data['data'] != null) {
          final juzData = data['data'] as Map<String, dynamic>;
          final ayahs = juzData['ayahs'] as List<dynamic>?;

          if (ayahs != null && ayahs.isNotEmpty) {
            // Group ayahs by surah
            Map<int, Map<String, dynamic>> surahMap = {};
            for (var ayah in ayahs) {
              final surahNum = ayah['surah']['number'];
              final surahName = ayah['surah']['englishName'];
              final surahArabic = ayah['surah']['name'] ?? '';
              final ayahNum = ayah['numberInSurah'];

              if (!surahMap.containsKey(surahNum)) {
                surahMap[surahNum] = {
                  'number': surahNum,
                  'name': surahName,
                  'arabicName': surahArabic,
                  'ayahs': [],
                  'startAyah': ayahNum,
                  'endAyah': ayahNum,
                };
              }
              surahMap[surahNum]!['ayahs'].add(ayah);
              surahMap[surahNum]!['endAyah'] = ayahNum;
            }

            _surahs = surahMap.values.toList();
            _surahs.sort((a, b) => a['number'].compareTo(b['number']));
            // Only keep the first surah encountered in this Juz
            if (_surahs.isNotEmpty) {
              _surahs = [_surahs.first];
            }
            setState(() => _isLoading = false);
            return;
          }
        }
      }

      setState(() {
        _error = 'Failed to load Juz details';
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Error: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Juz ${widget.juzNumber}',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.black87,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Container(
        color: Colors.black87,
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation(Color(0xFFFFC107)),
                ),
              )
            : _error != null
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(_error!, style: const TextStyle(color: Colors.red)),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _fetchJuzSurahs,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFFC107),
                      ),
                      child: const Text(
                        'Retry',
                        style: TextStyle(color: Colors.black),
                      ),
                    ),
                  ],
                ),
              )
            : ListView.separated(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                itemCount: _surahs.length,
                separatorBuilder: (context, index) =>
                    Divider(color: Colors.grey[800], height: 1, thickness: 1),
                itemBuilder: (context, index) {
                  final surah = _surahs[index];
                  return InkWell(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => SurahRangePage(
                          surahNumber: surah['number'],
                          startAyah: surah['startAyah'],
                          endAyah: surah['endAyah'],
                          title: '${surah['name']}',
                          juzNumber: widget.juzNumber,
                        ),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: Row(
                        children: [
                          // Left: English name + small grey ayah range
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${surah['name']}',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFFFFC107),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Ayah ${surah['startAyah']}–${surah['endAyah']}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[500],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // Right: Arabic name
                          Text(
                            surah['arabicName'] ?? '',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                            textDirection: TextDirection.rtl,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }
}
