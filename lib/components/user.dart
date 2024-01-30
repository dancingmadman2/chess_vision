import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class User {
  final int id;
  final int rating;
  // Add other chess metrics as needed

  User({required this.id, required this.rating});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'rating': rating,
      // Map other metrics
    };
  }
}

const String _dbName = 'User.db';

Future<String> getDatabasePath() async {
  final directory = await getApplicationDocumentsDirectory();
  return join(directory.path, _dbName);
}

void createDatabase(Database db) {
  db.execute('''
    CREATE TABLE user_stats(
      id INTEGER PRIMARY KEY,
      rating INTEGER,
      puzzlesPlayed INTEGER,
      puzzlesCorrect INTEGER,
    )
  ''');
  // Initialize with default values
  db.insert('user_stats',
      {'id': 1, 'rating': 1000, 'puzzlesPlayed': 0, 'puzzlesCorrect': 0});
}

Future<void> updateUserRating(int newRating) async {
  final dbPath = await getDatabasePath();
  final db = await openDatabase(dbPath);

  await db.update(
    'user_stats',
    {'rating': newRating},
    where: 'id = ?',
    whereArgs: [1], // Assuming the ID is always 1
  );
}

Future<Map<String, dynamic>> getUserStats() async {
  final dbPath = await getDatabasePath();
  final db = await openDatabase(dbPath);
  final List<Map<String, dynamic>> maps =
      await db.query('user_stats', where: 'id = ?', whereArgs: [1]);
  return maps.first;
}
