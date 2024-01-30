import 'package:chess_vision/components/database.dart';
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
/*
  Future<List<Puzzle>> getPuzzles() async {
    final String dbPath = await getDatabasePath();
    final db = await openDatabase(dbPath);
    final List<Map<String, dynamic>> maps = await db.query('puzzles');

    return List.generate(maps.length, (i) {
      return Puzzle(
        puzzleId: maps[i]['puzzleId'],
        fen: maps[i]['fen'],
        moves: maps[i]['moves'],
        rating: maps[i]['rating'],
        // ... other fields ...
      );
    });
  }*/

  Future<Puzzle?> getPuzzle(int minRating, int maxRating) async {
    final prefs = await SharedPreferences.getInstance();
    String? currentPuzzleId = prefs.getString('currentPuzzleId');

    if (currentPuzzleId == null) {
      // Fetch a new random puzzle
      return await getPuzzleByRating(minRating, maxRating);
    } else {
      // Fetch the puzzle with the stored ID
      return await getPuzzleById(currentPuzzleId);
    }
  }

  void markPuzzleAsSolved(String puzzleId) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.remove('currentPuzzleId'); // Remove or set a flag for a new puzzle
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

  Future<Puzzle?> getPuzzleByRating(int minRating, int maxRating) async {
    final prefs = await SharedPreferences.getInstance();
    final dbPath = await getDatabasePath();
    final db = await openDatabase(dbPath);

    String? currentPuzzleId = prefs.getString('currentPuzzleId');
    String whereClause = 'rating >= ? AND rating <= ?';
    List<dynamic> whereArgs = [minRating, maxRating];

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
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: primary,
      appBar: AppBar(
        backgroundColor: primary,
        leading: InkWell(
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
      body: FutureBuilder<Puzzle?>(
        future: getPuzzle(1300, 1400),
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
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            // Print the first puzzle's details to the console
            //print('First puzzle: ${snapshot.data?.first.toMap()}');
            final Puzzle sand = snapshot.data!;
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  sand.puzzleId,
                  style: defText,
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
                        // if(solutionIsCorrect){
                        // get new puzzle
                        // }
                        setState(() {
                          markPuzzleAsSolved(sand.puzzleId);
                          getPuzzle(1300, 1400);
                        });
                      },
                      child: Text(
                        'Next Puzzle',
                        style: buttonText,
                      ),
                    )),
              ],
            );
            /*
             ListView.builder(
              itemCount: snapshot.data?.length ?? 0,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(snapshot.data![index].fen),
                  // ... other list tile properties ...
                );
              },
            );*/
          }
        },
      ),
    );
  }
}
