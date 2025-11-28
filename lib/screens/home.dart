import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';
import 'auth_page.dart';
import '../AlQuran/juz_list_screen.dart';
import 'surah_list_screen.dart';
import 'namaz_timings_screen.dart';
import 'tasbih_counter_screen.dart';
import 'namaz_reading_screen.dart';
import '../AlQuran/al_quran_screen.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;
  String? _displayEmail;
  List<dynamic>? _surahs;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchSurahs();

    // Load saved email from local storage if Firebase user is not present
    if (FirebaseAuth.instance.currentUser == null) {
      AuthService.getUserEmail().then((email) {
        if (mounted && email != null) {
          setState(() => _displayEmail = email);
        }
      });
    } else {
      _displayEmail = FirebaseAuth.instance.currentUser?.email;
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _fetchSurahs() async {
    try {
      setState(() {
        _surahs = [
          {
            'number': 1,
            'englishName': 'Al-Fatihah',
            'englishNameTranslation': 'The Opening',
          },
          {
            'number': 2,
            'englishName': 'Al-Baqarah',
            'englishNameTranslation': 'The Cow',
          },
          {
            'number': 3,
            'englishName': 'Aal-E-Imran',
            'englishNameTranslation': 'The Family of Imran',
          },
        ];
        _isLoading = false;
      });
    } catch (e) {
      print('Error fetching Surahs: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final fbUser = FirebaseAuth.instance.currentUser;
    if (fbUser != null && _displayEmail != fbUser.email) {
      _displayEmail = fbUser.email;
    }
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const Text(
              'QuranLearn',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2B4146),
              ),
            ),
            const Spacer(),
            if (_displayEmail != null)
              Padding(
                padding: const EdgeInsets.only(right: 16),
                child: Text(
                  _displayEmail!,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF2B4146),
                  ),
                ),
              ),
            const Icon(Icons.wifi_off, color: Color(0xFF8B4513)),
            const SizedBox(width: 8),
            const CircleAvatar(
              radius: 20,
              backgroundColor: Color(0xFFFFCCBC), // Restored original color
              child: Icon(Icons.person, color: Color(0xFF2B4146)),
            ),
          ],
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Color(0xFF2B4146)),
            tooltip: 'Logout',
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              await AuthService.logout();
              if (context.mounted) {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const AuthPage()),
                  (route) => false,
                );
              }
            },
          ),
        ],
      ),
      bottomSheet: FirebaseAuth.instance.currentUser == null
          ? Container(
              color: const Color(0xFFFFF3E0), // Restored original color
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.info_outline, color: Color(0xFF8B4513)),
                  SizedBox(width: 8),
                  Text(
                    'Guest mode: you are logged in locally',
                    style: TextStyle(color: Color(0xFF8B4513)),
                  ),
                ],
              ),
            )
          : null,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _surahs == null
          ? const Center(child: Text('Failed to load Surahs'))
          : IndexedStack(
              index: _currentIndex,
              children: [
                _buildHomeContent(),
                const Center(child: Text('Lessons')),
                const Center(child: Text('Practice')),
                const Center(child: Text('Profile')),
              ],
            ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        backgroundColor: Colors.white,
        elevation: 0,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.school_outlined),
            selectedIcon: Icon(Icons.school),
            label: 'Lessons',
          ),
          NavigationDestination(
            icon: Icon(Icons.edit_outlined),
            selectedIcon: Icon(Icons.edit),
            label: 'Practice',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }

  Widget _buildHomeContent() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.white, Color.fromARGB(77, 233, 246, 246)],
        ),
      ),
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _buildHomeCard(
            icon: Icons.access_time,
            title: 'Namaz Timing',
            subtitle: '',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const NamazTimingsScreen()),
            ),
          ),
          const SizedBox(height: 16),
          _buildHomeCard(
            icon: Icons.book,
            title: 'Juzz',
            subtitle: 'Browse all 30 Juzz',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const JuzListScreen()),
            ),
          ),
          const SizedBox(height: 16),
          _buildHomeCard(
            icon: Icons.menu_book,
            title: 'Al-Quran',
            subtitle: 'Explore the Quran',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => AlQuranScreen()),
            ),
          ),
          const SizedBox(height: 16),
          _buildHomeCard(
            icon: Icons.location_on,
            title: 'Masjid Finder',
            subtitle: 'Find nearby mosques',
            onTap: () {
              // Navigate to Masjid Finder screen
            },
          ),
          const SizedBox(height: 16),
          _buildHomeCard(
            icon: Icons.explore,
            title: 'Qibla Direction',
            subtitle: 'Find the direction of Qibla',
            onTap: () {
              // Navigate to Qibla Direction screen
            },
          ),
          const SizedBox(height: 16),
          _buildHomeCard(
            icon: Icons.book,
            title: 'Namaz Reading',
            subtitle: 'Learn and read Namaz',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const NamazReadingScreen()),
            ),
          ),
          const SizedBox(height: 16),
          _buildHomeCard(
            icon: Icons.favorite,
            title: 'Duas',
            subtitle: 'Collection of daily Duas',
            onTap: () {
              // Navigate to Duas screen
            },
          ),
          const SizedBox(height: 16),
          _buildHomeCard(
            icon: Icons.countertops,
            title: 'Tasbih Counter',
            subtitle: 'Count your dhikr easily',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const TasbihCounterScreen()),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHomeCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF9DE0E7), Color(0xFFE8F3F1)],
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  color: Color(0xFF1E8B88),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: Colors.white, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2B4146),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF666666),
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios, color: Color(0xFF1E8B88)),
            ],
          ),
        ),
      ),
    );
  }
}
