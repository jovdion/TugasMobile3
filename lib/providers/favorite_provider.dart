import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FavoriteProvider extends ChangeNotifier {
  Set<String> _favorites = {};

  Set<String> get favorites => _favorites;

  FavoriteProvider() {
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    _favorites = prefs.getStringList('favorites')?.toSet() ?? {};
    notifyListeners();
  }

  Future<void> toggleFavorite(String url) async {
    final prefs = await SharedPreferences.getInstance();
    if (_favorites.contains(url)) {
      _favorites.remove(url);
    } else {
      _favorites.add(url);
    }
    await prefs.setStringList('favorites', _favorites.toList());
    notifyListeners();
  }
}
