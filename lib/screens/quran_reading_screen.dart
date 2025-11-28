import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class QuranReadingScreen extends StatefulWidget {
  final int pageNumber;

  const QuranReadingScreen({super.key, required this.pageNumber});

  @override
  _QuranReadingScreenState createState() => _QuranReadingScreenState();
}

class _QuranReadingScreenState extends State<QuranReadingScreen> {
  late Future<Map<String, dynamic>> pageData;

  @override
  void initState() {
    super.initState();
    pageData = fetchPageData(widget.pageNumber);
  }

  Future<Map<String, dynamic>> fetchPageData(int pageNumber) async {
    final response = await http.get(
      Uri.parse(
        'https://api.quran.com/api/v4/pages/$pageNumber',
      ), // Example API endpoint
    );
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load page data');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<Map<String, dynamic>>(
        future: pageData,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            final pageData = snapshot.data!;
            final surahName = pageData['data']['surah_name'] ?? 'Unknown Surah';
            final ayahs = pageData['data']['ayahs'] ?? [];

            return Column(
              children: [
                Expanded(
                  child: Container(
                    color: Colors.black,
                    child: Column(
                      children: [
                        // Top Border
                        Container(
                          decoration: const BoxDecoration(
                            border: Border(
                              top: BorderSide(color: Colors.yellow, width: 2),
                            ),
                          ),
                          padding: const EdgeInsets.symmetric(
                            vertical: 8.0,
                            horizontal: 16.0,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Juz ${pageData['data']['juz'] ?? 'Unknown'}',
                                style: const TextStyle(
                                  color: Colors.yellow,
                                  fontSize: 16,
                                ),
                              ),
                              Text(
                                'Page ${widget.pageNumber}',
                                style: const TextStyle(
                                  color: Colors.yellow,
                                  fontSize: 16,
                                ),
                              ),
                              Text(
                                surahName,
                                style: const TextStyle(
                                  color: Colors.yellow,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Page Content
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16.0,
                            ),
                            child: ayahs.isEmpty
                                ? const Center(
                                    child: Text(
                                      'No content available',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 18,
                                      ),
                                    ),
                                  )
                                : ListView.builder(
                                    itemCount: ayahs.length,
                                    itemBuilder: (context, index) {
                                      final ayah = ayahs[index];
                                      return Padding(
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 8.0,
                                        ),
                                        child: Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            CircleAvatar(
                                              backgroundColor: Colors.yellow,
                                              child: Text(
                                                ayah['ayah_number'].toString(),
                                                style: const TextStyle(
                                                  color: Colors.black,
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            Expanded(
                                              child: Text(
                                                ayah['text'] ?? '',
                                                textAlign: TextAlign.right,
                                                style: const TextStyle(
                                                  fontSize: 18,
                                                  color: Colors.white,
                                                  height: 2.0,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                  ),
                          ),
                        ),

                        // Bottom Border
                        Container(
                          decoration: const BoxDecoration(
                            border: Border(
                              bottom: BorderSide(
                                color: Colors.yellow,
                                width: 2,
                              ),
                            ),
                          ),
                          padding: const EdgeInsets.symmetric(
                            vertical: 8.0,
                            horizontal: 16.0,
                          ),
                          child: Text(
                            'Manzil: ${pageData['data']['manzil'] ?? 'Unknown'}',
                            style: const TextStyle(
                              color: Colors.yellow,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Navigation Buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ElevatedButton(
                      onPressed: widget.pageNumber > 1
                          ? () {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => QuranReadingScreen(
                                    pageNumber: widget.pageNumber - 1,
                                  ),
                                ),
                              );
                            }
                          : null,
                      child: const Text('Previous'),
                    ),
                    ElevatedButton(
                      onPressed: widget.pageNumber < 604
                          ? () {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => QuranReadingScreen(
                                    pageNumber: widget.pageNumber + 1,
                                  ),
                                ),
                              );
                            }
                          : null,
                      child: const Text('Next'),
                    ),
                  ],
                ),
              ],
            );
          }
        },
      ),
    );
  }
}
