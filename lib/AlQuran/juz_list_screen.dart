import 'package:flutter/material.dart';
import 'juz_detail_screen.dart';

class JuzListScreen extends StatefulWidget {
  const JuzListScreen({super.key});

  @override
  State<JuzListScreen> createState() => _JuzListScreenState();
}

class _JuzListScreenState extends State<JuzListScreen> {
  bool _isLoading = true;
  List<Map<String, dynamic>> _juzList = [];
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchJuzList();
  }

  Future<void> _fetchJuzList() async {
    try {
      setState(() => _isLoading = true);
      // Generate Juz list with proper data
      _generateFallbackJuzList();
    } catch (e) {
      _generateFallbackJuzList();
    }
  }

  void _generateFallbackJuzList() {
    // Juz names with English transliteration and Arabic
    final juzNames = [
      {'english': 'Alif Lam Meem', 'arabic': 'الم', 'page': 2},
      {'english': 'Sayaqool', 'arabic': 'سيقول', 'page': 21},
      {'english': 'Tilkal Rusull', 'arabic': 'تلك الرسل', 'page': 39},
      {'english': 'Lan Tana Loo', 'arabic': 'لن تنالوا', 'page': 57},
      {'english': 'Wal Mohsanat', 'arabic': 'والمحصنات', 'page': 75},
      {'english': 'La Yuhibbullah', 'arabic': 'لا يحب', 'page': 93},
      {'english': 'Wa Iza Samiu', 'arabic': 'وإذا سمعوا', 'page': 111},
      {'english': 'Wa Lau Annana', 'arabic': 'ولو أننا', 'page': 129},
      {'english': 'Qalal Malao', 'arabic': 'قال الملأ', 'page': 147},
      {'english': 'Wa Alamu', 'arabic': 'وأعلموا', 'page': 165},
      {'english': 'Yatazeroon', 'arabic': 'يتذكرون', 'page': 183},
      {'english': 'Wa Alladheena', 'arabic': 'والذين', 'page': 201},
      {'english': 'Wa Ith Qala', 'arabic': 'وإذ قال', 'page': 219},
      {'english': 'Nuzil Alaihi', 'arabic': 'نزل عليه', 'page': 237},
      {'english': 'Subhana', 'arabic': 'سبحان', 'page': 255},
      {'english': 'Qala Inallah', 'arabic': 'قال إن الله', 'page': 273},
      {'english': 'Alam Tara', 'arabic': 'ألم تر', 'page': 291},
      {'english': 'Qad Aflaha', 'arabic': 'قد أفلح', 'page': 309},
      {'english': 'Wa Qala Alladheena', 'arabic': 'وقال الذين', 'page': 327},
      {'english': 'Taha', 'arabic': 'طه', 'page': 345},
      {'english': 'Amm Al Kitab', 'arabic': 'أم الكتاب', 'page': 363},
      {'english': 'Am Yahsaboon', 'arabic': 'أم يحسبون', 'page': 381},
      {'english': 'Wa Izaa Qala', 'arabic': 'وإذا قال', 'page': 399},
      {'english': 'Faman Azlam', 'arabic': 'فمن أظلم', 'page': 417},
      {'english': 'Iza Jaaka', 'arabic': 'إذا جاءك', 'page': 435},
      {'english': 'Ha Meem', 'arabic': 'حم', 'page': 453},
      {'english': 'Qala Fatrada', 'arabic': 'قال فترادى', 'page': 471},
      {'english': 'Qaf', 'arabic': 'ق', 'page': 489},
      {'english': 'Tabaraka', 'arabic': 'تبارك', 'page': 505},
      {'english': 'Amma', 'arabic': 'عمّ', 'page': 521},
    ];

    _juzList = List.generate(30, (index) {
      final juzData = juzNames[index];
      return {
        'id': index + 1,
        'englishName': juzData['english'],
        'arabicName': juzData['arabic'],
        'pageNumber': juzData['page'],
      };
    });

    setState(() {
      _isLoading = false;
      _error = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Juzz Index',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
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
                    Text(
                      _error!,
                      style: const TextStyle(color: Colors.red, fontSize: 16),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _fetchJuzList,
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
                itemCount: _juzList.length,
                separatorBuilder: (context, index) =>
                    Divider(color: Colors.grey[700], height: 1, thickness: 1),
                itemBuilder: (context, index) {
                  final juz = _juzList[index];
                  return InkWell(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => JuzDetailScreen(juzNumber: juz['id']),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: Row(
                        children: [
                          // Left side: Number, English name, Page
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${juz['id']}. ${juz['englishName']}',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFFFFC107),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Page # ${juz['pageNumber']}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[500],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // Right side: Arabic name
                          Text(
                            juz['arabicName'],
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
