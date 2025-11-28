import 'package:flutter/material.dart';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:audioplayers/audioplayers.dart';

class NamazTimingsScreen extends StatefulWidget {
  const NamazTimingsScreen({super.key});

  @override
  State<NamazTimingsScreen> createState() => _NamazTimingsScreenState();
}

class _NamazTimingsScreenState extends State<NamazTimingsScreen> {
  Map<String, String>? _namazTimings;
  String? _nextNamaz;
  Duration? _timeUntilNextNamaz;
  bool _isLoading = true;
  String? _islamicDate;
  String? _islamicMonth;
  String? _islamicYear;
  String? _englishDate;
  String? _englishMonth;
  String? _englishYear;

  Timer? _countdownTimer;

  @override
  void initState() {
    super.initState();
    _fetchNamazTimings();
    _fetchDates();
    _startCountdown();
  }

  // Fixed prayer timings API response handling
  Future<void> _fetchNamazTimings() async {
    try {
      final response = await http.get(
        Uri.parse(
          'https://api.aladhan.com/v1/timings?latitude=24.8607&longitude=67.0011&method=2',
        ),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _namazTimings = {
            'Fajr': data['data']['timings']['Fajr'],
            'Sunrise': data['data']['timings']['Sunrise'],
            'Dhuhr': data['data']['timings']['Dhuhr'],
            'Asr': data['data']['timings']['Asr'],
            'Maghrib': data['data']['timings']['Maghrib'],
            'Isha': data['data']['timings']['Isha'],
          };
          _isLoading = false;
          _calculateNextNamaz();
        });
      } else {
        throw Exception(
          'Failed to fetch prayer timings: ${response.statusCode}',
        );
      }
    } catch (e) {
      print('Error fetching prayer timings: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _fetchDates() async {
    try {
      final response = await http.get(
        Uri.parse('http://api.aladhan.com/v1/gToH'),
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _islamicDate = data['data']['hijri']['date'];
          _islamicMonth = data['data']['hijri']['month']['en'];
          _islamicYear = data['data']['hijri']['year'];
          _englishDate = data['data']['gregorian']['date'];
          _englishMonth = data['data']['gregorian']['month']['en'];
          _englishYear = data['data']['gregorian']['year'];
          _isLoading = false;
        });
      } else {
        print('Failed to fetch dates');
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error fetching dates: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _startCountdown() {
    _countdownTimer?.cancel();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_timeUntilNextNamaz != null) {
        setState(() {
          _timeUntilNextNamaz =
              _timeUntilNextNamaz! - const Duration(seconds: 1);
        });

        if (_timeUntilNextNamaz!.isNegative) {
          timer.cancel();
          _calculateNextNamaz();
        }
      }
    });
  }

  // Debugging and fixing `_calculateNextNamaz`
  void _calculateNextNamaz() {
    final now = TimeOfDay.now();
    String? nextNamazName;
    TimeOfDay? nextNamazTime;

    _namazTimings?.forEach((name, time) {
      final parts = time.split(':');
      final hour = int.parse(parts[0]);
      final minute = int.parse(parts[1]);

      final namazTime = TimeOfDay(hour: hour, minute: minute);

      if (namazTime.hour > now.hour ||
          (namazTime.hour == now.hour && namazTime.minute > now.minute)) {
        if (nextNamazTime == null ||
            namazTime.hour < (nextNamazTime?.hour ?? 0) ||
            (namazTime.hour == (nextNamazTime?.hour ?? 0) &&
                namazTime.minute < (nextNamazTime?.minute ?? 0))) {
          nextNamazTime = namazTime;
          nextNamazName = name;
        }
      }
    });

    if (nextNamazTime != null) {
      final nowDateTime = DateTime.now();
      final nextNamazDateTime = DateTime(
        nowDateTime.year,
        nowDateTime.month,
        nowDateTime.day,
        nextNamazTime?.hour ?? 0,
        nextNamazTime?.minute ?? 0,
      );

      setState(() {
        _nextNamaz = nextNamazName;
        _timeUntilNextNamaz = nextNamazDateTime.difference(nowDateTime);
      });
    } else {
      setState(() {
        _nextNamaz = 'Now';
        _timeUntilNextNamaz = Duration.zero;
      });
    }
  }

  void _playAzan([String? voice]) {
    final azanVoice = voice ?? 'Default';
    final player = AudioPlayer();
    final azanUrls = {
      'Makkah': 'https://valid-audio-url.com/makkah.mp3',
      'Madinah': 'https://valid-audio-url.com/madinah.mp3',
      'Default': 'https://valid-audio-url.com/default.mp3',
      'Egypt': 'https://valid-audio-url.com/egypt.mp3',
      'Turkey': 'https://valid-audio-url.com/turkey.mp3',
    };

    final url = azanUrls[azanVoice] ?? azanUrls['Default'];
    if (url != null) {
      player.play(UrlSource(url));
    }
  }

  void _showAzanSettings() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        final List<String> azanVoices = [
          'Makkah',
          'Madinah',
          'Default',
          'Egypt',
          'Turkey',
        ];
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: azanVoices.map((voice) {
            return ListTile(
              title: Text(voice),
              onTap: () {
                Navigator.pop(context);
                setState(() {
                  _playAzan(voice);
                });
              },
            );
          }).toList(),
        );
      },
    );
  }

  @override
  void dispose() {
    super.dispose();
    _countdownTimer?.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Prayer Times')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Top Section: Islamic and Gregorian Dates
                Container(
                  color: Colors.yellow,
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Icon(Icons.arrow_back_ios, color: Colors.black),
                          Text(
                            '$_islamicDate - $_islamicMonth - $_islamicYear',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Icon(Icons.arrow_forward_ios, color: Colors.black),
                        ],
                      ),
                      Text(
                        '$_englishDate - $_englishMonth - $_englishYear',
                        style: const TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                ),

                // Black Line Section with Countdown
                if (_timeUntilNextNamaz != null)
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: const BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.all(Radius.circular(8)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: const [
                            Icon(Icons.watch_later, color: Colors.white),
                            SizedBox(width: 8),
                            Text(
                              'Next Namaz',
                              style: TextStyle(color: Colors.white),
                            ),
                          ],
                        ),
                        Text(
                          'Time left: ${_timeUntilNextNamaz!.inHours.toString().padLeft(2, '0')}:${_timeUntilNextNamaz!.inMinutes.remainder(60).toString().padLeft(2, '0')}:${_timeUntilNextNamaz!.inSeconds.remainder(60).toString().padLeft(2, '0')}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),

                // Namaz Timings List
                Expanded(
                  child: ListView.builder(
                    itemCount: _namazTimings?.length ?? 0,
                    itemBuilder: (context, index) {
                      final namazName = _namazTimings!.keys.elementAt(index);
                      final namazTime = _namazTimings![namazName]!;
                      final isCurrentNamaz = namazName == _nextNamaz;

                      return Column(
                        children: [
                          Container(
                            color: isCurrentNamaz
                                ? Colors.green
                                : Colors.transparent,
                            padding: const EdgeInsets.symmetric(
                              vertical: 8,
                              horizontal: 16,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  namazName + (isCurrentNamaz ? ' - Now' : ''),
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: isCurrentNamaz
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                    color: isCurrentNamaz
                                        ? Colors.white
                                        : Colors.black,
                                  ),
                                ),
                                Text(
                                  namazTime,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: isCurrentNamaz
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                    color: isCurrentNamaz
                                        ? Colors.white
                                        : Colors.black,
                                  ),
                                ),
                                Row(
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.volume_up),
                                      onPressed: () {
                                        if (isCurrentNamaz &&
                                            _timeUntilNextNamaz!.inSeconds ==
                                                0) {
                                          _playAzan();
                                        }
                                      },
                                    ),
                                    const SizedBox(width: 8),
                                    IconButton(
                                      icon: const Icon(Icons.settings),
                                      onPressed: _showAzanSettings,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }
}
