import 'package:flutter/material.dart';
import '../services/quran_api_service.dart';

class QuranReaderScreen extends StatefulWidget {
  final int surahNumber;

  const QuranReaderScreen({required this.surahNumber, super.key});

  @override
  _QuranReaderScreenState createState() => _QuranReaderScreenState();
}

class _QuranReaderScreenState extends State<QuranReaderScreen> {
  Map<String, dynamic>? _surahDetails;
  bool _isLoading = true;
  int _currentAyahIndex = 0;

  @override
  void initState() {
    super.initState();
    _fetchSurahDetails();
  }

  Future<void> _fetchSurahDetails() async {
    final apiService = QuranApiService();
    try {
      final details = await apiService.fetchSurahDetails(widget.surahNumber);
      setState(() {
        _surahDetails = {'ayahs': details};
        _isLoading = false;
      });
    } catch (e) {
      print('Error fetching Surah details: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _nextAyah() {
    if (_currentAyahIndex < (_surahDetails?['ayahs'].length ?? 0) - 1) {
      setState(() {
        _currentAyahIndex++;
      });
    }
  }

  void _previousAyah() {
    if (_currentAyahIndex > 0) {
      setState(() {
        _currentAyahIndex--;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_surahDetails?['englishName'] ?? 'Quran Reader'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _surahDetails == null
          ? const Center(child: Text('Failed to load Surah details'))
          : Column(
              children: [
                Expanded(
                  child: Center(
                    child: Text(
                      _surahDetails!['ayahs'][_currentAyahIndex]['text'],
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 24),
                    ),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back),
                      onPressed: _previousAyah,
                    ),
                    Text(
                      'Ayah ${_currentAyahIndex + 1} of ${_surahDetails!['ayahs'].length}',
                    ),
                    IconButton(
                      icon: const Icon(Icons.arrow_forward),
                      onPressed: _nextAyah,
                    ),
                  ],
                ),
              ],
            ),
    );
  }
}
