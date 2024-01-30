import 'package:chess_vision/screens/puzzles/combined_puzzles.dart';
import 'package:chess_vision/screens/puzzles/components/puzzles_button.dart';
import 'package:chess_vision/styles.dart';

import 'package:flutter/material.dart';

class PuzzlesScreen extends StatefulWidget {
  const PuzzlesScreen({super.key});

  @override
  State<PuzzlesScreen> createState() => _PuzzlesScreenState();
}

class _PuzzlesScreenState extends State<PuzzlesScreen> {
  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: primary,
        title: Text(
          'Puzzles',
          style: appbarTitle,
          textAlign: TextAlign.center,
        ),
        centerTitle: true,
      ),
      backgroundColor: primary,
      body: Center(
        child: Column(children: [
          Image.asset('assets/images/puzzle.png', width: 60, color: green),
          const SizedBox(
            height: 30,
          ),
          PuzzlesButton(
            screenWidth: screenWidth,
            image: 'assets/images/puzzle_knight.png',
            title: 'Combined Puzzles',
            description:
                'These are a combination of all the puzzles to test yourself and get a rating.',
            destination: const CombinedPuzzles(),
          ),
          const SizedBox(
            height: 30,
          ),
          PuzzlesButton(
            destination: const CombinedPuzzles(),
            screenWidth: screenWidth,
            image: 'assets/images/books.png',
            title: 'Opening Puzzles',
            description:
                'Refine your opening moves with strategic puzzles to elevate your board vision.',
          ),
          const SizedBox(
            height: 15,
          ),
          PuzzlesButton(
            destination: const CombinedPuzzles(),
            screenWidth: screenWidth,
            image: 'assets/images/queen.png',
            title: 'Middlegame Puzzles',
            description:
                'Enhance your middlegame tactics and decision-making through engaging puzzles focusing on complex middlegame scenarios.',
          ),
          const SizedBox(
            height: 15,
          ),
          PuzzlesButton(
            destination: const CombinedPuzzles(),
            screenWidth: screenWidth,
            image: 'assets/images/rook_king.png',
            title: 'Endgame Puzzles',
            description:
                'Master endgame strategy with puzzles to enhance mental visualization.',
          ),
        ]),
      ),
    );
  }
}
