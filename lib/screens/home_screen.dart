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
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  final List<Widget> _tabs = [DashboardTab(), MembersScreen(), HelpScreen()];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _tabs[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (i) => setState(() => _currentIndex = i),
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Beranda'),
          BottomNavigationBarItem(icon: Icon(Icons.group), label: 'Anggota'),
          BottomNavigationBarItem(icon: Icon(Icons.help), label: 'Bantuan'),
        ],
      ),
    );
  }
}

class DashboardTab extends StatelessWidget {
  final List<_MenuItem> menuItems = [
    _MenuItem('Stopwatch', Icons.timer, StopwatchScreen()),
    _MenuItem('Deteksi Bilangan', Icons.calculate, NumberTypeScreen()),
    _MenuItem('Tracking LBS', Icons.location_on, TrackingScreen()),
    _MenuItem('Konversi Waktu', Icons.access_time, TimeConvertScreen()),
    _MenuItem('Rekomendasi Situs', Icons.link, RecommendationScreen()),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Beranda')),
      body: ListView.builder(
        itemCount: menuItems.length,
        itemBuilder: (_, index) {
          final item = menuItems[index];
          return ListTile(
            leading: Icon(item.icon),
            title: Text(item.title),
            trailing: Icon(Icons.arrow_forward),
            onTap:
                () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => item.screen),
                ),
          );
        },
      ),
    );
  }
}

class _MenuItem {
  final String title;
  final IconData icon;
  final Widget screen;
  _MenuItem(this.title, this.icon, this.screen);
}
