import 'package:path/path.dart';
import 'package:flutter/foundation.dart';
import 'dart:io';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    debugPrint('DATABASE INITIALIZATION: Opening SQLite database...');
    _database = await _initDB('memories.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    if (!kIsWeb && (Platform.isWindows || Platform.isLinux || Platform.isMacOS)) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }

    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 3,
      onConfigure: _onConfigure,
      onCreate: _createDB,
      onUpgrade: _upgradeDB,
    );
  }

  Future _onConfigure(Database db) async {
    // Add support for cascading deletes
    await db.execute('PRAGMA foreign_keys = ON');
  }

  Future _createDB(Database db, int version) async {
    debugPrint('DATABASE INITIALIZATION: Creating tables...');
    await db.execute('''
CREATE TABLE memories (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  title TEXT NOT NULL,
  description TEXT NOT NULL,
  date TEXT NOT NULL,
  latitude REAL,
  longitude REAL,
  locationName TEXT,
  category TEXT NOT NULL,
  mood TEXT NOT NULL,
  isFavorite INTEGER NOT NULL,
  createdAt TEXT NOT NULL,
  updatedAt TEXT NOT NULL
)
''');

    await db.execute('''
CREATE TABLE memory_photos (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  memoryId INTEGER NOT NULL,
  imagePath TEXT NOT NULL,
  createdAt TEXT NOT NULL,
  FOREIGN KEY (memoryId) REFERENCES memories (id) ON DELETE CASCADE
)
''');
  }

  Future _upgradeDB(Database db, int oldVersion, int newVersion) async {
    debugPrint('DATABASE INITIALIZATION: Upgrading database from $oldVersion to $newVersion...');
    if (oldVersion < 2) {
      // For migrating from String ID to Auto-increment INTEGER ID
      await db.execute('DROP TABLE IF EXISTS memory_photos');
      await db.execute('DROP TABLE IF EXISTS memories');
      await _createDB(db, newVersion);
    } else if (oldVersion < 3) {
      // For adding memory_photos table
      await db.execute('''
CREATE TABLE IF NOT EXISTS memory_photos (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  memoryId INTEGER NOT NULL,
  imagePath TEXT NOT NULL,
  createdAt TEXT NOT NULL,
  FOREIGN KEY (memoryId) REFERENCES memories (id) ON DELETE CASCADE
)
''');
    }
  }

  Future<void> close() async {
    final db = await instance.database;
    db.close();
  }
}

