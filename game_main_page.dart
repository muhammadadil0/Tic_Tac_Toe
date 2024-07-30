import 'dart:math';

import 'package:flutter/material.dart';

class GameMainPage extends StatefulWidget {
  const GameMainPage({super.key});

  @override
  State<GameMainPage> createState() => _GameMainPageState();
}

class _GameMainPageState extends State<GameMainPage> {
  List<String> display = ['', '', '', '', '', '', '', '', ''];
  bool isOTurn = true;
  bool isWin = false;
  bool playWithComputer = false;

  @override
  void initState() {
    super.initState();
    // Initial state setup if needed, but do not call _showModeSelectionDialog here
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Move the dialog call here
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showModeSelectionDialog();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black54,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.only(top: 149.0, left: 10, right: 10),
          child: GridView.builder(
            itemCount: 9,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
            ),
            itemBuilder: (context, index) {
              return Center(
                child: GestureDetector(
                  onTap: () {
                    tapped(index);
                  },
                  child: Center(
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                      ),
                      child: Center(
                        child: Text(
                          display[index],
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 40,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  void checkWinner() {
    // Check rows
    for (int i = 0; i < 9; i += 3) {
      if (display[i] != '' &&
          display[i] == display[i + 1] &&
          display[i] == display[i + 2]) {
        setState(() {
          isWin = true;
        });
        _showWinnerDialog(display[i]);
        return;
      }
    }

    // Check columns
    for (int i = 0; i < 3; i++) {
      if (display[i] != '' &&
          display[i] == display[i + 3] &&
          display[i] == display[i + 6]) {
        setState(() {
          isWin = true;
        });
        _showWinnerDialog(display[i]);
        return;
      }
    }

    // Check diagonals
    if (display[0] != '' &&
        display[0] == display[4] &&
        display[0] == display[8]) {
      setState(() {
        isWin = true;
      });
      _showWinnerDialog(display[0]);
      return;
    }
    if (display[2] != '' &&
        display[2] == display[4] &&
        display[2] == display[6]) {
      setState(() {
        isWin = true;
      });
      _showWinnerDialog(display[2]);
      return;
    }

    // Check for draw
    if (!display.contains('')) {
      setState(() {
        isWin = true;
      });
      _showWinnerDialog(null); // Indicate a draw
    }
  }

  void tapped(int index) {
    if (display[index] == '' && !isWin) {
      setState(() {
        display[index] = isOTurn ? 'O' : 'X';
        isOTurn = !isOTurn;
        checkWinner();
        if (!isWin && playWithComputer && !isOTurn) {
          playingComputer();
        }
      });
    }
  }

  void _showWinnerDialog(String? winner) {
    String message;
    if (winner == null) {
      message = "It's a Draw!";
    } else {
      message = '$winner wins!';
    }
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Game Over'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close the dialog
              playingAgain(); // Reset the game
            },
            child: Text('Play Again'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close the dialog
              Navigator.pop(context); // Go back to the previous screen
            },
            child: Text('Exit'),
          ),
        ],
      ),
    );
  }

  void playingAgain() {
    setState(() {
      display = ['', '', '', '', '', '', '', '', ''];
      isOTurn = true;
      isWin = false;
    });
    _showModeSelectionDialog();
  }

  int _minimax(List<String> board, bool isMaximizing) {
    // Base cases for terminal states
    for (int i = 0; i < 9; i += 3) {
      if (board[i] != '' && board[i] == board[i + 1] && board[i] == board[i + 2]) {
        return board[i] == 'X' ? 10 : -10;
      }
    }
    for (int i = 0; i < 3; i++) {
      if (board[i] != '' && board[i] == board[i + 3] && board[i] == board[i + 6]) {
        return board[i] == 'X' ? 10 : -10;
      }
    }
    if (board[0] != '' && board[0] == board[4] && board[0] == board[8]) {
      return board[0] == 'X' ? 10 : -10;
    }
    if (board[2] != '' && board[2] == board[4] && board[2] == board[6]) {
      return board[2] == 'X' ? 10 : -10;
    }
    if (!board.contains('')) return 0;

    // Minimax algorithm
    if (isMaximizing) {
      int bestScore = -1000;
      for (int i = 0; i < 9; i++) {
        if (board[i] == '') {
          board[i] = 'X';
          int score = _minimax(board, false);
          board[i] = '';
          bestScore = max(score, bestScore);
        }
      }
      return bestScore;
    } else {
      int bestScore = 1000;
      for (int i = 0; i < 9; i++) {
        if (board[i] == '') {
          board[i] = 'O';
          int score = _minimax(board, true);
          board[i] = '';
          bestScore = min(score, bestScore);
        }
      }
      return bestScore;
    }
  }

  void playingComputer() {
    int bestScore = -1000;
    int bestMove = 0;
    for (int i = 0; i < 9; i++) {
      if (display[i] == '') {
        display[i] = 'X';
        int score = _minimax(display, false);
        display[i] = '';
        if (score > bestScore) {
          bestScore = score;
          bestMove = i;
        }
      }
    }
    setState(() {
      display[bestMove] = 'X';
      isOTurn = true;
      checkWinner();
    });
  }

  void _showModeSelectionDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Choose Game Mode'),
          content: Text('Would you like to play with the computer or a human?'),
          actions: [
            TextButton(
              onPressed: () {
                setState(() {
                  playWithComputer = false;
                });
                Navigator.of(context).pop();
              },
              child: Text('Play with Human'),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  playWithComputer = true;
                });
                Navigator.of(context).pop();
              },
              child: Text('Play with Computer'),
            ),
          ],
        );
      },
    );
  }
}
