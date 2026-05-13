import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/library_model.dart';

class DatabaseService {
  static Database? _database;
  static const String _tableName = 'libraries';

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    try {
      final dbPath = await getDatabasesPath();
      final path = join(dbPath, 'minsk_libraries.db');

      final isNew = !await databaseExists(path);

      final db = await openDatabase(
        path,
        version: 1,
        onCreate: _onCreate,
      );

      if (isNew) {
        await _loadInitialData(db);
      }

      return db;
    } catch (e) {
      print('Ошибка инициализации БД: $e');
      rethrow;
    }
  }

  Future<void> _onCreate(Database db, int version) async {
    try {
      await db.execute('''
        CREATE TABLE $_tableName (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          name_ru TEXT NOT NULL,
          name_en TEXT NOT NULL,
          name_be TEXT NOT NULL,
          address_ru TEXT NOT NULL,
          address_en TEXT NOT NULL,
          address_be TEXT NOT NULL,
          district TEXT NOT NULL,
          latitude REAL NOT NULL,
          longitude REAL NOT NULL,
          phone TEXT DEFAULT '',
          website TEXT DEFAULT '',
          working_hours TEXT DEFAULT ''
        )
      ''');
    } catch (e) {
      print('Ошибка создания таблицы: $e');
      rethrow;
    }
  }

  Future<void> _loadInitialData(Database db) async {
    try {
      final jsonString = await rootBundle.loadString('assets/libraries.json');
      final List<dynamic> jsonData = json.decode(jsonString);

      final batch = db.batch();
      for (final item in jsonData) {
        batch.insert(_tableName, Map<String, dynamic>.from(item));
      }
      await batch.commit(noResult: true);
      print('Загружено ${jsonData.length} библиотек в БД');
    } catch (e) {
      print('Ошибка загрузки начальных данных: $e');
    }
  }

  Future<List<LibraryModel>> getAllLibraries() async {
    try {
      final db = await database;
      final maps = await db.query(_tableName);
      return maps.map((map) => LibraryModel.fromMap(map)).toList();
    } catch (e) {
      print('Ошибка получения всех библиотек: $e');
      return [];
    }
  }

  Future<List<LibraryModel>> getLibrariesByDistrict(String district) async {
    try {
      final db = await database;
      final maps = await db.query(
        _tableName,
        where: 'district = ?',
        whereArgs: [district],
      );
      return maps.map((map) => LibraryModel.fromMap(map)).toList();
    } catch (e) {
      print('Ошибка получения библиотек по району: $e');
      return [];
    }
  }

  Future<LibraryModel?> getLibraryById(int id) async {
    try {
      final db = await database;
      final maps = await db.query(
        _tableName,
        where: 'id = ?',
        whereArgs: [id],
      );
      if (maps.isNotEmpty) {
        return LibraryModel.fromMap(maps.first);
      }
      return null;
    } catch (e) {
      print('Ошибка получения библиотеки по ID: $e');
      return null;
    }
  }

  Future<int> insertLibrary(LibraryModel library) async {
    try {
      final db = await database;
      return await db.insert(_tableName, library.toMap());
    } catch (e) {
      print('Ошибка добавления библиотеки: $e');
      return -1;
    }
  }

  Future<int> updateLibrary(LibraryModel library) async {
    try {
      final db = await database;
      return await db.update(
        _tableName,
        library.toMap(),
        where: 'id = ?',
        whereArgs: [library.id],
      );
    } catch (e) {
      print('Ошибка обновления библиотеки: $e');
      return 0;
    }
  }

  Future<int> deleteLibrary(int id) async {
    try {
      final db = await database;
      return await db.delete(
        _tableName,
        where: 'id = ?',
        whereArgs: [id],
      );
    } catch (e) {
      print('Ошибка удаления библиотеки: $e');
      return 0;
    }
  }

  Future<void> close() async {
    final db = await database;
    db.close();
    _database = null;
  }
}
