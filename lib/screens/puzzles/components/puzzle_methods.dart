import '../../../components/helper.dart';

class PuzzleWithUserStats {
  final Puzzle? puzzle;
  final User? userStats;

  PuzzleWithUserStats({this.puzzle, this.userStats});
}

List<String> parsePgn(String pgn) {
  pgn = pgn.trim();
  List<String> moves = pgn.split(' ');

  int count = 0;
  for (int i = 0; i < moves.length; i++) {
    if (i == 0) {
      count++;
      moves.insert(0, '1. ');
    } else if (i % 3 == 0) {
      count++;

      moves.insert(i, '$count. ');
    }
  }

  return moves;
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

  // Check if the piece is a pawn and return the position
  if (piece.toLowerCase() == 'p') {
    return 'p';
  }

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

bool isCheck(String fen) {
  // Split the FEN string to extract relevant information
  List<String> parts = fen.split(' ');
  String boardState = parts[0];
  String activeColor = parts[1];

  // Find the position of the king based on the active color
  int kingIndex =
      activeColor == 'w' ? boardState.indexOf('K') : boardState.indexOf('k');

  // Check if the king is under attack (check)
  return false;
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

  // Format piece in chess notation
  String chessNotation = piece.isNotEmpty ? '$piece$position' : '';

  return chessNotation;
}

List<String> getAllPieces(String fen) {
  final List<String> files = ['a', 'b', 'c', 'd', 'e', 'f', 'g', 'h'];
  //final List<String> ranks = ['8', '7', '6', '5', '4', '3', '2', '1'];
  List<String> pieces = [];

  for (int rank = 8; rank >= 1; rank--) {
    for (String file in files) {
      pieces.add(getPiece(fen, file + rank.toString()));
    }
  }
  pieces.removeWhere((element) => element == '');
  return pieces;
}

Map<String, dynamic> parseMoves(
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

  List<String> botMoves = [];
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
    } else {
      if (i != 0) {
        botMoves.add(parsedMoves[i]);
      }
    }
  }
  Map<String, List<String>> parsed = {'solution': solution, 'bot': botMoves};
  return parsed;
}
