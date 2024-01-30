import 'package:chess_vision/screens/puzzles/combined_puzzles.dart';
import 'package:chess_vision/screens/puzzles/components/puzzles_button.dart';
import 'package:chess_vision/styles.dart';
import 'package:flutter/material.dart';

class MinigamesScreen extends StatefulWidget {
  const MinigamesScreen({super.key});

  @override
  State<MinigamesScreen> createState() => _MinigamesScreenState();
}

class _MinigamesScreenState extends State<MinigamesScreen> {
  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: primary,
      appBar: AppBar(
        backgroundColor: primary,
        title: Text(
          'Minigames',
          style: appbarTitle,
          textAlign: TextAlign.center,
        ),
        centerTitle: true,
      ),
      body: Center(
          child: Column(
        children: [
          Image.asset('assets/images/target.png',
              width: 60, color: Colors.blue),
          const SizedBox(
            height: 30,
          ),
          PuzzlesButton(
              destination: const CombinedPuzzles(),
              screenWidth: screenWidth,
              image: 'assets/images/coordinate.png',
              title: 'Coordinate Trainer',
              description:
                  'Get familiar with the squares on chessboard by training.'),
          const SizedBox(
            height: 30,
          ),
          PuzzlesButton(
              destination: const CombinedPuzzles(),
              screenWidth: screenWidth,
              image: 'assets/images/chess_board.png',
              title: 'Remember The Position',
              description:
                  'Remember chess positions with various complexities in a time limit.'),
          const SizedBox(
            height: 15,
          ),
          PuzzlesButton(
              destination: const CombinedPuzzles(),
              screenWidth: screenWidth,
              image: 'assets/images/queen_knight.png',
              title: 'Capture The Queen',
              description:
                  'Manoeuvre your knight carefully and capture the queen.'),
          const SizedBox(
            height: 15,
          ),
          PuzzlesButton(
              destination: const CombinedPuzzles(),
              screenWidth: screenWidth,
              image: 'assets/images/checkmate.png',
              title: 'Find The Mate',
              description:
                  'Find the mate within various mate in "x" positions.'),
        ],
      )),
    );
  }
}
