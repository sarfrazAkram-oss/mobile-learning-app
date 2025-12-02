import 'package:flutter/material.dart';
import '../services/quran_api_service.dart';
import 'tajweed_rules_screen.dart';

/// Single clean implementation of Tajweed reader.
/// Shows surah list and per-surah tajweed-colored text using
/// `TajweedRulesScreen.ruleColors` for the palette.
class TajweedQuranReaderScreen extends StatefulWidget {
  const TajweedQuranReaderScreen({Key? key}) : super(key: key);

  @override
  _TajweedQuranReaderScreenState createState() =>
      _TajweedQuranReaderScreenState();
}

class _TajweedQuranReaderScreenState extends State<TajweedQuranReaderScreen> {
  final QuranApiService _api = QuranApiService();
  List<Map<String, dynamic>> _surahs = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchSurahList();
  }

  Future<void> _fetchSurahList() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final data = await _api.fetchSurahList();
      setState(() {
        _surahs = data;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tajweed Quran')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? Center(child: Text('Error: $_error'))
          : ListView.builder(
              itemCount: _surahs.length,
              itemBuilder: (context, index) {
                final s = _surahs[index];
                return ListTile(
                  title: Text(s['name'].toString()),
                  subtitle: Text('Verses: ${s['ayah_count'].toString()}'),
                  trailing: Text(s['number'].toString()),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => TajweedSurahPage(
                        surahNumber: s['number'] as int,
                        surahName: s['name'] as String,
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}

class TajweedSurahPage extends StatefulWidget {
  final int surahNumber;
  final String surahName;

  const TajweedSurahPage({
    Key? key,
    required this.surahNumber,
    required this.surahName,
  }) : super(key: key);

  @override
  _TajweedSurahPageState createState() => _TajweedSurahPageState();
}

class _TajweedSurahPageState extends State<TajweedSurahPage> {
  final QuranApiService _api = QuranApiService();
  List<Map<String, dynamic>> _ayahs = [];
  bool _loading = true;
  String? _error;

  static const Set<String> _qalqalah = {'ق', 'ط', 'ب', 'ج', 'د'};
  // Removed _tanween, _sukun, and _shadda as they were unused

  static const Map<String, String> _rulePurposes = {
    'madd': 'Prolongation of vowel sounds',
    'ghunna': 'Nasalization on Noon/Meem',
    'idghaam': 'Assimilation/merging letters',
    'izhar': 'Clear pronunciation of Noon',
    'iqlab': 'Convert Noon to Meem before ب',
    'ikhfa': 'Concealment (partial hiding)',
    'qalqalah': 'Echoing on specific letters',
    'shadda': 'Doubling/emphasis (shadda)',
    'sukun': 'Absence of vowel (sukun)',
  };

  @override
  void initState() {
    super.initState();
    _fetchSurah();
  }

  Future<void> _fetchSurah() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final data = await _api.fetchSurahDetails(widget.surahNumber);
      setState(() {
        _ayahs = data;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  List<TextSpan> _colorize(String text) {
    final spans = <TextSpan>[];
    final colors = TajweedRulesScreen.ruleColors;

    // Regex to capture Arabic base letter plus following diacritics as a single token
    final tokenRe = RegExp(
      r'[\u0600-\u06FF\u0750-\u077F\u08A0-\u08FF][\u064B-\u065F\u0670\u06D6-\u06ED]*|\s+|.',
      multiLine: true,
    );
    final matches = tokenRe.allMatches(text).toList();

    for (var idx = 0; idx < matches.length; idx++) {
      final token = matches[idx].group(0) ?? '';

      if (token.isEmpty) continue;

      if (token.trim().isEmpty) {
        // whitespace / newlines - keep as-is
        spans.add(TextSpan(text: token));
        continue;
      }

      // Determine base letter and diacritics (base is first code unit)
      final base = token[0];
      final rest = token.substring(1);

      String? rule;

      // Tanween (approx) -> ghunna
      if (RegExp('[\u064B\u064C\u064D]').hasMatch(rest)) {
        rule = 'ghunna';
      }

      // Shadda
      if (rest.contains('ّ')) {
        rule = 'shadda';
      }

      // Sukun
      if (rest.contains('ْ')) {
        rule = 'sukun';
      }

      // Qalqalah: base letter in set and next token is boundary/sukun/space
      if (rule == null && _qalqalah.contains(base)) {
        final nextToken = (idx + 1 < matches.length)
            ? matches[idx + 1].group(0) ?? ''
            : '';
        if (nextToken.isEmpty ||
            nextToken.trim().isEmpty ||
            nextToken.startsWith('\n') ||
            nextToken.startsWith('ْ')) {
          rule = 'qalqalah';
        }
      }

      // Noon/Meem rules (ghunna/idghaam/izhar/iqlab/ikhfa) - heuristic
      if (rule == null && (base == 'ن' || base == 'م')) {
        final nextToken = (idx + 1 < matches.length)
            ? matches[idx + 1].group(0) ?? ''
            : '';
        final prevToken = (idx - 1 >= 0) ? matches[idx - 1].group(0) ?? '' : '';
        final nextHasShadda = nextToken.contains('ّ');
        final nextHasSukun = nextToken.contains('ْ');
        final nextHasTanween = RegExp(
          '[\u064B\u064C\u064D]',
        ).hasMatch(nextToken);
        final prevHasShadda = prevToken.contains('ّ');

        if (nextHasShadda || nextHasSukun || nextHasTanween || prevHasShadda) {
          // decide more specific rule by peeking at next meaningful base letter
          String nextLetter = '';
          for (var j = idx + 1; j < matches.length; j++) {
            final t = matches[j].group(0) ?? '';
            if (t.trim().isEmpty) continue;
            nextLetter = t[0];
            break;
          }
          final throat = {'ء', 'ه', 'ع', 'ح', 'غ', 'خ', 'أ', 'إ', 'آ', 'ؤ'};
          final idghaamLetters = {'ي', 'ر', 'م', 'ل', 'و', 'ن'};
          if (nextLetter.isNotEmpty) {
            if (throat.contains(nextLetter)) {
              rule = 'izhar';
            } else if (nextLetter == 'ب') {
              rule = 'iqlab';
            } else if (idghaamLetters.contains(nextLetter)) {
              rule = 'idghaam';
            } else {
              rule = 'ikhfa';
            }
          } else {
            rule = 'ghunna';
          }
        }
      }

      // Madd detection (simplified)
      if (rule == null && (base == 'ا' || base == 'و' || base == 'ي')) {
        String prevLetter = '';
        for (var j = idx - 1; j >= 0; j--) {
          final t = matches[j].group(0) ?? '';
          if (t.trim().isEmpty) continue;
          prevLetter = t[0];
          break;
        }
        if (prevLetter.isNotEmpty) {
          rule = 'madd';
        }
      }

      // Choose style: default white, or tajweed color if rule matched
      final color = (rule != null)
          ? (colors[rule] ?? Colors.white)
          : Colors.white;
      spans.add(
        TextSpan(
          text: token,
          style: TextStyle(color: color, fontSize: 20),
        ),
      );
    }

    return spans;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.surahName)),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? Center(child: Text('Error: $_error'))
          : Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFF0D0D0D), Color(0xFF111111)],
                ),
              ),
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _ayahs.length + 1,
                itemBuilder: (context, index) {
                  if (index == 0) {
                    final colors = TajweedRulesScreen.ruleColors;
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Tajweed Color Legend',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 12,
                              runSpacing: 8,
                              children: _rulePurposes.keys.map((key) {
                                final color = colors[key] ?? Colors.black;
                                final label =
                                    key[0].toUpperCase() + key.substring(1);
                                final purpose = _rulePurposes[key] ?? '';
                                return Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      width: 12,
                                      height: 12,
                                      decoration: BoxDecoration(
                                        color: color,
                                        borderRadius: BorderRadius.circular(3),
                                        border: Border.all(
                                          color: Colors.black12,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    Column(
                                      mainAxisSize: MainAxisSize.min,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          label,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w600,
                                            color: Colors
                                                .black, // Changed from white to black
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          purpose,
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color: Colors
                                                .black54, // Changed from white70 to black54
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                );
                              }).toList(),
                            ),
                          ],
                        ),
                      ),
                    );
                  }
                  final a = _ayahs[index - 1];
                  final text = a['text'] as String? ?? '';
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Directionality(
                        textDirection: TextDirection.rtl,
                        child: RichText(
                          textAlign: TextAlign.right,
                          text: TextSpan(
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w500,
                              color: Colors.white,
                              height: 2.0,
                              fontFamily: 'Amiri',
                            ),
                            children: _colorize(text),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Divider(color: Colors.grey.shade300),
                    ],
                  );
                },
              ),
            ),
    );
  }
}
