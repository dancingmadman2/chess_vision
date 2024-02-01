import 'package:chess_vision/styles.dart';
import 'package:csv/csv.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';

// Define the data model
class Puzzle {
  final dynamic puzzleId;
  final String fen;
  final String moves;
  final int rating;
  final String? toMove;

  // ... other fields ...

  Puzzle({
    required this.puzzleId,
    required this.fen,
    required this.moves,
    required this.rating,
    this.toMove,
  });

  Map<String, dynamic> toMap() {
    return {
      'puzzleId': puzzleId,
      'fen': fen,
      'moves': moves,
      'rating': rating,
      'toMove': toMove
    };
  }
}

class User {
  final int uid;
  final int rating;
  final int puzzlesPlayed;
  final int puzzlesWon;

  User({
    required this.uid,
    required this.rating,
    required this.puzzlesPlayed,
    required this.puzzlesWon,
  });

  Map<String, dynamic> toMap() {
    return {
      'userId': uid,
      'rating': rating,
      'puzzlesPlayed': puzzlesPlayed,
      'puzzlesWon': puzzlesWon
    };
  }
}

const String _dbName = 'Database.db';
// Create the database tables
void createDatabase(Database db) {
  // Create table for puzzles
  db.execute('''
  CREATE TABLE Puzzles(
  puzzleId TEXT PRIMARY KEY,
  fen TEXT,
  moves TEXT,
  rating INTEGER,
  solved INTEGER DEFAULT 0
    )
  ''');

  // Create the UserStats table
  db.execute('''
    CREATE TABLE UserStats(
      id INTEGER PRIMARY KEY,
      rating INTEGER,
      gamesPlayed INTEGER,
      gamesWon INTEGER
    )
  ''');
  insertUserStats(1000, 0, 0);
}

Future<User?> getUserStats() async {
  final dbPath = await getDatabasePath();
  final db = await openDatabase(dbPath);
  final List<Map<String, dynamic>> maps =
      await db.query('UserStats', where: 'id = ?', whereArgs: [1]);
  if (maps.isNotEmpty) {
    final user = User(
        uid: maps[0]['id'],
        rating: maps[0]['rating'],
        puzzlesPlayed: maps[0]['gamesPlayed'],
        puzzlesWon: maps[0]['gamesWon']);

    return user;
  }
  return null;
}

Future<Puzzle?> getPuzzle(String puzzleId) async {
  final dbPath = await getDatabasePath();
  final db = await openDatabase(dbPath);
  final List<Map<String, dynamic>> maps = await db.query(
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
      // ... other fields ...
    );

    return puzzle;
  }
  return null;
}

Future<void> insertUserStats(int rating, int gamesPlayed, int gamesWon) async {
  final dbPath = await getDatabasePath();
  final db = await openDatabase(dbPath);
  await db.insert('UserStats', {
    'id': 1,
    'rating': rating,
    'gamesPlayed': gamesPlayed,
    'gamesWon': gamesWon
  });
}

Future<void> updateUserRating(int newRating) async {
  final dbPath = await getDatabasePath();
  final db = await openDatabase(dbPath);
  await db.update('UserStats', {'rating': newRating},
      where: 'id = ?', whereArgs: [1]);
}

// Read and parse the CSV file
Future<void> loadCsvData() async {
  final String csvData = await rootBundle.loadString('assets/data/subset.csv');
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
      // ... other fields ...
    );

    puzzles.add(puzzle);
  }
  await insertPuzzlesInBatch(puzzles); // Insert puzzles in batch
}

Future<String> getDatabasePath() async {
  final directory = await getApplicationDocumentsDirectory();
  return join(directory.path, _dbName);
}

Future<void> insertPuzzlesInBatch(List<Puzzle> puzzles) async {
  final dbPath = await getDatabasePath();
  final Database db = await openDatabase(dbPath);

  await db.transaction((txn) async {
    for (var puzzle in puzzles) {
      await txn.insert(
        'puzzles',
        puzzle.toMap(),
        conflictAlgorithm:
            ConflictAlgorithm.ignore, // Handles duplicate entries
      );
    }
  });
}

// Manage database state
Future<void> initializeDatabase() async {
  final prefs = await SharedPreferences.getInstance();
  final String dbPath = await getDatabasePath();

  if (prefs.getBool('isDatabaseInitialized') == null ||
      prefs.getBool('isDatabaseInitialized') == false) {
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
    openDatabase(dbPath).then((db) {
      createDatabase(db);
      loadCsvData().then((_) {
        // Dismiss the SnackBar
        Get.back();

        prefs.setBool('isDatabaseInitialized', true);
      });
    });
    /*
    final Database db = await openDatabase(dbPath);
    createDatabase(db);
    loadCsvData();

    prefs.setBool('isDatabaseInitialized', true);*/
  }
}
