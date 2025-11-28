import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class SurahRangePage extends StatefulWidget {
  final int surahNumber;
  final int startAyah;
  final int endAyah;
  final String? title;
  final int? juzNumber;

  const SurahRangePage({
    super.key,
    required this.surahNumber,
    required this.startAyah,
    required this.endAyah,
    this.title,
    this.juzNumber,
  });

  @override
  State<SurahRangePage> createState() => _SurahRangePageState();
}

class _SurahRangePageState extends State<SurahRangePage> {
  bool _isLoading = true;
  String? _error;
  final List<Map<String, dynamic>> _pages = [];
  late PageController _controller;

  @override
  void initState() {
    super.initState();
    _controller = PageController();
    _fetchRange();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _fetchRange() async {
    try {
      setState(() => _isLoading = true);
      final url = Uri.parse(
        'https://api.alquran.cloud/v1/surah/${widget.surahNumber}/quran-uthmani',
      );
      final response = await http.get(url).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        if (data['status'] == 'OK' && data['data'] != null) {
          final surahData = data['data'] as Map<String, dynamic>;
          final ayahs = surahData['ayahs'] as List<dynamic>;

          final filtered = ayahs.where((a) {
            final num = a['numberInSurah'] as int;
            return num >= widget.startAyah && num <= widget.endAyah;
          }).toList();

          const int perPage = 10;
          for (int i = 0; i < filtered.length; i += perPage) {
            final int end = (i + perPage < filtered.length)
                ? i + perPage
                : filtered.length;
            final slice = filtered.sublist(i, end);
            final List<Map<String, dynamic>> lines = [];
            for (var ayah in slice) {
              final text = ayah['text'] ?? '';
              final ayahNum = ayah['numberInSurah'];
              lines.add({'text': text, 'ayah': ayahNum});
            }
            _pages.add({'lines': lines});
          }

          setState(() => _isLoading = false);
          return;
        }
      }

      setState(() {
        _error = 'Failed to load surah';
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
        title: Text(widget.title ?? 'Surah ${widget.surahNumber}'),
        backgroundColor: Colors.black87,
        elevation: 0,
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
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: _fetchRange,
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              )
            : Stack(
                children: [
                  PageView.builder(
                    controller: _controller,
                    itemCount: _pages.length,
                    itemBuilder: (context, index) {
                      final page = _pages[index];
                      final lines = (page['lines'] as List<dynamic>?) ?? [];
                      return SingleChildScrollView(
                        padding: const EdgeInsets.all(12),
                        child: Center(
                          child: Column(
                            children: [
                              Container(
                                constraints: const BoxConstraints(
                                  maxWidth: 760,
                                ),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 12,
                                ),
                                decoration: const BoxDecoration(
                                  color: Color(0xFF1E1E1E),
                                ),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 16,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFf6f0df),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: Colors.brown.shade800,
                                      width: 2,
                                    ),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                widget.title ??
                                                    'Surah ${widget.surahNumber}',
                                                style: const TextStyle(
                                                  color: Colors.black87,
                                                  fontWeight: FontWeight.w700,
                                                  fontSize: 16,
                                                ),
                                              ),
                                              if (widget.juzNumber != null)
                                                Text(
                                                  'Juz #${widget.juzNumber} ',
                                                  style: const TextStyle(
                                                    color: Colors.black54,
                                                    fontSize: 12,
                                                  ),
                                                ),
                                            ],
                                          ),
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.end,
                                            children: [
                                              Text(
                                                '${index + 1}',
                                                style: const TextStyle(
                                                  color: Colors.black87,
                                                  fontSize: 20,
                                                  fontWeight: FontWeight.w700,
                                                ),
                                              ),
                                              const SizedBox(height: 2),
                                              Text(
                                                'Page ${index + 1} of ${_pages.length}',
                                                style: const TextStyle(
                                                  color: Colors.black54,
                                                  fontSize: 12,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 12),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.stretch,
                                        children: lines.map<Widget>((ln) {
                                          final text = ln['text'] ?? '';
                                          final ayahNum = ln['ayah'];
                                          return Container(
                                            margin: const EdgeInsets.symmetric(
                                              vertical: 6,
                                            ),
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 12,
                                              vertical: 10,
                                            ),
                                            decoration: BoxDecoration(
                                              color: Colors.black,
                                              border: Border.all(
                                                color: Colors.white,
                                                width: 1.5,
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(4),
                                            ),
                                            child: Row(
                                              textDirection: TextDirection.rtl,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              children: [
                                                Expanded(
                                                  child: Text(
                                                    text,
                                                    textAlign: TextAlign.right,
                                                    style: const TextStyle(
                                                      fontSize: 26,
                                                      height: 1.4,
                                                      color: Colors.white,
                                                      fontFamily:
                                                          'NotoKufiArabic',
                                                    ),
                                                  ),
                                                ),
                                                const SizedBox(width: 8),
                                                Container(
                                                  padding: const EdgeInsets.all(
                                                    6,
                                                  ),
                                                  decoration:
                                                      const BoxDecoration(
                                                        color: Color(
                                                          0xFF2E7D32,
                                                        ),
                                                        shape: BoxShape.circle,
                                                      ),
                                                  child: Text(
                                                    '$ayahNum',
                                                    style: const TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 12,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          );
                                        }).toList(),
                                      ),
                                      const SizedBox(height: 12),
                                      Center(
                                        child: Text(
                                          'Page ${index + 1} of ${_pages.length}',
                                          style: const TextStyle(
                                            color: Colors.grey,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(height: 24),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                  Positioned(
                    right: 20,
                    bottom: 20,
                    child: FloatingActionButton(
                      backgroundColor: const Color(0xFF2E7D32),
                      onPressed: () =>
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Audio coming soon')),
                          ),
                      child: const Icon(Icons.play_arrow, color: Colors.white),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
