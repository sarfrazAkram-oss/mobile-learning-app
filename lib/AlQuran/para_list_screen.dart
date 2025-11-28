import 'package:flutter/material.dart';
import 'juz_page.dart';

class ParaListScreen extends StatefulWidget {
  const ParaListScreen({super.key});

  @override
  State<ParaListScreen> createState() => _ParaListScreenState();
}

class _ParaListScreenState extends State<ParaListScreen> {
  bool _isLoading = true;
  List<Map<String, dynamic>> _paraList = [];
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchParaList();
  }

  Future<void> _fetchParaList() async {
    try {
      setState(() => _isLoading = true);
      // Generate Para list (same as Juz list in Quran structure)
      // Para and Juz are the same concept, so we'll fetch juz data
      _generateParaList();
    } catch (e) {
      setState(() {
        _error = 'Error: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  void _generateParaList() {
    // Para/Juz names in Arabic
    final paraNames = [
      'الم',
      'سيقول',
      'تلك الرسل',
      'فإن أخطأتم',
      'والمحصنات',
      'لا يستطيعون',
      'سأل سائل',
      'ولو أننا',
      'قال الملأ',
      'الشورى',
      'يا أيها الناس',
      'والذين يجتنبون',
      'إن الذين أوتوا',
      'نزل عليه',
      'سبحان الذي',
      'قال إن الله',
      'ألم تر',
      'قد أفلح',
      'وقال الذين',
      'طه',
      'أمّ الكتاب',
      'أم يحسبون',
      'وإذ قال موسى',
      'فمن أظلم',
      'إذا جاءك المنافقون',
      'حم',
      'قال فما خطبكم',
      'ق',
      'تبارك الذي',
      'عمّ',
    ];

    _paraList = List.generate(30, (index) {
      return {
        'id': index + 1,
        'name': 'Para ${index + 1}',
        'arabicName': paraNames[index],
        'index': index + 1,
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
          'Al-Quran (Paras)',
          style: TextStyle(
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
                      onPressed: _fetchParaList,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF9DE0E7),
                      ),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              )
            : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _paraList.length,
                itemBuilder: (context, index) {
                  final para = _paraList[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: InkWell(
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => JuzPage(juzNumber: para['id']),
                          ),
                        ),
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            gradient: const LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [Color(0xFF9DE0E7), Color(0xFFE8F3F1)],
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 50,
                                height: 50,
                                decoration: const BoxDecoration(
                                  color: Color(0xFF1E8B88),
                                  shape: BoxShape.circle,
                                ),
                                child: Center(
                                  child: Text(
                                    '${para['id']}',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Para ${para['id']}',
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF2B4146),
                                      ),
                                    ),
                                    Text(
                                      para['arabicName'],
                                      style: const TextStyle(
                                        fontSize: 14,
                                        color: Color(0xFF1E8B88),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const Icon(
                                Icons.arrow_forward_ios,
                                color: Color(0xFF1E8B88),
                                size: 18,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }
}
