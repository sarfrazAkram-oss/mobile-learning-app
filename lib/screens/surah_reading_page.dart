import 'package:flutter/material.dart';
import '../services/quran_api_service.dart';

class SurahReadingPage extends StatefulWidget {
  final int surahNumber;
  final String surahName;

  const SurahReadingPage({
    super.key,
    required this.surahNumber,
    required this.surahName,
  });

  @override
  _SurahReadingPageState createState() => _SurahReadingPageState();
}

class _SurahReadingPageState extends State<SurahReadingPage> {
  Map<String, dynamic>? _surahDetails;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchSurahDetails();
  }

  // Update the _fetchSurahDetails method to use the new pagination logic
  Future<void> _fetchSurahDetails() async {
    final apiService = QuranApiService();
    try {
      print('Fetching full Surah for Surah number: ${widget.surahNumber}');
      final verses = await apiService.fetchSurahDetails(widget.surahNumber);
      print('Fetched verses: $verses');
      setState(() {
        _surahDetails = {'verses': verses};
        _isLoading = false;
      });
    } catch (e) {
      print('Error fetching Surah content: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.surahName),
        backgroundColor: Colors.teal,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _surahDetails == null
          ? const Center(child: Text('Failed to load Surah'))
          : Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xFFF5F5F5), // Light background color
                    Color(0xFFE8E8E8), // Slightly darker shade
                  ],
                ),
              ),
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _surahDetails!['verses'].length,
                itemBuilder: (context, index) {
                  final ayah = _surahDetails!['verses'][index];
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        ayah['text'],
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w500,
                          color: Colors.black87,
                          height: 2.0,
                          fontFamily: 'Amiri',
                        ),
                        textAlign: TextAlign.right,
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
