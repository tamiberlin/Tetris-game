import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../piece.dart';
import '../tile.dart';
import '../values.dart' as values;

const int rowLength = 10;
const int colLength = 15;
List<List<values.TetrisShape?>> gameBoard = List.generate(
  colLength,
  (_) => List.generate(rowLength, (_) => null),
);

class GameBoard extends StatefulWidget {
  @override
  _GameBoardState createState() => _GameBoardState();
}

class _GameBoardState extends State<GameBoard> {
  late Piece currentPiece;
  late int currentScore = 0;
  bool isGameOver = false;

  @override
  void initState() {
    super.initState();
    startGame();
  }

  void startGame() {
    createNewPiece();
    gameLoop(Duration(milliseconds: 500));
  }

  void gameLoop(Duration frameRate) {
    Timer.periodic(frameRate, (timer) {
      setState(() {
        clearLines();
        checkLanding();
        if (isGameOver) {
          timer.cancel();
          showGameOverDialog();
        }
        currentPiece.movePiece(values.Direction.down);
      });
    });
  }

  void showGameOverDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Game Over"),
        content: Text("Your score: $currentScore"),
        actions: [
          TextButton(
            onPressed: () {
              resetGame();
              Navigator.of(context).pop();
            },
            child: Text("Play Again"),
          ),
        ],
      ),
    );
  }

  bool checkCollision({values.Direction? direction}) {
    return currentPiece.position.any((pos) {
      int row = (pos / rowLength).floor();
      int col = pos % rowLength;
      if (direction == values.Direction.left) {
        col -= 1;
      }
      if (direction == values.Direction.right) {
        col += 1;
      }
      if (direction == values.Direction.down) {
        row += 1;
      }
      return row >= colLength ||
          col < 0 ||
          col >= rowLength ||
          (row >= 0 && col >= 0 && gameBoard[row][col] != null);
    });
  }

  void checkLanding() {
  if (checkCollision(direction: values.Direction.down)) {
    for (int pos in currentPiece.position) {
      int row = (pos / rowLength).floor();
      int col = pos % rowLength;
      if (row >= 0 && row < colLength && col >= 0 && col < rowLength) {
        gameBoard[row][col] = currentPiece.type; // הנחת על הלוח
      }
    }
    createNewPiece();
  }
}

  bool isgameOver() {
    return gameBoard[0].any((call) => call != null);
  }

  void createNewPiece() {
    currentPiece = Piece(
        type: values.TetrisShape
            .values[Random().nextInt(values.TetrisShape.values.length)]);
    currentPiece.initiallizePiece();
    if (isgameOver()) isGameOver = true;
  }

  void clearLines() {
    for (int row = colLength - 1; row >= 0; row--) {
      if (gameBoard[row].every((cell) => cell != null)) {
        for (int r = row; r > 0; r--)
          gameBoard[r] = List.from(gameBoard[r - 1]);
        gameBoard[0] = List.generate(rowLength, (_) => null);
        currentScore++;
      }
    }
  }

  void moveLeft() {
    if (!checkCollision(direction: values.Direction.left)) {
      setState(() => currentPiece.movePiece(values.Direction.left));
    }
    checkLanding();
  }

  void moveRight() {
    if (!checkCollision(direction: values.Direction.right)) {
      setState(() => currentPiece.movePiece(values.Direction.right));
    }
    checkLanding();
  }

  void rotatePiece() {
    setState(() {
      currentPiece.protatePiece();
      if (checkCollision(direction: values.Direction.down)) {
        currentPiece.protatePiece();
      }
    });
    checkLanding();
  }

  void resetGame() {
    gameBoard =
        List.generate(colLength, (_) => List.generate(rowLength, (_) => null));
    currentScore = 0;
    isGameOver = false;
    currentScore = 0;
    createNewPiece();
    startGame();
  }

  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: GridView.builder(
                itemCount: rowLength*colLength,
                physics: NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: rowLength,
                ),
                itemBuilder: (context, index) {
                  int row = (index / rowLength).floor();
                  int col = index % rowLength;
                  Color color;
                  if (currentPiece.position.contains(index)) {
                    color = currentPiece.color;
                  } else if (gameBoard[row][col] != null) {
                    color = values.tetrisShapeColors[gameBoard[row][col]]!;
                  } else {
                    color = Colors.grey[900]!;
                  }
                  return Tile(
                    color: color,
                  );
                },
              ),
            ),
            Padding(
              padding: EdgeInsets.all(25),
              child: Text(
                "Score: $currentScore",
                style: TextStyle(color: Colors.white, fontSize: 20),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(bottom: 20),
              child: Row(
                children: [
                  IconButton(
                    onPressed: moveLeft,
                    icon: Icon(Icons.arrow_back_ios),
                  ),
                  IconButton(
                    onPressed: rotatePiece,
                    icon: Icon(Icons.rotate_right),
                  ),
                  IconButton(
                    onPressed: moveRight,
                    icon: Icon(Icons.arrow_forward_ios),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
