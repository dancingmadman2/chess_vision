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
  // ... other fields ...

  Puzzle({
    required this.puzzleId,
    required this.fen,
    required this.moves,
    required this.rating,
  });

  Map<String, dynamic> toMap() {
    return {
      'puzzleId': puzzleId,
      'fen': fen,
      'moves': moves,
      'rating': rating,
    };
  }
}

String _dbName = 'Puzzles.db';
// Create the database tables
void createDatabase(Database db) {
  db.execute('''
  CREATE TABLE Puzzles(
  puzzleId TEXT PRIMARY KEY,
  fen TEXT,
  moves TEXT,
  rating INTEGER
    )
  ''');
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
