import '../../../components/helper.dart';

class PuzzleWithUserStats {
  final Puzzle? puzzle;
  final User? userStats;

  PuzzleWithUserStats({this.puzzle, this.userStats});
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
