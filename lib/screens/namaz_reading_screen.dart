import 'package:flutter/material.dart';
import '../services/namaz_api_service.dart';

class NamazReadingScreen extends StatefulWidget {
  const NamazReadingScreen({Key? key}) : super(key: key);

  @override
  _NamazReadingScreenState createState() => _NamazReadingScreenState();
}

class _NamazReadingScreenState extends State<NamazReadingScreen> {
  late Future<List<Map<String, String>>> _namazContent;

  @override
  void initState() {
    super.initState();
    _namazContent = NamazApiService.fetchNamazContent();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Namaz Reading'),
        backgroundColor: Colors.teal,
      ),
      body: FutureBuilder<List<Map<String, String>>>(
        future: _namazContent,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Error: ${snapshot.error}',
                    style: const TextStyle(fontSize: 16, color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _namazContent = NamazApiService.fetchNamazContent();
                      });
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          } else if (snapshot.hasData) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: snapshot.data!
                    .map(
                      (section) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              section['title']!,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                              textAlign: TextAlign.right,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              section['text']!,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.normal,
                                color: Colors.black,
                                fontFamily:
                                    'Amiri', // Use a font that supports Arabic
                              ),
                              textAlign: TextAlign.right,
                            ),
                          ],
                        ),
                      ),
                    )
                    .toList(),
              ),
            );
          } else {
            return const Center(child: Text('No content available.'));
          }
        },
      ),
    );
  }
}
