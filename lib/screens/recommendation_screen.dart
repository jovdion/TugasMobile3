import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RecommendationScreen extends StatefulWidget {
  @override
  _RecommendationScreenState createState() => _RecommendationScreenState();
}

class _RecommendationScreenState extends State<RecommendationScreen> {
  // Daftar situs rekomendasi — tambahkan atau ubah sesuai kebutuhan
  final List<Site> sites = const [
    Site(
      title: 'Flutter',
      url: 'https://flutter.dev',
      imgUrl: 'https://storage.googleapis.com/cms-storage-bucket/6e19fee6b47b36ca613f.png',
    ),
    Site(
      title: 'Dart',
      url: 'https://dart.dev',
      imgUrl: 'https://dart.dev/assets/shared/dart-logo-for-shares.png?2',
    ),
    Site(
      title: 'pub.dev',
      url: 'https://pub.dev',
      imgUrl: 'https://pub.dev/static/hash-5weehz3o/img/pub-dev-logo-cover-image.png',
    ),
  ];

  Set<String> _favorites = {};

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _favorites = prefs.getStringList('favorites')?.toSet() ?? {};
    });
  }

  Future<void> _toggleFavorite(String url) async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      if (_favorites.contains(url)) {
        _favorites.remove(url);
      } else {
        _favorites.add(url);
      }
      prefs.setStringList('favorites', _favorites.toList());
    });
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Gagal membuka link')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Rekomendasi Situs'),
      ),
      body: ListView.builder(
        itemCount: sites.length,
        itemBuilder: (context, index) {
          final site = sites[index];
          final isFav = _favorites.contains(site.url);
          return Card(
            margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            elevation: 3,
            child: ListTile(
              contentPadding: EdgeInsets.all(12),
              leading: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  site.imgUrl,
                  width: 50,
                  height: 50,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Icon(Icons.language, size: 40),
                ),
              ),
              title: Text(site.title, style: TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text(site.url, style: TextStyle(fontSize: 12, color: Colors.blue)),
              trailing: IconButton(
                icon: Icon(isFav ? Icons.favorite : Icons.favorite_border,
                    color: isFav ? Colors.red : null),
                onPressed: () => _toggleFavorite(site.url),
              ),
              onTap: () => _launchUrl(site.url),
            ),
          );
        },
      ),
    );
  }
}

class Site {
  final String title;
  final String url;
  final String imgUrl;
  const Site({
    required this.title,
    required this.url,
    required this.imgUrl,
  });
}
