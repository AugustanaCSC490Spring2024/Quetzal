// ignore_for_file: dangling_library_doc_comments, unnecessary_cast

import 'package:flutter/material.dart';
import 'package:auth_screen/screens/quiz.dart';
import 'package:auth_screen/screens/speed_run_game.dart';
import 'package:auth_screen/screens/leaderboard.dart';
import 'package:animated_text_kit/animated_text_kit.dart';

class GameScreen extends StatelessWidget {
  const GameScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Mario GIF background with opacity
          Positioned.fill(
            child: Opacity(
              opacity: 0.3, // Adjust the opacity value as needed
              child: Image.asset(
                'assets/images/mario.gif', // Ensure the path is correct
                fit: BoxFit.cover,
              ),
            ),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildGameButton(context, 'Quiz', const QuizScreen()),
              _buildGameButton(context, 'Speed Run', const Speedrun()),
              _buildGameButton(context, 'Leaderboard', const Leaderboard()),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGameButton(BuildContext context, String label, Widget targetScreen) {
    return Expanded(
      child: Center(
        child: GestureDetector(
          onTapDown: (_) => _navigateToScreen(context, targetScreen),
          child: Container(
            padding: const EdgeInsets.all(20),
            margin: const EdgeInsets.symmetric(vertical: 20),
            decoration: BoxDecoration(
              image: const DecorationImage(
                image: AssetImage('assets/images/wood.jpg'), // Wood texture background
                fit: BoxFit.cover,
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: DefaultTextStyle(
              style: const TextStyle(
                fontSize: 40.0,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
              child: AnimatedTextKit(
                animatedTexts: [
                  WavyAnimatedText(label),
                ],
                isRepeatingAnimation: true,
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _navigateToScreen(BuildContext context, Widget screen) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => screen),
    );
  }
}
