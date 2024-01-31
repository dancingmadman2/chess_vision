import 'package:chess_vision/components/database.dart';
import 'package:chess_vision/screens/puzzles/components/puzzle_with_stats.dart';
import 'package:chess_vision/styles.dart';
import 'package:flutter/cupertino.dart';

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show defaultTargetPlatform;

import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';

class CombinedPuzzles extends StatefulWidget {
  const CombinedPuzzles({super.key});

  @override
  State<CombinedPuzzles> createState() => _CombinedPuzzlesState();
}

class _CombinedPuzzlesState extends State<CombinedPuzzles> {
  final TextEditingController _controller = TextEditingController();
  late Future _future;

  Future<void> markPuzzleAsSolved(String puzzleId) async {
    int userRating = -1;

    // fetch the user rating
    var userStats = await getUserStats();
    if (userStats != null) {
      userRating = userStats.rating;
    }

    final prefs = await SharedPreferences.getInstance();
    final dbPath = await getDatabasePath();
    final db = await openDatabase(dbPath);

    // mark it as solved in the sql table
    await db.update(
      'Puzzles',
      {'solved': 1}, // Set solved to 1
      where: 'puzzleId = ?',
      whereArgs: [puzzleId],
    );

    // updating user rating
    updateUserRating(userRating + 13);

    // removing the sharedpref tag so that new puzzles can be generated
    setState(() {
      prefs.remove('currentPuzzleId');
    });
  }

/*
  Future<Puzzle?> getPuzzle() async {
    final prefs = await SharedPreferences.getInstance();
    String? currentPuzzleId = prefs.getString('currentPuzzleId');

    if (currentPuzzleId == null) {
      // Fetch a new random puzzle
      return await getPuzzleByRating();
    } else {
      // Fetch the puzzle with the stored ID
      return await getPuzzleById(currentPuzzleId);
    }
  }*/

  Future<PuzzleWithUserStats> getPuzzleWithStats() async {
    final prefs = await SharedPreferences.getInstance();
    String? currentPuzzleId = prefs.getString('currentPuzzleId');
    User? user;
    Puzzle? puzzle;

    if (currentPuzzleId == null) {
      puzzle = await getPuzzleByRating(); // Fetch a new random puzzle
    } else {
      puzzle = await getPuzzleById(
          currentPuzzleId); // Fetch the puzzle with the stored ID
    }

    user = await getUserStats(); // Get user stats

    return PuzzleWithUserStats(puzzle: puzzle, userStats: user);
  }

  Future<Puzzle?> getPuzzleById(String puzzleId) async {
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

  Future<Puzzle?> getPuzzleByRating() async {
    int userRating = -1;
    var userStats = await getUserStats();
    if (userStats != null) {
      userRating = userStats.rating;
    }
    final prefs = await SharedPreferences.getInstance();
    final dbPath = await getDatabasePath();
    final db = await openDatabase(dbPath);

    String? currentPuzzleId = prefs.getString('currentPuzzleId');
    String whereClause = 'rating >= ? AND rating <= ? AND solved = 0';
    List<dynamic> whereArgs = [userRating - 50, userRating + 50];

    // Exclude the current puzzle ID if it exists
    if (currentPuzzleId != null) {
      whereClause += ' AND puzzleId != ?';
      whereArgs.add(currentPuzzleId);
    }

    final List<Map<String, dynamic>> maps = await db.query(
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
        // ... other fields ...
      );
      prefs.setString('currentPuzzleId', puzzle.puzzleId);

      return puzzle;
    }
    return null;
  }

  @override
  void initState() {
    super.initState();
    _future = getPuzzleWithStats();
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: primary,
      appBar: AppBar(
        backgroundColor: primary,
        leading: InkWell(
            borderRadius: BorderRadius.circular(8),
            onTap: () => Navigator.pop(context),
            child: const Icon(
              CupertinoIcons.back,
              color: Colors.white,
            )),
        title: Text(
          'Combined Puzzles',
          style: appbarTitle,
          textAlign: TextAlign.center,
        ),
        centerTitle: true,
      ),
      body: FutureBuilder(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
                child: defaultTargetPlatform == TargetPlatform.android
                    ? const CircularProgressIndicator(
                        color: Colors.white,
                      )
                    : const CupertinoActivityIndicator(
                        color: Colors.white,
                      ));
          } else if (snapshot.hasError) {
            return Center(
                child: Text(
              'Error: ${snapshot.error}',
              style: defText,
            ));
          } else {
            // Print the first puzzle's details to the console
            //print('First puzzle: ${snapshot.data?.first.toMap()}');
            final Puzzle sand = snapshot.data!.puzzle!;
            final User stats = snapshot.data!.userStats!;
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '${stats.rating}',
                    style: subtitle,
                  ),
                  const SizedBox(
                    height: 50,
                  ),
                  Text(
                    sand.puzzleId,
                    style: defText,
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                  SizedBox(
                    width: screenWidth / 2,
                    child: TextField(
                      controller: _controller,
                      style: defText,
                      maxLength: 10,
                      cursorColor: Colors.white,
                      decoration: InputDecoration(
                          counterText: '',
                          focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(width: 2, color: green)),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: const BorderSide(
                                  width: 2, color: Colors.white)),
                          enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: const BorderSide(
                                  width: 2, color: Colors.white))),
                    ),
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                  SizedBox(
                      width: screenWidth - 15,
                      height: 65,
                      child: TextButton(
                        style: TextButton.styleFrom(
                          backgroundColor: green,
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(Radius.circular(8)),
                          ),
                        ),
                        onPressed: () {
                          /*
                        authenticate the puzzle here
                          */
                          markPuzzleAsSolved(sand.puzzleId).then((_) {
                            _future = getPuzzleWithStats();
                          });
                        },
                        child: Text(
                          'Next Puzzle',
                          style: buttonText,
                        ),
                      )),
                ],
              ),
            );
          }
        },
      ),
    );
  }
}
