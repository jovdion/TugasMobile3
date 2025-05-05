import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RecommendationScreen extends StatefulWidget {
  const RecommendationScreen({Key? key}) : super(key: key);

  @override
  _RecommendationScreenState createState() => _RecommendationScreenState();
}

class _RecommendationScreenState extends State<RecommendationScreen> with SingleTickerProviderStateMixin {
  // Daftar situs rekomendasi — tambahkan atau ubah sesuai kebutuhan
  final List<Site> sites = const [
    Site(
      title: 'Flutter',
      url: 'https://flutter.dev',
      imgUrl: 'https://storage.googleapis.com/cms-storage-bucket/6e19fee6b47b36ca613f.png',
      description: 'Framework UI untuk membuat aplikasi native untuk mobile, web, dan desktop dari codebase yang sama',
    ),
    Site(
      title: 'Dart',
      url: 'https://dart.dev',
      imgUrl: 'https://dart.dev/assets/shared/dart-logo-for-shares.png?2',
      description: 'Bahasa pemrograman yang dioptimalkan untuk aplikasi dengan performa dan fleksibilitas tinggi',
    ),
    Site(
      title: 'pub.dev',
      url: 'https://pub.dev',
      imgUrl: 'https://pub.dev/static/hash-5weehz3o/img/pub-dev-logo-cover-image.png',
      description: 'Repositori paket untuk aplikasi Flutter dan Dart yang dikelola oleh komunitas',
    ),
    Site(
      title: 'Google maps',
      url: 'https://maps.google.com',
      imgUrl: 'https://w7.pngwing.com/pngs/8/868/png-transparent-google-maps-hd-logo.png',
      description: 'Platform untuk menampilkan dan mencari lokasi yang paling diandalkan untuk saat ini',
    ),
    Site(
      title: 'Google',
      url: 'https://google.com',
      imgUrl: 'https://cdn.imgbin.com/5/1/2/imgbin-google-logo-g-suite-google-search-chrome-EcAGrdDu8ifPFwERsNhwqpLiT.jpg',
      description: 'Platform untuk mencari segala sesuatu di internet',
    ),
    Site(
      title: 'Visual studio code',
      url: 'https://code.visualstudio.com',
      imgUrl: 'https://logowik.com/content/uploads/images/visual-studio-code7642.jpg',
      description: 'Aplikasi untuk membuat kode yang banyak digunakan',
    ),
    Site(
      title: 'Roblox',
      url: 'https://www.roblox.com',
      imgUrl: 'https://upload.wikimedia.org/wikipedia/commons/7/7e/Roblox_Logo_2022.jpg',
      description: 'Platform game yang sangat seru untuk dimainkan',
    ),
  ];

  Set<String> _favorites = {};
  late TabController _tabController;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    setState(() {
      _isLoading = true;
    });
    
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _favorites = prefs.getStringList('favorites')?.toSet() ?? {};
      _isLoading = false;
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
    try {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Gagal membuka link'),
            behavior: SnackBarBehavior.floating,
          )
        );
      }
    }
  }

  // Mendapatkan situs berdasarkan URL
  Site? _getSiteByUrl(String url) {
    try {
      return sites.firstWhere((site) => site.url == url);
    } catch (e) {
      return null;
    }
  }

  // Mendapatkan daftar situs favorit
  List<Site> _getFavoriteSites() {
    final List<Site> favSites = [];
    for (var url in _favorites) {
      final site = _getSiteByUrl(url);
      if (site != null) {
        favSites.add(site);
      }
    }
    return favSites;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Rekomendasi Situs',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Theme.of(context).primaryColor,
          labelColor: Theme.of(context).primaryColor,
          unselectedLabelColor: Colors.grey[600],
          tabs: const [
            Tab(
              text: 'Semua Situs',
              icon: Icon(Icons.language),
            ),
            Tab(
              text: 'Favorit',
              icon: Icon(Icons.favorite),
            ),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                // Tab semua situs
                _buildSiteList(sites),

                // Tab situs favorit
                _buildFavoritesList(),
              ],
            ),
    );
  }

  Widget _buildSiteList(List<Site> siteList) {
    if (siteList.isEmpty) {
      return const Center(
        child: Text(
          'Tidak ada situs untuk ditampilkan',
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: siteList.length,
      itemBuilder: (context, index) {
        final site = siteList[index];
        final isFav = _favorites.contains(site.url);
        
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.2),
                spreadRadius: 1,
                blurRadius: 6,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(16),
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () => _launchUrl(site.url),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Site image
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        width: 80,
                        height: 80,
                        color: Colors.grey[100],
                        child: Image.network(
                          site.imgUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Icon(
                            Icons.language,
                            size: 40,
                            color: Colors.grey[400],
                          ),
                        ),
                      ),
                    ),
                    
                    const SizedBox(width: 16),
                    
                    // Site info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            site.title,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            site.url,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.blue[700],
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            site.description,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(width: 8),
                    
                    // Favorite button
                    IconButton(
                      icon: Icon(
                        isFav ? Icons.favorite : Icons.favorite_border,
                        color: isFav ? Colors.red : Colors.grey,
                        size: 28,
                      ),
                      onPressed: () => _toggleFavorite(site.url),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildFavoritesList() {
    final favoriteSites = _getFavoriteSites();
    
    if (favoriteSites.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.favorite_border,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'Belum ada situs favorit',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Tambahkan situs ke favorit dengan mengetuk ikon hati',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: favoriteSites.length,
      itemBuilder: (context, index) {
        final site = favoriteSites[index];
        
        return Dismissible(
          key: Key(site.url),
          direction: DismissDirection.endToStart,
          background: Container(
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 20),
            decoration: BoxDecoration(
              color: Colors.red,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.delete,
              color: Colors.white,
              size: 30,
            ),
          ),
          onDismissed: (_) => _toggleFavorite(site.url),
          child: Container(
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  spreadRadius: 1,
                  blurRadius: 6,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(16),
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () => _launchUrl(site.url),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Site image
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          width: 80,
                          height: 80,
                          color: Colors.grey[100],
                          child: Image.network(
                            site.imgUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Icon(
                              Icons.language,
                              size: 40,
                              color: Colors.grey[400],
                            ),
                          ),
                        ),
                      ),
                      
                      const SizedBox(width: 16),
                      
                      // Site info
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              site.title,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              site.url,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.blue[700],
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              site.description,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      
                      const SizedBox(width: 8),
                      
                      // Unlike button
                      IconButton(
                        icon: const Icon(
                          Icons.favorite,
                          color: Colors.red,
                          size: 28,
                        ),
                        onPressed: () => _toggleFavorite(site.url),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}

class Site {
  final String title;
  final String url;
  final String imgUrl;
  final String description;
  
  const Site({
    required this.title,
    required this.url,
    required this.imgUrl,
    required this.description,
  });
}
