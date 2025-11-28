import 'package:flutter/material.dart';
import '../services/quran_api_service.dart';

class SurahDetailsScreen extends StatefulWidget {
  final int surahNumber;

  const SurahDetailsScreen({required this.surahNumber, super.key});

  @override
  _SurahDetailsScreenState createState() => _SurahDetailsScreenState();
}

class _SurahDetailsScreenState extends State<SurahDetailsScreen> {
  Map<String, dynamic>? _surahDetails;
  bool _isLoading = true;

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_surahDetails?['englishName'] ?? 'Surah Details'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _surahDetails == null
          ? const Center(child: Text('Failed to load Surah details'))
          : ListView.builder(
              itemCount: _surahDetails!['ayahs'].length,
              itemBuilder: (context, index) {
                final ayah = _surahDetails!['ayahs'][index];
                return ListTile(
                  title: Text(ayah['text']),
                  subtitle: Text('Ayah ${ayah['number']}'),
                );
              },
            ),
    );
  }
}
