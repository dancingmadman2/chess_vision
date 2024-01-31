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

  Future<bool> authenticatePuzzle(String puzzleId) async {
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
    */
    String xFen = fen;
    for (int i = 0; i < movesArray.length; i++) {
      String parsedMove =
          '${getPieceAtSquare(xFen, movesArray[i].substring(0, 2)).toUpperCase()} ${movesArray[i].substring(2, 4).toLowerCase()}';

      if (getPieceAtSquare(xFen, movesArray[i].substring(2, 4)).toLowerCase() !=
          '') {
        parsedMove =
            '${getPieceAtSquare(xFen, movesArray[i].substring(0, 2)).toUpperCase()}x ${movesArray[i].substring(2, 4).toLowerCase()}';
      }

      parsedMove = parsedMove.replaceAll(' ', '');

      parsedMoves.add(parsedMove);
      xFen = applyMoveToFen(xFen, movesArray[i]);
    }
    print(parsedMoves);
    String solution = movesArray[0];

    if (_controller.text.toString() == solution) {
      isAuthenticated = true;
    }
    return isAuthenticated;
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
                          authenticatePuzzle(sand.puzzleId);
                          /*
                          markPuzzleAsSolved(sand.puzzleId).then((_) {
                            _future = getPuzzleWithStats();
                          });*/
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

String getPieceAtSquare(String fenBoard, String position) {
  // Parse FEN board
  List<String> rows = fenBoard.split('/');
  List<String> board = [];
  for (String row in rows) {
    for (int i = 0; i < row.length; i++) {
      if (row[i] == '1' ||
          row[i] == '2' ||
          row[i] == '3' ||
          row[i] == '4' ||
          row[i] == '5' ||
          row[i] == '6' ||
          row[i] == '7' ||
          row[i] == '8') {
        // Add empty squares
        int count = int.parse(row[i]);
        for (int j = 0; j < count; j++) {
          board.add('');
        }
      } else {
        // Add pieces
        board.add(row[i]);
      }
    }
  }

  // Convert position to indices
  int file = position.codeUnitAt(0) - 'a'.codeUnitAt(0);
  int rank = 8 - int.parse(position[1]);

  // Get piece at the specified square
  String piece = board[rank * 8 + file];

  return piece;
}

String applyMoveToFen(String fenBoard, String move) {
  // Parse FEN board
  List<String> rows = fenBoard.split('/');
  List<String> board = [];
  for (String row in rows) {
    for (int i = 0; i < row.length; i++) {
      if (row[i] == '1' ||
          row[i] == '2' ||
          row[i] == '3' ||
          row[i] == '4' ||
          row[i] == '5' ||
          row[i] == '6' ||
          row[i] == '7' ||
          row[i] == '8') {
        // Add empty squares
        int count = int.parse(row[i]);
        for (int j = 0; j < count; j++) {
          board.add('');
        }
      } else {
        // Add pieces
        board.add(row[i]);
      }
    }
  }

  // Parse move
  int fromFile = move[0].codeUnitAt(0) - 'a'.codeUnitAt(0);
  int fromRank = 8 - int.parse(move[1]);

  int toFile = move[2].codeUnitAt(0) - 'a'.codeUnitAt(0);
  int toRank = 8 - int.parse(move[3]);

  // Get piece at the source square
  String piece = board[fromRank * 8 + fromFile];

  // Update board with the move
  board[fromRank * 8 + fromFile] = '';
  board[toRank * 8 + toFile] = piece;

  // Convert board back to FEN
  String updatedFen = '';
  int emptyCount = 0;
  for (int i = 0; i < board.length; i++) {
    if (board[i].isEmpty) {
      emptyCount++;
    } else {
      if (emptyCount > 0) {
        updatedFen += emptyCount.toString();
        emptyCount = 0;
      }
      updatedFen += board[i];
    }

    if ((i + 1) % 8 == 0 && i != board.length - 1) {
      if (emptyCount > 0) {
        updatedFen += emptyCount.toString();
        emptyCount = 0;
      }
      updatedFen += '/';
    }
  }

  return updatedFen;
}
