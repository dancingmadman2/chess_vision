import 'dart:async';

import 'package:chess_vision/components/database.dart';
import 'package:chess_vision/screens/puzzles/components/puzzle_methods.dart';
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
  int index = 0;
  List<bool> isCorrect = List.filled(20, false);
  int tryGiveUp = 0;
  late Timer _timer;
  late ValueNotifier<int> _giveUp;

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

  Future<bool> authenticateSolution(String puzzleId, int index) async {
    bool isAuthenticated = false;
    var puzzle = await getPuzzle(puzzleId);
    String moves = '';
    String fen = '';
    if (puzzle != null) {
      moves = puzzle.moves;
      fen = puzzle.fen;
    }
    List<String> movesArray = [];
    List<String> parsedMoves = [];
    movesArray = moves.split(' ');
    /*
    parsing logic for solution
     moves:  h4h5 d4f2 g3b3 c2b3 a2b3 f2e1
     current board: 4r1k1/5p2/6p1/2pRP3/PpPb3P/6Q1/P1q3P1/4R2K w - - 1 31
     look at g3 return the piece
     return example: Qb3
     update current board(fen) after each move
     iterate
    */
    String xFen = fen;
    // Loop to parse the moves
    for (int i = 0; i < movesArray.length; i++) {
      //
      String parsedMove =
          '${getPieceAtSquare(xFen, movesArray[i].substring(0, 2)).toUpperCase()} ${movesArray[i].substring(2, 4).toLowerCase()}';
      //
      if (getPieceAtSquare(xFen, movesArray[i].substring(2, 4)).toLowerCase() !=
          '') {
        parsedMove =
            '${getPieceAtSquare(xFen, movesArray[i].substring(0, 2)).toUpperCase()}x ${movesArray[i].substring(2, 4).toLowerCase()}';
      }
      parsedMove = parsedMove.replaceAll(' ', '');
      parsedMoves.add(parsedMove);
      xFen = applyMoveToFen(xFen, movesArray[i]);
    }
    List<String> solution = [];

    for (int i = 0; i < parsedMoves.length; i++) {
      if (i % 2 != 0) {
        solution.add(parsedMoves[i]);
      }
    }
    print(solution);
    if (_controller.text.toString().toLowerCase() ==
        solution[index].toLowerCase()) {
      isAuthenticated = true;
    }
    return isAuthenticated;
  }

  @override
  void initState() {
    super.initState();
    _future = getPuzzleWithStats();
    _giveUp = ValueNotifier(0);
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: primary,
      resizeToAvoidBottomInset: false,
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
                children: [
                  Image.asset(
                    'assets/images/puzzle_knight.png',
                    width: 60,
                    color: green,
                  ),
                  const SizedBox(
                    height: 30,
                  ),
                  Row(
                    children: [
                      const SizedBox(
                        width: 5,
                      ),
                      Text(
                        'Your Rating: ',
                        style: defText,
                      ),
                      Text(
                        '${stats.rating}',
                        style: subtitleGreen,
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      const SizedBox(
                        width: 5,
                      ),
                      Text(
                        'Puzzle Rating: ',
                        style: defText,
                      ),
                      Text(
                        '${sand.rating}',
                        style: subtitleBlue,
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 50,
                  ),
                  Text(
                    'Puzzle: ${sand.puzzleId}',
                    style: defText,
                  ),
                  const SizedBox(
                    height: 30,
                  ),
                  SizedBox(
                    width: screenWidth / 2,
                    child: TextField(
                      controller: _controller,
                      style: subtitle,
                      maxLength: 10,
                      onSubmitted: (value) => checkAnswer(sand),
                      cursorColor: Colors.white,
                      decoration: InputDecoration(
                          labelText: 'Enter your solution',
                          labelStyle: defTextGrey,
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
                  Row(
                    children: [
                      const SizedBox(
                        width: 15,
                      ),
                      Expanded(
                        child: SizedBox(
                            //width: screenWidth - 15,
                            height: 70,
                            child: TextButton(
                              style: TextButton.styleFrom(
                                backgroundColor: green,
                                shape: const RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(8)),
                                ),
                              ),
                              onPressed: () async {
                                await checkAnswer(sand);

                                /*
                                markPuzzleAsSolved(sand.puzzleId).then((_) {
                                  _future = getPuzzleWithStats();
                                });*/
                              },
                              child: Text(
                                'Check Solution',
                                style: buttonText,
                              ),
                            )),
                      ),
                      const SizedBox(
                        width: 15,
                      ),
                      SizedBox(
                          width: screenWidth / 2 - 50,
                          height: 70,
                          child: TextButton(
                            style: TextButton.styleFrom(
                              backgroundColor: mono,
                              shape: const RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(8)),
                              ),
                            ),
                            onPressed: () async => await giveUp(),
                            child: ValueListenableBuilder<int?>(
                                valueListenable: _giveUp,
                                builder: (context, value, child) {
                                  return Text(
                                    value == 1 ? 'Are you sure?' : 'Give Up?',
                                    style: buttonText,
                                    textAlign: TextAlign.center,
                                  );
                                }),
                          )),
                      const SizedBox(
                        width: 15,
                      ),
                    ],
                  ),
                ],
              ),
            );
          }
        },
      ),
    );
  }

  Future<void> giveUp() async {
    tryGiveUp++;
    _giveUp.value = tryGiveUp;

    Timer.periodic(const Duration(seconds: 2), (timer) {
      tryGiveUp = 0;
      _giveUp.value = tryGiveUp;
      timer.cancel();
    });
    if (tryGiveUp > 1) {
      final prefs = await SharedPreferences.getInstance();
      // removing the sharedpref tag so that new puzzles can be generated
      setState(() {
        prefs.remove('currentPuzzleId');
      });
    }
  }

  Future<void> checkAnswer(Puzzle sand) async {
    List<String> movesArray = [];

    movesArray = sand.moves.split(' ');
    int l = movesArray.length ~/ 2;

    if (index < l) {
      isCorrect[index] = (await authenticateSolution(sand.puzzleId, index));
    }

    if (isCorrect[index]) {
      index++;
      _controller.clear();
    }

    if (isCorrect[l - 1]) {
      isCorrect.fillRange(0, 20, false);
      markPuzzleAsSolved(sand.puzzleId).then((_) {
        _future = getPuzzleWithStats();
      });
    }
  }
}
