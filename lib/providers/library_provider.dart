import 'package:flutter/foundation.dart';
import '../models/library_model.dart';
import '../models/district.dart';
import '../services/database_service.dart';
import '../services/cache_service.dart';

class LibraryProvider extends ChangeNotifier {
  final DatabaseService _dbService;
  final CacheService _cacheService;

  List<LibraryModel> _libraries = [];
  List<LibraryModel> _filteredLibraries = [];
  District? _selectedDistrict;
  String _searchQuery = '';
  bool _isLoading = false;
  bool _isOffline = false;
  String? _error;
  DateTime? _lastUpdate;

  List<LibraryModel> get libraries => _libraries;
  List<LibraryModel> get filteredLibraries => _filteredLibraries;
  District? get selectedDistrict => _selectedDistrict;
  String get searchQuery => _searchQuery;
  bool get isLoading => _isLoading;
  bool get isOffline => _isOffline;
  String? get error => _error;
  DateTime? get lastUpdate => _lastUpdate;

  LibraryProvider({
    DatabaseService? dbService,
    CacheService? cacheService,
  })  : _dbService = dbService ?? DatabaseService(),
        _cacheService = cacheService ?? CacheService();

  Future<void> loadLibraries() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _libraries = await _dbService.getAllLibraries();
      _applyFilters();
      _isOffline = false;
      _lastUpdate = DateTime.now();
      // Сохраняем в кеш для офлайн-режима.
      await _cacheService.saveLibraries(_libraries);
    } catch (e) {
      _error = 'Ошибка загрузки библиотек: $e';
      // ignore: avoid_print
      print(_error);
      // Пробуем восстановить из кеша.
      try {
        final cached = await _cacheService.loadLibraries();
        if (cached.isNotEmpty) {
          _libraries = cached;
          _applyFilters();
          _isOffline = true;
          _lastUpdate = await _cacheService.lastUpdate();
        }
      } catch (cacheErr) {
        // ignore: avoid_print
        print('Кеш также недоступен: $cacheErr');
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> selectDistrict(District district) async {
    _selectedDistrict = district;
    _applyFilters();
    notifyListeners();
  }

  void clearFilter() {
    _selectedDistrict = null;
    _searchQuery = '';
    _applyFilters();
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    _applyFilters();
    notifyListeners();
  }

  void _applyFilters() {
    Iterable<LibraryModel> result = _libraries;
    if (_selectedDistrict != null) {
      result = result.where((l) => l.district == _selectedDistrict!.id);
    }
    if (_searchQuery.trim().isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      result = result.where((l) =>
          l.nameRu.toLowerCase().contains(q) ||
          l.nameEn.toLowerCase().contains(q) ||
          l.nameBe.toLowerCase().contains(q) ||
          l.addressRu.toLowerCase().contains(q) ||
          l.addressEn.toLowerCase().contains(q));
    }
    _filteredLibraries = result.toList();
  }

  Future<bool> addLibrary(LibraryModel library) async {
    try {
      await _dbService.insertLibrary(library);
      await loadLibraries();
      return true;
    } catch (e) {
      // ignore: avoid_print
      print('Ошибка добавления библиотеки: $e');
      _error = '$e';
      notifyListeners();
      return false;
    }
  }

  Future<bool> removeLibrary(int id) async {
    try {
      await _dbService.deleteLibrary(id);
      await loadLibraries();
      return true;
    } catch (e) {
      // ignore: avoid_print
      print('Ошибка удаления библиотеки: $e');
      _error = '$e';
      notifyListeners();
      return false;
    }
  }

  Future<void> clearCache() async {
    await _cacheService.clear();
    notifyListeners();
  }
}
