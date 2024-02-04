import 'dart:async';

import 'package:chess_vision/components/helper.dart';
import 'package:chess_vision/screens/puzzles/components/sandbox_methods.dart';
import 'package:chess_vision/styles.dart';
import 'package:flutter/cupertino.dart';

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show defaultTargetPlatform;

import 'package:shared_preferences/shared_preferences.dart';

class Sandbox extends StatefulWidget {
  const Sandbox({super.key});

  @override
  State<Sandbox> createState() => _SandboxState();
}

class _SandboxState extends State<Sandbox> {
  final TextEditingController _controller = TextEditingController();
  late Future _future;
  int index = 0;
  List<bool> isCorrect = List.filled(20, false);
  int tryGiveUp = 0;
  int countCheckAnswer = 0;
  int countCheckAfterWrongAnswer = 0;
  int countGiveUp = 0;
  late Timer _timer;
  bool isFinished = false;
  bool hasBeenWrong = false;
  bool ratingChanged = false;
  late ValueNotifier<int> _giveUp;
  late ValueNotifier<List<bool>> _answerTF;
  late ValueNotifier<bool> _answer;
  late ValueNotifier<int> _rating;
  late ValueNotifier<bool> _isFinishedNotifier;
  late final ValueNotifier<String> _timeNotifier =
      ValueNotifier<String>("0:00");

  Stopwatch stopwatch = Stopwatch();

  Future<void> markPuzzleAsSolved(String puzzleId) async {
    DatabaseHelper db = DatabaseHelper();
    final prefs = await SharedPreferences.getInstance();

    db.updateSolved(puzzleId);

    // removing the sharedpref tag so that new puzzles can be generated
    _answer.value = false;
    setState(() {
      prefs.remove('currentPuzzleId');
    });
  }

  Future<PuzzleWithUserStats> getPuzzleWithStats() async {
    DatabaseHelper db = DatabaseHelper();
    final prefs = await SharedPreferences.getInstance();
    String? currentPuzzleId = prefs.getString('currentPuzzleId');
    User? user;
    Puzzle? puzzle;

    if (currentPuzzleId == null) {
      puzzle = await db.getPuzzleByRating(); // Fetch a new random puzzle
    } else {
      puzzle = await db
          .getPuzzle(currentPuzzleId); // Fetch the puzzle with the stored ID
    }

    user = await db.getUserStats(); // Get user stats

    // Loop to parse the moves
    List<String> solution = parseSolution(puzzle!.moves, puzzle.fen);
    print(solution);

    return PuzzleWithUserStats(puzzle: puzzle, userStats: user);
  }

  Future<bool> authenticateSolution(String puzzleId, int index) async {
    DatabaseHelper db = DatabaseHelper();
    bool isAuthenticated = false;
    var puzzle = await db.getPuzzle(puzzleId);
    String moves = '';
    String fen = '';
    if (puzzle != null) {
      moves = puzzle.moves;
      fen = puzzle.fen;
    }

    // Loop to parse the moves
    List<String> solution = parseSolution(moves, fen);
    print(solution);

    // Right answer
    if (_controller.text.toString().toLowerCase() ==
        solution[index].toLowerCase()) {
      isAuthenticated = true;

      _answerTF.value = List<bool>.from(_answerTF.value)..[0] = true;

      if (!_timer.isActive) {
        _timer = Timer.periodic(const Duration(milliseconds: 1000), (timer) {
          _answerTF.value = List<bool>.from(_answerTF.value)..[0] = false;
          _timer.cancel();
        });
      }
    }
    // Wrong answer
    else {
      _answerTF.value = List<bool>.from(_answerTF.value)..[1] = true;
      _answer.value = false;

      if (!_timer.isActive) {
        _timer = Timer.periodic(const Duration(milliseconds: 1000), (timer) {
          _answerTF.value = List<bool>.from(_answerTF.value)..[1] = false;
          _timer.cancel();
        });
      }
    }
    return isAuthenticated;
  }

  List<String> parseSolution(
    String moves,
    String xFen,
  ) {
    /*
    parsing logic for solution
     moves:  h4h5 d4f2 g3b3 c2b3 a2b3 f2e1
     current board: 4r1k1/5p2/6p1/2pRP3/PpPb3P/6Q1/P1q3P1/4R2K w - - 1 31
     look at g3 return the piece
     return example: Qb3
     update current board(fen) after each move
     iterate
    */
    List<String> movesArray = [];

    movesArray = moves.split(' ');
    List<String> parsedMoves = [];
    for (int i = 0; i < movesArray.length; i++) {
      String parsedMove = '';
      //if piece is a pawn
      if (getPieceAtSquare(xFen, movesArray[i].substring(0, 2)) == 'p') {
        parsedMove = movesArray[i].substring(2, 4).toLowerCase();
      } else {
        parsedMove =
            '${getPieceAtSquare(xFen, movesArray[i].substring(0, 2)).toUpperCase()} ${movesArray[i].substring(2, 4).toLowerCase()}';
      }

      // Capturing a piece
      if (getPieceAtSquare(xFen, movesArray[i].substring(2, 4)).toLowerCase() !=
          '') {
        if (getPieceAtSquare(xFen, movesArray[i].substring(0, 2)) == 'p') {
          parsedMove =
              '${movesArray[i].substring(0, 1)}x ${movesArray[i].substring(2, 4).toLowerCase()}';
        } else {
          parsedMove =
              '${getPieceAtSquare(xFen, movesArray[i].substring(0, 2)).toUpperCase()}x ${movesArray[i].substring(2, 4).toLowerCase()}';
        }
      }
      parsedMove = parsedMove.replaceAll(' ', '');
      if (isCheck(xFen)) {
        parsedMove = '$parsedMove+';
      }
      parsedMoves.add(parsedMove);
      xFen = applyMoveToFen(xFen, movesArray[i]);
    }
    List<String> solution = [];

    for (int i = 0; i < parsedMoves.length; i++) {
      if (i % 2 != 0) {
        solution.add(parsedMoves[i]);
      }
    }
    return solution;
  }

  @override
  void initState() {
    super.initState();

    _future = getPuzzleWithStats();
    _giveUp = ValueNotifier(0);
    _rating = ValueNotifier(0);
    _isFinishedNotifier = ValueNotifier(false);

    stopwatch.start();
    Timer.periodic(const Duration(seconds: 1), (timer) {
      int totalSeconds = stopwatch.elapsed.inSeconds;
      int minutes = totalSeconds ~/ 60;
      int seconds = totalSeconds % 60;

      _timeNotifier.value = "$minutes:${seconds.toString().padLeft(2, '0')}";
    });

    _timer = Timer.periodic(const Duration(seconds: 0), (timer) {
      // Perform your periodic logic here
      _timer.cancel();
    });

    _answerTF = ValueNotifier<List<bool>>(List<bool>.generate(
      2, // Replace with the desired number of items in the list
      (index) =>
          false, // Initialize each item with false or true based on your requirements
    ));
    _answer = ValueNotifier(false);
  }

  @override
  void dispose() {
    if (mounted) {
      _giveUp.dispose();
      _answerTF.dispose();
      _controller.dispose();
      _timer.cancel();
      stopwatch.stop();

      super.dispose();
    }
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
                      const SizedBox(
                        width: 5,
                      ),
                      ValueListenableBuilder<int?>(
                          valueListenable: _rating,
                          builder: (context, value, child) {
                            return Text(
                              value! != 0
                                  ? (value > 0 ? ('+$value') : (' $value'))
                                  : '',
                              style: value > 0 ? defTextGreen : defTextRed,
                            );
                          }),
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
                        style: subtitle,
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 50,
                  ),
                  Row(
                    children: [
                      const SizedBox(
                        width: 5,
                      ),
                      Icon(CupertinoIcons.time, size: 32, color: green),
                      const SizedBox(
                        width: 5,
                      ),
                      ValueListenableBuilder<String>(
                          valueListenable: _timeNotifier,
                          builder: (context, value, child) {
                            return Text(
                              value,
                              style: defText,
                            );
                          }),
                    ],
                  ),
                  Text(
                    'Puzzle: ${sand.puzzleId}',
                    style: defText,
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                  SizedBox(
                    width: screenWidth / 2,
                    child: ValueListenableBuilder<List<bool?>>(
                        valueListenable: _answerTF,
                        builder: (context, value, child) {
                          return TextField(
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
                                    borderSide: BorderSide(
                                        width: 2,
                                        color: _answerTF.value[1]
                                            ? Colors.red
                                            : _answerTF.value[0]
                                                ? green
                                                : Colors.white)),
                                errorBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: BorderSide(
                                        width: 2,
                                        color:
                                            _answerTF.value[0] ? green : mono)),
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: BorderSide(
                                        width: 2,
                                        color:
                                            _answerTF.value[0] ? green : mono)),
                                enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: BorderSide(
                                        width: 2,
                                        color: _answerTF.value[0]
                                            ? green
                                            : mono))),
                          );
                        }),
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
                                if (_controller.text.isNotEmpty) {}
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

                      //
                      const SizedBox(
                        width: 15,
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 30,
                  ),
                  ValueListenableBuilder<bool?>(
                      valueListenable: _isFinishedNotifier,
                      builder: (context, value, child) {
                        return value!
                            ? SizedBox(
                                width: screenWidth - 15,
                                height: 70,
                                child: TextButton(
                                  style: TextButton.styleFrom(
                                    backgroundColor: mono,
                                    shape: const RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.all(Radius.circular(8)),
                                    ),
                                  ),
                                  onPressed: () => nextPuzzle(sand.puzzleId),
                                  child: Text(
                                    'Next Puzzle',
                                    style: buttonText,
                                    textAlign: TextAlign.center,
                                  ),
                                ))
                            : const Center();
                      }),
                ],
              ),
            );
          }
        },
      ),
    );
  }

  Future<void> giveUp() async {
    DatabaseHelper db = DatabaseHelper();

    if (!isFinished) {
      int userRating = -1;

      // fetch the user rating
      var userStats = await db.getUserStats();
      if (userStats != null) {
        userRating = userStats.rating;
      }
      tryGiveUp++;
      _giveUp.value = tryGiveUp;

      if (!_timer.isActive) {
        _timer = Timer.periodic(const Duration(seconds: 2), (timer) {
          tryGiveUp = 0;
          _giveUp.value = tryGiveUp;
          _timer.cancel();
        });
      }

      if (tryGiveUp == 2 && countGiveUp < 1) {
        countGiveUp++;
        final prefs = await SharedPreferences.getInstance();
        // removing the sharedpref tag so that new puzzles can be generated
        if (!ratingChanged && prefs.getBool('doneBefore') == null) {
          db.updateUserRating(userRating - 8);
          _rating.value = -8;
        }

        isFinished = true;
        _isFinishedNotifier.value = isFinished;

        stopwatch.stop();
        setState(() {
          prefs.remove('currentPuzzleId');
          prefs.remove('doneBefore');
        });
      }
    }
  }

  Future<void> checkAnswer(Puzzle sand) async {
    DatabaseHelper db = DatabaseHelper();
    int userRating = -1;
    final prefs = await SharedPreferences.getInstance();

    // fetch the user rating
    var userStats = await db.getUserStats();
    if (userStats != null) {
      userRating = userStats.rating;
    }
    List<String> movesArray = [];

    movesArray = sand.moves.split(' ');
    int l = movesArray.length ~/ 2;

    if (index < l && !isFinished) {
      isCorrect[index] = (await authenticateSolution(sand.puzzleId, index));
    }

    if (isCorrect[index]) {
      index++;
      _controller.clear();
    } else {
      hasBeenWrong = true;
    }
    _answer.value = !hasBeenWrong;

    if (hasBeenWrong &&
        countCheckAfterWrongAnswer < 1 &&
        prefs.getBool('doneBefore') == null) {
      prefs.setBool('doneBefore', true);
      countCheckAfterWrongAnswer++;
      db.updateUserRating(userRating - 8);
      _rating.value = -8;
      ratingChanged = true;
    }

    if (isCorrect[l - 1] && countCheckAnswer < 1) {
      countCheckAnswer++;
      index = 0;
      isCorrect.fillRange(0, 20, false);
      isFinished = true;
      _isFinishedNotifier.value = isFinished;
      prefs.remove('currentPuzzleId');

      if (_answer.value && prefs.getBool('doneBefore') == null) {
        db.updateUserRating(userRating + 13);
        _rating.value = 13;
        stopwatch.stop();
      }
    }
  }

  void nextPuzzle(String puzzleId) async {
    final prefs = await SharedPreferences.getInstance();
    if (isFinished || countGiveUp == 1) {
      markPuzzleAsSolved(puzzleId).then((_) {
        _future = getPuzzleWithStats();
      });
      countCheckAnswer = 0;
      countGiveUp = 0;
      _rating.value = 0;
      countCheckAfterWrongAnswer = 0;
      isFinished = false;
      _isFinishedNotifier.value = isFinished;
      ratingChanged = false;
      stopwatch.reset();
      stopwatch.start();
      prefs.remove('doneBefore');
    }
  }
}
