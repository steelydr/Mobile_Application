// favourites_store.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '/services/db_helper.dart';

class FavouritesStore extends ChangeNotifier {
  List<Map<String, dynamic>> results = [];
  List ids = [];
  DBHelper dbHelper = DBHelper();
  final String _prefsKey = 'favorites_ids';
  late SharedPreferences _prefs;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    await _loadFromPrefs();
    await retriveDB();
  }

  List<Map<String, dynamic>> get Results => results;
  List get Ids => ids;

  Future<void> _loadFromPrefs() async {
    ids = _prefs.getStringList(_prefsKey) ?? [];
  }

  Future<void> _saveToPrefs() async {
    List<String> stringIds = ids.map((id) => id.toString()).toList();
    await _prefs.setStringList(_prefsKey, stringIds);
  }

  Future<void> retriveDB() async {
    results = await dbHelper.query('favourites');
    ids = results.map((e) => e['id']).toList();
    await _saveToPrefs();
    notifyListeners();
  }

  Future<void> addFavorite(Map<String, dynamic> article) async {
    await dbHelper.insertFavourites('favourites', article);
    await retriveDB();
  }

  Future<void> removeFavorite(String id) async {
    await dbHelper.deleteFavourites(id); // Fixed: removed the table name argument
    await retriveDB();
  }

  Future<void> clearFavorites() async {
    for (var id in ids) {
      await dbHelper.deleteFavourites(id); // Need to delete each favorite individually
    }
    await _prefs.remove(_prefsKey);
    results = [];
    ids = [];
    notifyListeners();
  }
}