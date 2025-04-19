import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../screens/stopwatch_screen.dart';
import '../screens/number_type_screen.dart';
import '../screens/tracking_screen.dart';
import '../screens/time_convert_screen.dart';
import '../screens/recommendation_screen.dart';
import '../screens/members_screen.dart';
import '../screens/help_screen.dart';
import '../providers/auth_provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  final List<Widget> _tabs = [
    DashboardTab(), 
    const MembersScreen(), 
    const HelpScreen()
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _tabs[_currentIndex],
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 8,
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (i) => setState(() => _currentIndex = i),
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.dashboard_rounded),
              label: 'Beranda',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.people_alt_rounded),
              label: 'Anggota',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.help_center_rounded),
              label: 'Bantuan',
            ),
          ],
          selectedItemColor: Theme.of(context).primaryColor,
          unselectedItemColor: Colors.grey,
          showUnselectedLabels: true,
          elevation: 1, // Konsisten dengan AppBar pada screen lainnya
        ),
      ),
    );
  }
}

class DashboardTab extends StatelessWidget {
  final List<_MenuItem> menuItems = [
    _MenuItem('Stopwatch', Icons.timer, StopwatchScreen(), Colors.blue),
    _MenuItem('Deteksi Bilangan', Icons.calculate, NumberTypeScreen(), Colors.green),
    _MenuItem('Tracking LBS', Icons.location_on, TrackingScreen(), Colors.orange),
    _MenuItem('Konversi Waktu', Icons.access_time, TimeConvertScreen(), Colors.purple),
    _MenuItem('Rekomendasi Situs', Icons.link, RecommendationScreen(), Colors.red),
  ];

  DashboardTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 1, // Konsisten dengan screen lainnya
        title: const Text(
          'Aplikasi Multifungsi',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Header section
          Container(
            margin: const EdgeInsets.only(bottom: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Pilih menu di bawah ini',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[700],
                  ),
                ),
                const SizedBox(height: 8),
                const Divider(),
              ],
            ),
          ),
          
          // Menu items
          ...menuItems.map((item) => _buildMenuItem(context, item)).toList(),
          
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildMenuItem(BuildContext context, _MenuItem item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8), // Konsisten dengan card lainnya
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1), // Shadow lebih halus
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(8), // Sesuaikan dengan container
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => item.screen),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: item.color.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    item.icon,
                    size: 24, // Sedikit lebih kecil untuk konsistensi dengan screen lain
                    color: item.color,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    item.title,
                    style: const TextStyle(
                      fontSize: 16, // Ukuran font yang lebih konsisten
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                ),
                const Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: Colors.grey,
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _MenuItem {
  final String title;
  final IconData icon;
  final Widget screen;
  final Color color;
  
  const _MenuItem(this.title, this.icon, this.screen, this.color);
}
