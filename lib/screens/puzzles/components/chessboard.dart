import 'dart:math';

import 'package:chess_vision/styles.dart';
import 'package:flutter/material.dart';

class ChessboardWidget extends StatelessWidget {
  final List<String> files = ['a', 'b', 'c', 'd', 'e', 'f', 'g', 'h'];
  final List<String> ranks = ['8', '7', '6', '5', '4', '3', '2', '1'];
  //final String initialFEN = 'rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR';
  final String fen;
  final bool pieces;
  ChessboardWidget({super.key, required this.fen, required this.pieces});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Display ranks
        for (int rank = 8; rank >= 1; rank--)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(width: 8),
              Text(
                rank.toString(),
                style: defText,
              ),
              const SizedBox(width: 8),
              // Display files
              for (String file in files)
                Column(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      color: (file.codeUnitAt(0) + rank) % 2 == 0
                          ? mono
                          : Colors.white60,
                      child: Center(
                          child: pieces
                              ? getPiece(fen, file + rank.toString()).isNotEmpty
                                  ? Image.asset(
                                      pieceImage(getPiece(
                                          fen, file + rank.toString())),
                                      width: 32,
                                      height: 32,
                                      color: getPiece(fen,
                                                  file + rank.toString()) ==
                                              getPiece(fen,
                                                      file + rank.toString())
                                                  .toUpperCase()
                                          ? Colors.white
                                          : Colors.black,
                                    )
                                  : null
                              : null),
                    ),
                    const SizedBox(width: 8),
                    if (rank == 1)
                      Text(
                        file,
                        style: defText,
                      ),
                    const SizedBox(width: 8),
                  ],
                ),
              const SizedBox(width: 8),
            ],
          ),
      ],
    );
  }

  String getPiece(String fenBoard, String position) {
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

  String pieceImage(String piece) {
    String x = piece;
    x = x.toUpperCase();
    if (piece.isNotEmpty) {
      return 'assets/images/$x.png';
    } else {
      return '';
    }
  }
}
