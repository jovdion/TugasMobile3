import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:location/location.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter/services.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());
}

// MODEL
class User {
  final String username;

  User({required this.username});
}

class Website {
  final String id;
  final String name;
  final String url;
  final String description;
  final String imageUrl;
  bool isFavorite;

  Website({
    required this.id,
    required this.name,
    required this.url,
    required this.description,
    required this.imageUrl,
    this.isFavorite = false,
  });
}

// SERVICES
// Improved AuthService with better login and logout
class AuthService with ChangeNotifier {
  User? _user;
  bool _isAuthenticated = false;
  bool _isInitialized = false;

  User? get user => _user;
  bool get isAuthenticated => _isAuthenticated;
  bool get isInitialized => _isInitialized;

  Future<bool> login(
    String username,
    String password,
    WebsiteService websiteService,
  ) async {
    try {
      if (username.isNotEmpty && password.isNotEmpty) {
        // In a real app, you would validate credentials against a backend here
        // For this demo app, we'll just accept any non-empty credentials

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('username', username);
        print("Credentials saved for: $username");

        _user = User(username: username);
        _isAuthenticated = true;
        _isInitialized = true;

        // Set current user in WebsiteService
        websiteService.setCurrentUser(username);

        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      print("Error during login: $e");
      return false;
    }
  }

  Future<void> autoLogin(WebsiteService websiteService) async {
    if (_isInitialized) return;

    try {
      final prefs = await SharedPreferences.getInstance();
      final username = prefs.getString('username');

      if (username != null && username.isNotEmpty) {
        print("Auto login successful for user: $username");
        _user = User(username: username);
        _isAuthenticated = true;

        // Set current user in WebsiteService
        websiteService.setCurrentUser(username);
      } else {
        print("No stored credentials found");
        _isAuthenticated = false;
      }
    } catch (e) {
      print("Error during auto login: $e");
      _isAuthenticated = false;
    }

    _isInitialized = true;
    notifyListeners();
  }

  Future<void> logout(WebsiteService websiteService) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('username');
      print("User logged out");

      // Clear user data in WebsiteService
      websiteService.clearUserData();

      _user = null;
      _isAuthenticated = false;
      notifyListeners();
    } catch (e) {
      print("Error during logout: $e");
    }
  }
}

class LocationService {
  final Location _location = Location();

  Future<LocationData?> getCurrentLocation() async {
    try {
      bool serviceEnabled = await _location.serviceEnabled();
      if (!serviceEnabled) {
        serviceEnabled = await _location.requestService();
        if (!serviceEnabled) return null;
      }

      PermissionStatus permissionGranted = await _location.hasPermission();
      if (permissionGranted == PermissionStatus.denied) {
        permissionGranted = await _location.requestPermission();
        if (permissionGranted != PermissionStatus.granted) return null;
      }

      return await _location.getLocation();
    } catch (e) {
      return null;
    }
  }
}

class WebsiteService with ChangeNotifier {
  final List<Website> _websites = [
    Website(
      id: '1',
      name: 'Flutter Dev',
      url: 'https://flutter.dev',
      description: 'Situs resmi pengembangan Flutter',
      imageUrl: 'https://flutter.dev/images/flutter-logo-sharing.png',
    ),
    Website(
      id: '2',
      name: 'Dart Lang',
      url: 'https://dart.dev',
      description: 'Dokumentasi bahasa pemrograman Dart',
      imageUrl: 'https://dart.dev/assets/shared/dart-logo-for-shares.png',
    ),
  ];

  String? _currentUsername;

  List<Website> get websites => _websites;

  // Set current user when logged in
  void setCurrentUser(String? username) {
    _currentUsername = username;
    _loadFavorites();
  }

  // Save favorites to SharedPreferences
  Future<void> _saveFavorites() async {
    if (_currentUsername == null) return;

    try {
      final prefs = await SharedPreferences.getInstance();
      final favoriteIds =
          _websites
              .where((website) => website.isFavorite)
              .map((website) => website.id)
              .toList();

      await prefs.setStringList('favorites_$_currentUsername', favoriteIds);
      print('Favorites saved for user: $_currentUsername');
    } catch (e) {
      print('Error saving favorites: $e');
    }
  }

  // Load favorites from SharedPreferences
  Future<void> _loadFavorites() async {
    if (_currentUsername == null) {
      // Reset all favorites when no user is logged in
      _resetAllFavorites();
      return;
    }

    try {
      final prefs = await SharedPreferences.getInstance();
      final favoriteIds =
          prefs.getStringList('favorites_$_currentUsername') ?? [];

      // Reset all favorites first
      _resetAllFavorites();

      // Then set the ones that are in the saved list
      for (final website in _websites) {
        if (favoriteIds.contains(website.id)) {
          website.isFavorite = true;
        }
      }

      notifyListeners();
      print('Favorites loaded for user: $_currentUsername');
    } catch (e) {
      print('Error loading favorites: $e');
    }
  }

  // Reset all favorites (used on logout)
  void _resetAllFavorites() {
    for (final website in _websites) {
      website.isFavorite = false;
    }
    notifyListeners();
  }

  // Clear favorites when user logs out
  void clearUserData() {
    _currentUsername = null;
    _resetAllFavorites();
  }

  Future<void> launchWebsite(Website website) async {
    final Uri url = Uri.parse(website.url);
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    }
  }

  void toggleFavorite(String id) {
    final index = _websites.indexWhere((w) => w.id == id);
    if (index != -1) {
      _websites[index].isFavorite = !_websites[index].isFavorite;
      _saveFavorites(); // Save when favorites change
      notifyListeners();
    }
  }
}

// SCREENS
class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  String _errorMessage = '';

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context, listen: false);
    final websiteService = Provider.of<WebsiteService>(context, listen: false);

    return Scaffold(
      appBar: AppBar(title: Text('Login')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextFormField(
                controller: _usernameController,
                decoration: InputDecoration(
                  labelText: 'Username',
                  border: OutlineInputBorder(),
                ),
                validator:
                    (value) => value!.isEmpty ? 'Username harus diisi' : null,
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _passwordController,
                decoration: InputDecoration(
                  labelText: 'Password',
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
                validator:
                    (value) => value!.isEmpty ? 'Password harus diisi' : null,
              ),
              SizedBox(height: 8),
              if (_errorMessage.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    _errorMessage,
                    style: TextStyle(color: Colors.red),
                  ),
                ),
              SizedBox(height: 24),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  minimumSize: Size(double.infinity, 50),
                ),
                onPressed:
                    _isLoading
                        ? null
                        : () async {
                          if (_formKey.currentState!.validate()) {
                            setState(() {
                              _isLoading = true;
                              _errorMessage = '';
                            });

                            final success = await authService.login(
                              _usernameController.text,
                              _passwordController.text,
                              websiteService, // Pass websiteService
                            );

                            if (!success && mounted) {
                              setState(() {
                                _errorMessage =
                                    'Login gagal. Periksa username dan password Anda.';
                                _isLoading = false;
                              });
                            }
                          }
                        },
                child:
                    _isLoading
                        ? SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                        : Text('Login'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}

class TimeConversionScreen extends StatefulWidget {
  @override
  _TimeConversionScreenState createState() => _TimeConversionScreenState();
}

class _TimeConversionScreenState extends State<TimeConversionScreen> {
  final _yearsController = TextEditingController();
  String _result = '';

  void _convertTime() {
    final years = int.tryParse(_yearsController.text) ?? 0;

    if (years <= 0) {
      setState(() => _result = 'Masukkan tahun yang valid (>0)');
      return;
    }

    final days = years * 365;
    final hours = days * 24;
    final minutes = hours * 60;
    final seconds = minutes * 60;

    setState(() {
      _result = '''
$years tahun = 
${days.toStringAsFixed(0)} hari
${hours.toStringAsFixed(0)} jam
${minutes.toStringAsFixed(0)} menit
${seconds.toStringAsFixed(0)} detik
''';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Konversi Waktu')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _yearsController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Masukkan tahun',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            ElevatedButton(onPressed: _convertTime, child: Text('Konversi')),
            SizedBox(height: 32),
            Text(_result, style: TextStyle(fontSize: 18)),
          ],
        ),
      ),
    );
  }
}

class TrackingScreen extends StatefulWidget {
  @override
  _TrackingScreenState createState() => _TrackingScreenState();
}

class _TrackingScreenState extends State<TrackingScreen> {
  GoogleMapController? _mapController;
  LocationData? _currentLocation;
  bool _isLoading = false;
  Set<Marker> _markers = {};

  final CameraPosition _initialCameraPosition = CameraPosition(
    target: LatLng(-6.200000, 106.816666), // Default: Jakarta
    zoom: 15,
  );

  @override
  void initState() {
    super.initState();
    // Try to get location when screen loads
    _getLocation();
  }

  Future<void> _getLocation() async {
    setState(() => _isLoading = true);

    try {
      final location =
          await Provider.of<LocationService>(
            context,
            listen: false,
          ).getCurrentLocation();

      setState(() {
        _currentLocation = location;
        _isLoading = false;
      });

      if (_currentLocation != null && _mapController != null) {
        // Add marker for current location
        _markers.clear();
        _markers.add(
          Marker(
            markerId: MarkerId("currentLocation"),
            position: LatLng(
              _currentLocation!.latitude!,
              _currentLocation!.longitude!,
            ),
            infoWindow: InfoWindow(title: "Lokasi Anda"),
          ),
        );

        // Move camera to current location
        _mapController!.animateCamera(
          CameraUpdate.newLatLng(
            LatLng(_currentLocation!.latitude!, _currentLocation!.longitude!),
          ),
        );
      }
    } catch (e) {
      print("Error getting location: $e");
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Tracking LBS')),
      body: Stack(
        children: [
          // Google Map
          GoogleMap(
            initialCameraPosition: _initialCameraPosition,
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
            markers: _markers,
            onMapCreated: (GoogleMapController controller) {
              _mapController = controller;
              if (_currentLocation != null) {
                // If we already have location, update map
                _markers.add(
                  Marker(
                    markerId: MarkerId("currentLocation"),
                    position: LatLng(
                      _currentLocation!.latitude!,
                      _currentLocation!.longitude!,
                    ),
                    infoWindow: InfoWindow(title: "Lokasi Anda"),
                  ),
                );

                controller.animateCamera(
                  CameraUpdate.newLatLng(
                    LatLng(
                      _currentLocation!.latitude!,
                      _currentLocation!.longitude!,
                    ),
                  ),
                );
              }
            },
          ),

          // Location Info Panel
          if (_currentLocation != null)
            Positioned(
              top: 16,
              left: 16,
              right: 16,
              child: Card(
                elevation: 4,
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Lokasi Anda:',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Latitude: ${_currentLocation!.latitude!.toStringAsFixed(6)}',
                      ),
                      Text(
                        'Longitude: ${_currentLocation!.longitude!.toStringAsFixed(6)}',
                      ),
                    ],
                  ),
                ),
              ),
            ),

          // Loading indicator
          if (_isLoading)
            Container(
              color: Colors.black26,
              child: Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _getLocation,
        child: Icon(Icons.my_location),
        tooltip: 'Dapatkan Lokasi',
      ),
    );
  }
}

class WebsitesScreen extends StatefulWidget {
  @override
  _WebsitesScreenState createState() => _WebsitesScreenState();
}

class _WebsitesScreenState extends State<WebsitesScreen> {
  bool _showOnlyFavorites = false;

  @override
  Widget build(BuildContext context) {
    final websiteService = Provider.of<WebsiteService>(context);
    final websites = websiteService.websites;

    // Filter websites if needed
    final displayedWebsites =
        _showOnlyFavorites
            ? websites.where((website) => website.isFavorite).toList()
            : websites;

    return Scaffold(
      appBar: AppBar(
        title: Text('Situs Rekomendasi'),
        actions: [
          // Toggle button to show favorites
          IconButton(
            icon: Icon(
              _showOnlyFavorites ? Icons.favorite : Icons.favorite_border,
              color: _showOnlyFavorites ? Colors.red : null,
            ),
            onPressed: () {
              setState(() {
                _showOnlyFavorites = !_showOnlyFavorites;
              });
            },
            tooltip: _showOnlyFavorites ? 'Tampilkan semua' : 'Hanya favorit',
          ),
        ],
      ),
      body:
          displayedWebsites.isEmpty
              ? Center(
                child:
                    _showOnlyFavorites
                        ? Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.favorite_border,
                              size: 64,
                              color: Colors.grey,
                            ),
                            SizedBox(height: 16),
                            Text(
                              'Belum ada situs favorit',
                              style: TextStyle(fontSize: 18),
                            ),
                            SizedBox(height: 24),
                            ElevatedButton.icon(
                              icon: Icon(Icons.list),
                              label: Text('Tampilkan semua situs'),
                              onPressed: () {
                                setState(() {
                                  _showOnlyFavorites = false;
                                });
                              },
                            ),
                          ],
                        )
                        : Text('Tidak ada situs tersedia'),
              )
              : ListView.builder(
                itemCount: displayedWebsites.length,
                itemBuilder: (context, index) {
                  final website = displayedWebsites[index];
                  return Card(
                    margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    elevation: 2,
                    child: ListTile(
                      contentPadding: EdgeInsets.all(8),
                      leading: CircleAvatar(
                        backgroundImage: NetworkImage(website.imageUrl),
                        radius: 25,
                      ),
                      title: Text(
                        website.name,
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(website.description),
                      trailing: IconButton(
                        icon: Icon(
                          website.isFavorite
                              ? Icons.favorite
                              : Icons.favorite_border,
                          color: website.isFavorite ? Colors.red : null,
                        ),
                        onPressed:
                            () => websiteService.toggleFavorite(website.id),
                      ),
                      onTap: () => websiteService.launchWebsite(website),
                    ),
                  );
                },
              ),
    );
  }
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthService()),
        ChangeNotifierProvider(create: (_) => WebsiteService()),
        Provider(create: (_) => LocationService()),
      ],
      child: MaterialApp(
        title: 'Aplikasi Kelompok',
        debugShowCheckedModeBanner: false,
        home: AuthWrapper(),
      ),
    );
  }
}

// Improved AuthWrapper that properly handles initialization
class AuthWrapper extends StatefulWidget {
  @override
  _AuthWrapperState createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  @override
  void initState() {
    super.initState();
    // Initialize auth on first load
    Future.microtask(() {
      final authService = Provider.of<AuthService>(context, listen: false);
      final websiteService = Provider.of<WebsiteService>(
        context,
        listen: false,
      );
      authService.autoLogin(websiteService);
    });
  }

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);

    // Show loading until initialization is complete
    if (!authService.isInitialized) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Loading...'),
            ],
          ),
        ),
      );
    }

    // After initialization, show the appropriate screen based on authentication state
    return authService.isAuthenticated ? HomeScreen() : LoginScreen();
  }
}

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    MainMenuScreen(),
    MembersScreen(),
    HelpScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context, listen: false);
    final websiteService = Provider.of<WebsiteService>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: Text('Aplikasi Kelompok'),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () => authService.logout(websiteService),
          ),
        ],
      ),
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.people), label: 'Anggota'),
          BottomNavigationBarItem(icon: Icon(Icons.help), label: 'Bantuan'),
        ],
        onTap: (index) => setState(() => _currentIndex = index),
      ),
    );
  }
}

class MainMenuScreen extends StatelessWidget {
  final List<Map<String, dynamic>> menuItems = [
    {'title': 'Stopwatch', 'icon': Icons.timer, 'screen': StopwatchScreen()},
    {
      'title': 'Jenis Bilangan',
      'icon': Icons.numbers,
      'screen': NumberTypeScreen(),
    },
    {
      'title': 'Tracking LBS',
      'icon': Icons.location_on,
      'screen': TrackingScreen(),
    },
    {
      'title': 'Konversi Waktu',
      'icon': Icons.access_time,
      'screen': TimeConversionScreen(),
    },
    {
      'title': 'Situs Rekomendasi',
      'icon': Icons.language,
      'screen': WebsitesScreen(),
    },
  ];

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: menuItems.length,
      itemBuilder: (context, index) {
        return Card(
          margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: ListTile(
            leading: Icon(menuItems[index]['icon']),
            title: Text(menuItems[index]['title']),
            onTap:
                () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => menuItems[index]['screen'],
                  ),
                ),
          ),
        );
      },
    );
  }
}

class MembersScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.all(16),
      children: [
        ListTile(
          leading: CircleAvatar(child: Text('D')),
          title: Text('Daniel Ridho'),
          subtitle: Text('Frontend Developer'),
        ),
        ListTile(
          leading: CircleAvatar(child: Text('H')),
          title: Text('Hadyan Baktiadi'),
          subtitle: Text('Backend Developer'),
        ),
        ListTile(
          leading: CircleAvatar(child: Text('J')),
          title: Text('Jovano Dion'),
          subtitle: Text('UI/UX Designer'),
        ),
      ],
    );
  }
}

class HelpScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Panduan Penggunaan Aplikasi',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 24),
          _buildHelpSection(
            context,
            icon: Icons.timer,
            title: 'Stopwatch',
            description:
                'Gunakan timer untuk menghitung waktu. Tekan tombol "Start" untuk memulai, "Stop" untuk menghentikan, dan "Reset" untuk mengatur ulang ke nol.',
          ),
          _buildHelpSection(
            context,
            icon: Icons.numbers,
            title: 'Jenis Bilangan',
            description:
                'Masukkan angka dan aplikasi akan menentukan jenis bilangan tersebut, seperti bilangan bulat, prima, negatif, atau desimal.',
          ),
          _buildHelpSection(
            context,
            icon: Icons.location_on,
            title: 'Tracking LBS',
            description:
                'Fitur ini akan menampilkan lokasi Anda saat ini pada peta. Tekan tombol "Dapatkan Lokasi" untuk memperbarui posisi Anda.',
          ),
          _buildHelpSection(
            context,
            icon: Icons.access_time,
            title: 'Konversi Waktu',
            description:
                'Masukkan jumlah tahun dan aplikasi akan mengonversinya ke hari, jam, menit, dan detik.',
          ),
          _buildHelpSection(
            context,
            icon: Icons.language,
            title: 'Situs Rekomendasi',
            description:
                'Telusuri daftar situs web yang direkomendasikan. Tekan pada situs untuk membukanya di browser. Tambahkan ke favorit dengan menekan ikon hati.',
          ),
          SizedBox(height: 24),
          Card(
            elevation: 2,
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Informasi Aplikasi',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Text('Versi: 1.0.0'),
                  Text('Dikembangkan oleh: Tim Kelompok'),
                  SizedBox(height: 16),
                  Text(
                    'Untuk bantuan lebih lanjut, silakan hubungi tim dukungan.',
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHelpSection(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Card(
      margin: EdgeInsets.only(bottom: 16),
      elevation: 2,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 36, color: Theme.of(context).primaryColor),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Text(description, style: TextStyle(fontSize: 14)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class StopwatchScreen extends StatefulWidget {
  @override
  _StopwatchScreenState createState() => _StopwatchScreenState();
}

class _StopwatchScreenState extends State<StopwatchScreen> {
  bool _isRunning = false;
  int _seconds = 0;
  late Timer _timer;

  String _formatTime(int seconds) {
    int hours = seconds ~/ 3600;
    int minutes = (seconds % 3600) ~/ 60;
    int secs = seconds % 60;
    return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    if (_isRunning) {
      _timer.cancel();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Stopwatch')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(_formatTime(_seconds), style: TextStyle(fontSize: 48)),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () {
                    if (_isRunning) {
                      _timer.cancel();
                    } else {
                      _timer = Timer.periodic(Duration(seconds: 1), (timer) {
                        setState(() => _seconds++);
                      });
                    }
                    setState(() => _isRunning = !_isRunning);
                  },
                  child: Text(_isRunning ? 'Stop' : 'Start'),
                ),
                SizedBox(width: 20),
                ElevatedButton(
                  onPressed: () => setState(() => _seconds = 0),
                  child: Text('Reset'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class NumberTypeScreen extends StatefulWidget {
  @override
  _NumberTypeScreenState createState() => _NumberTypeScreenState();
}

class _NumberTypeScreenState extends State<NumberTypeScreen> {
  final _numberController = TextEditingController();
  String _result = '';

  bool _isPrime(int n) {
    if (n <= 1) return false;
    for (int i = 2; i <= n / 2; i++) {
      if (n % i == 0) return false;
    }
    return true;
  }

  void _checkNumber() {
    final input = _numberController.text;
    if (input.isEmpty) return;

    final number = double.tryParse(input);
    if (number == null) {
      setState(() => _result = 'Input tidak valid');
      return;
    }

    List<String> types = [];

    if (number == number.toInt()) {
      types.add('Bilangan Bulat');
      if (number > 0) {
        types.add('Positif');
        if (_isPrime(number.toInt())) types.add('Prima');
      } else if (number < 0) {
        types.add('Negatif');
      }
    } else {
      types.add('Bilangan Desimal');
    }

    setState(() => _result = 'Jenis: ${types.join(', ')}');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Jenis Bilangan')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _numberController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: 'Masukkan bilangan'),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _checkNumber,
              child: Text('Cek Jenis Bilangan'),
            ),
            SizedBox(height: 16),
            Text(_result, style: TextStyle(fontSize: 18)),
          ],
        ),
      ),
    );
  }
}
