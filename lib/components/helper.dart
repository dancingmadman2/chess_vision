import 'package:chess_vision/components/database.dart';
import 'package:chess_vision/styles.dart';
import 'package:csv/csv.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class Puzzle {
  final dynamic puzzleId;
  final String fen;
  final String moves;
  final int rating;
  final String theme;
  final String toMove;
  final String pgn;

  // ... other fields ...

  Puzzle({
    required this.puzzleId,
    required this.fen,
    required this.moves,
    required this.rating,
    required this.theme,
    required this.toMove,
    required this.pgn,
  });

  Map<String, dynamic> toMap() {
    return {
      'puzzleId': puzzleId,
      'fen': fen,
      'moves': moves,
      'rating': rating,
      'theme': theme,
      'toMove': toMove,
      'pgn': pgn
    };
  }
}

class User {
  final int uid;
  final int rating;
  final int puzzlesPlayed;
  final int puzzlesWon;
  final int puzzlesLost;

  User({
    required this.uid,
    required this.rating,
    required this.puzzlesPlayed,
    required this.puzzlesLost,
    required this.puzzlesWon,
  });

  Map<String, dynamic> toMap() {
    return {
      'userId': uid,
      'rating': rating,
      'puzzlesPlayed': puzzlesPlayed,
      'puzzlesWon': puzzlesWon,
      'puzzlesLost': puzzlesLost
    };
  }
}

class DatabaseHelper {
  static Database? _database;
  final _dbName = 'keshpopo.db';
  final _version = 3;

  //Future<Database> get database async => _database ??= await _initDatabase();

  Future<void> initializeDatabase() async {
    if (_database == null) {
      final dbPath = await getDatabasesPath();
      final path = join(dbPath, _dbName);
      _database = await openDatabase(path, version: _version,
          onCreate: (db, version) async {
        dbInitSnackbar();
        await createDatabase(db);

        loadCsvData().then((_) => Get.back());
      }, onUpgrade: ((db, oldVersion, newVersion) {
        dbUpgradeSnackbar();
        loadCsvData().then((_) => Get.back);
      }));
    }
  }

  Future<void> createDatabase(Database db) async {
    // Create table for puzzles
    db.execute('''
  CREATE TABLE Puzzles(
  puzzleId TEXT PRIMARY KEY,
  fen TEXT,
  moves TEXT,
  toMove TEXT,
  rating INTEGER,
  theme TEXT,
  solved INTEGER DEFAULT 0,
  pgn TEXT
    )
  ''');

    // Create the UserStats table
    db.execute('''
    CREATE TABLE UserStats(
      id INTEGER PRIMARY KEY,
      rating INTEGER,
      puzzlesPlayed INTEGER,
      puzzlesWon INTEGER,
      puzzlesLost INTEGER
    )
  ''');
    db.rawInsert('''
        INSERT INTO UserStats(id, rating, puzzlesPlayed, puzzlesWon, puzzlesLost)
        VALUES(?, ?, ?, ?, ?)
      ''', [1, 1000, 0, 0, 0]); // setting initial values
  }

  Future<void> loadCsvData() async {
    final String csvData =
        await rootBundle.loadString('assets/data/subset_updated_final.csv');
    final List<List<dynamic>> rowsAsListOfValues =
        const CsvToListConverter().convert(csvData);

    List<Puzzle> puzzles = [];
    for (int i = 1; i < rowsAsListOfValues.length; i++) {
      final row = rowsAsListOfValues[i];

      final Puzzle puzzle = Puzzle(
          puzzleId: row[0],
          fen: row[1],
          moves: row[2],
          rating: row[3],
          theme: row[6],
          toMove: row[9],
          pgn: row[8]

          // ... other fields ...
          );

      puzzles.add(puzzle);
    }
    await insertPuzzlesInBatch(puzzles); // Insert puzzles in batch
  }

  Future<void> insertPuzzlesInBatch(List<Puzzle> puzzles) async {
    await initializeDatabase();

    await _database?.transaction((txn) async {
      var batch = txn.batch();

      for (var puzzle in puzzles) {
        batch.insert(
          'puzzles',
          puzzle.toMap(),
          conflictAlgorithm: ConflictAlgorithm.ignore,
        );
      }

      await batch.commit();
    });
  }

  Future<String> getDatabasePath() async {
    final directory = await getApplicationDocumentsDirectory();
    return join(directory.path, _dbName);
  }

  Future<void> insertUserStats(
      int rating, int puzzlesPlayed, int puzzlesWon, int puzzlesLost) async {
    await initializeDatabase();
    await _database?.insert('UserStats', {
      'id': 1,
      'rating': rating,
      'puzzlesPlayed': puzzlesPlayed,
      'puzzlesWon': puzzlesWon,
      'puzzlesLost': puzzlesLost
    });
  }

  Future<User?> getUserStats() async {
    await initializeDatabase();
    final List<Map<String, dynamic>> maps =
        await _database!.query('UserStats', where: 'id = ?', whereArgs: [1]);
    if (maps.isNotEmpty) {
      final user = User(
        uid: maps[0]['id'],
        rating: maps[0]['rating'],
        puzzlesPlayed: maps[0]['puzzlesPlayed'],
        puzzlesWon: maps[0]['puzzlesWon'],
        puzzlesLost: maps[0]['puzzlesLost'],
      );

      return user;
    }
    return null;
  }

  Future<void> updateUserRating(int newRating) async {
    await _database?.update('UserStats', {'rating': newRating},
        where: 'id = ?', whereArgs: [1]);
  }

  Future<Puzzle?> getPuzzle(String puzzleId) async {
    final List<Map<String, dynamic>> maps = await _database!.query(
      'puzzles',
      where: 'puzzleId = ?',
      whereArgs: [puzzleId],
    );
    if (maps.isNotEmpty) {
      // ... create and return Puzzle object ...
      final puzzle = Puzzle(
          puzzleId: maps[0]['puzzleId'],
          fen: maps[0]['fen'],
          moves: maps[0]['moves'],
          rating: maps[0]['rating'],
          theme: maps[0]['theme'],
          toMove: maps[0]['toMove'],
          pgn: maps[0]['pgn']

          // ... other fields ...
          );

      return puzzle;
    }
    return null;
  }

  Future<void> updateUserStats(int puzzlesPlayed, int puzzlesWon) async {
    await _database?.update(
        'UserStats', {'puzzlesPlayed': puzzlesPlayed, 'puzzlesWon': puzzlesWon},
        where: 'id = ?', whereArgs: [1]);
  }

  Future<void> updateSolved(String puzzleId) async {
    await _database?.update(
      'Puzzles',
      {'solved': 1}, // Set solved to 1
      where: 'puzzleId = ?',
      whereArgs: [puzzleId],
    );
  }

  Future<Puzzle?> getPuzzleByRating() async {
    int userRating = -1;
    var userStats = await getUserStats();
    if (userStats != null) {
      userRating = userStats.rating;
    }
    final prefs = await SharedPreferences.getInstance();

    String? currentPuzzleId = prefs.getString('currentPuzzleId');
    String whereClause = 'rating >= ? AND rating <= ? AND solved = 0';
    List<dynamic> whereArgs = [];

    if (userRating > 980) {
      whereArgs = [userRating - 50, userRating + 50];
    } else {
      whereArgs = [1000, 1050];
    }

    // Exclude the current puzzle ID if it exists
    if (currentPuzzleId != null) {
      whereClause += ' AND puzzleId != ?';
      whereArgs.add(currentPuzzleId);
    }

    final List<Map<String, dynamic>> maps = await _database!.query(
      'puzzles',
      where: whereClause,
      whereArgs: whereArgs,
      orderBy: 'RANDOM()',
      limit: 1,
    );
    if (maps.isNotEmpty) {
      final puzzle = Puzzle(
          puzzleId: maps[0]['puzzleId'],
          fen: maps[0]['fen'],
          moves: maps[0]['moves'],
          rating: maps[0]['rating'],
          theme: maps[0]['theme'],
          toMove: maps[0]['toMove'],
          pgn: maps[0]['pgn']

          // ... other fields ...
          );
      prefs.setString('currentPuzzleId', puzzle.puzzleId);

      return puzzle;
    }
    return null;
  }
}

void dbInitSnackbar() {
  WidgetsBinding.instance.addPostFrameCallback((_) async {
    Get.rawSnackbar(
        messageText: Text(
          'Database initializing for the first time...',
          textAlign: TextAlign.center,
          style: defText,
        ),
        isDismissible: false,
        duration: const Duration(days: 1),
        backgroundColor: mono,
        borderRadius: 8,
        icon: const Icon(
          Icons.downloading_rounded,
          color: Colors.white,
        ),
        margin: const EdgeInsets.only(bottom: 65),
        snackStyle: SnackStyle.GROUNDED);
  });
}
