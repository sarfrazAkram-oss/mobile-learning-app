import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class JuzPage extends StatefulWidget {
  final int juzNumber;

  const JuzPage({super.key, required this.juzNumber});

  @override
  State<JuzPage> createState() => _JuzPageState();
}

class _JuzPageState extends State<JuzPage> {
  bool _isLoading = true;
  final List<Map<String, String>> _pageTexts = [];
  String? _error;
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _fetchJuzData();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _fetchJuzData() async {
    try {
      setState(() => _isLoading = true);
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
            _pageTexts.clear();
            const int ayahsPerPage = 10;

            for (int i = 0; i < ayahs.length; i += ayahsPerPage) {
              int endIdx = (i + ayahsPerPage < ayahs.length)
                  ? i + ayahsPerPage
                  : ayahs.length;
              String pageText = '';

              for (int j = i; j < endIdx; j++) {
                final ayah = ayahs[j] as Map<String, dynamic>;
                final text = ayah['text'] ?? '';
                final surahNum = ayah['surah']?['number'] ?? '';
                final ayahNum = ayah['numberInSurah'] ?? '';
                pageText += '$text\n\n $surahNum:$ayahNum\n\n---\n\n';
              }

              _pageTexts.add({
                'text': pageText.trim(),
                'pageNum': '${i ~/ ayahsPerPage + 1}',
              });
            }

            setState(() => _isLoading = false);
            return;
          }
        }
      }

      setState(() {
        _error = 'Failed to load Juz';
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
            color: Color(0xFF2B4146),
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF2B4146)),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.white, Color.fromARGB(77, 233, 246, 246)],
          ),
        ),
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation(Color(0xFF9DE0E7)),
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
                      onPressed: _fetchJuzData,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF9DE0E7),
                      ),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              )
            : Stack(
                children: [
                  PageView.builder(
                    controller: _pageController,
                    itemCount: _pageTexts.length,
                    itemBuilder: (context, index) {
                      final pageData = _pageTexts[index];
                      return SingleChildScrollView(
                        padding: const EdgeInsets.all(16),
                        child: Center(
                          child: Container(
                            constraints: const BoxConstraints(maxWidth: 650),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 30,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFAF5EA),
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: const [
                                BoxShadow(color: Colors.black12, blurRadius: 8),
                              ],
                              border: Border.all(
                                color: const Color(0xFFD9C9A3),
                                width: 2,
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                // Full page text preserved exactly as original (no Tajweed)
                                Text(
                                  pageData['text'] ?? '',
                                  textAlign: TextAlign.right,
                                  style: const TextStyle(
                                    fontSize: 26,
                                    height: 2.0,
                                    color: Color(0xFF2B4146),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 24),
                                Center(
                                  child: Text(
                                    'Page ${index + 1} of ${_pageTexts.length}',
                                    style: const TextStyle(
                                      color: Color(0xFF999999),
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                  Positioned(
                    right: 20,
                    bottom: 20,
                    child: FloatingActionButton(
                      backgroundColor: const Color(0xFF1E8B88),
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Audio coming soon')),
                        );
                      },
                      child: const Icon(Icons.play_arrow, color: Colors.white),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
