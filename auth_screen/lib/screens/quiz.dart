// ignore_for_file: use_build_context_synchronously

import 'dart:math';
import 'package:flutter/material.dart';
import 'package:auth_screen/questions.dart';
import 'package:auth_screen/screens/home_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';

class QuizScreen extends StatefulWidget {
  const QuizScreen({super.key});

  @override
  QuizScreenState createState() => QuizScreenState();
}

class QuizScreenState extends State<QuizScreen> {
  late List<Map<String, dynamic>> questions;
  int correctAnswers = 0;
  int totalAnswered = 0;

  @override
  void initState() {
    super.initState();
    questions = List.from(questionData);
    questions.shuffle();
    questions = questions.sublist(0, min(3, questions.length));
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showIntroPopup();
    });
  }

  void updateCorrectAnswers(bool isCorrect) {
    setState(() {
      if (isCorrect) {
        correctAnswers++;
      }
      totalAnswered++;
    });
  }

  Future<void> updatePointsInFirestore() async {
    String userId = FirebaseAuth.instance.currentUser!.uid;
    var userDocRef = FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('portfolio')
        .doc('details');

    var userDocSnapshot = await userDocRef.get();
    var userData = userDocSnapshot.data() ?? {};

    double currentPoints = userData.containsKey('points')
        ? (userData['points'] as num).toDouble()
        : 0.0;
    double newPoints = currentPoints + correctAnswers;

    await userDocRef.set({
      'points': newPoints,
    }, SetOptions(merge: true));
  }

  void _showIntroPopup() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text(
            'Quiz Instructions',
            style: GoogleFonts.montserrat(
              fontWeight: FontWeight.bold,
              color: const Color(0xFF3A5199),
            ),
            textAlign: TextAlign.center,
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.quiz_rounded,
                size: 60,
                color: Color(0xFF3A5199),
              ),
              const SizedBox(height: 16),
              Text(
                'Answer these three questions about trading and investing.',
                style: GoogleFonts.montserrat(),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'You\'ll earn 1 point for each correct answer!',
                style: GoogleFonts.montserrat(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 8, horizontal: 20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF3A5199), Color(0xFF8C9EFF)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Text(
                  'Start Quiz',
                  style: GoogleFonts.montserrat(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showResultsDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text(
            'Quiz Results',
            style: GoogleFonts.montserrat(
              fontWeight: FontWeight.bold,
              fontSize: 22,
              color: const Color(0xFF3A5199),
            ),
            textAlign: TextAlign.center,
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                correctAnswers == questions.length
                    ? Icons.emoji_events_rounded
                    : correctAnswers >= questions.length / 2
                        ? Icons.check_circle_rounded
                        : Icons.sentiment_neutral_rounded,
                size: 70,
                color: correctAnswers == questions.length
                    ? Colors.amber
                    : correctAnswers >= questions.length / 2
                        ? Colors.green
                        : Colors.orange,
              ),
              const SizedBox(height: 16),
              Text(
                'You scored:',
                style: GoogleFonts.montserrat(),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                '$correctAnswers out of ${questions.length}',
                style: GoogleFonts.montserrat(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF3A5199),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                correctAnswers == questions.length
                    ? 'Perfect score! Amazing job!'
                    : correctAnswers >= questions.length / 2
                        ? 'Well done! Keep learning!'
                        : 'Keep practicing to improve your score!',
                style: GoogleFonts.montserrat(
                  fontStyle: FontStyle.italic,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () async {
                await updatePointsInFirestore();
                Navigator.pop(context);
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const HomePage()),
                  (route) => false,
                );
              },
              child: Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 10, horizontal: 24),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF3A5199), Color(0xFF8C9EFF)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Text(
                  'Return to Home',
                  style: GoogleFonts.montserrat(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        title: Text(
          'Knowledge Quiz',
          style: GoogleFonts.montserrat(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF3A5199),
              Color(0xFF62B6CB),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Progress indicator
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 20.0, vertical: 10.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Progress:',
                          style: GoogleFonts.montserrat(
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          '$totalAnswered/${questions.length} Questions',
                          style: GoogleFonts.montserrat(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: LinearProgressIndicator(
                        value: questions.isEmpty
                            ? 0
                            : totalAnswered / questions.length,
                        backgroundColor: Colors.white.withOpacity(0.2),
                        color: Colors.white,
                        minHeight: 8,
                      ),
                    ),
                  ],
                ),
              ),

              // Question cards
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 80),
                  itemCount: questions.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: QuestionCard(
                        question: questions[index]['question'],
                        options: questions[index]['options'],
                        answer: questions[index]['answer'],
                        updateCorrectAnswers: updateCorrectAnswers,
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showResultsDialog,
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF3A5199),
        elevation: 4,
        label: Text(
          'Submit',
          style: GoogleFonts.montserrat(fontWeight: FontWeight.bold),
        ),
        icon: const Icon(Icons.check_circle),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}

class QuestionCard extends StatefulWidget {
  final String question;
  final Map<String, String> options;
  final String answer;
  final Function(bool) updateCorrectAnswers;

  const QuestionCard({
    super.key,
    required this.question,
    required this.options,
    required this.answer,
    required this.updateCorrectAnswers,
  });

  @override
  QuestionCardState createState() => QuestionCardState();
}

class QuestionCardState extends State<QuestionCard>
    with SingleTickerProviderStateMixin {
  String? selectedOption;
  String? correctAnswer;
  bool answerChecked = false;
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void handleAnswerCheck() {
    bool isCorrect = selectedOption == widget.answer;
    widget.updateCorrectAnswers(isCorrect);
    setState(() {
      correctAnswer = widget.options[widget.answer];
      answerChecked = true;
    });
    _animationController.forward();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: Colors.white,
        ),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Question text
              Text(
                widget.question,
                style: GoogleFonts.montserrat(
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF3A5199),
                ),
              ),
              const Divider(height: 20, thickness: 1),

              // Options list
              Column(
                children: widget.options.entries.map((option) {
                  final isSelected = selectedOption == option.key;
                  final isCorrect =
                      answerChecked && option.key == widget.answer;
                  final isWrong = answerChecked &&
                      isSelected &&
                      option.key != widget.answer;

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Material(
                      color: isCorrect
                          ? Colors.green.withOpacity(0.1)
                          : isWrong
                              ? Colors.red.withOpacity(0.1)
                              : isSelected
                                  ? const Color(0xFF3A5199).withOpacity(0.1)
                                  : Colors.grey.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(12),
                      child: InkWell(
                        onTap: answerChecked
                            ? null
                            : () {
                                setState(() {
                                  selectedOption = option.key;
                                });
                              },
                        borderRadius: BorderRadius.circular(12),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 12.0, horizontal: 16.0),
                          child: Row(
                            children: [
                              Container(
                                width: 24,
                                height: 24,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: isSelected
                                      ? const Color(0xFF3A5199)
                                      : Colors.white,
                                  border: Border.all(
                                    color: isCorrect
                                        ? Colors.green
                                        : isWrong
                                            ? Colors.red
                                            : isSelected
                                                ? const Color(0xFF3A5199)
                                                : Colors.grey,
                                    width: 2,
                                  ),
                                ),
                                child: isSelected
                                    ? const Icon(
                                        Icons.check,
                                        size: 16,
                                        color: Colors.white,
                                      )
                                    : null,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  option.value,
                                  style: GoogleFonts.montserrat(
                                    fontSize: 16,
                                    color: isCorrect
                                        ? Colors.green
                                        : isWrong
                                            ? Colors.red
                                            : Colors.black87,
                                    fontWeight: isSelected
                                        ? FontWeight.w600
                                        : FontWeight.normal,
                                  ),
                                ),
                              ),
                              if (answerChecked)
                                Icon(
                                  isCorrect
                                      ? Icons.check_circle
                                      : isWrong
                                          ? Icons.cancel
                                          : null,
                                  color: isCorrect ? Colors.green : Colors.red,
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),

              const SizedBox(height: 16),

              // Check Answer button
              if (selectedOption != null && !answerChecked)
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: handleAnswerCheck,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF3A5199),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      elevation: 2,
                    ),
                    child: Text(
                      'Check Answer',
                      style: GoogleFonts.montserrat(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),

              // Answer feedback
              if (answerChecked)
                FadeTransition(
                  opacity: _animation,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    margin: const EdgeInsets.only(top: 8),
                    decoration: BoxDecoration(
                      color: selectedOption == widget.answer
                          ? Colors.green.withOpacity(0.1)
                          : Colors.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: selectedOption == widget.answer
                            ? Colors.green
                            : Colors.red,
                        width: 1,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              selectedOption == widget.answer
                                  ? Icons.check_circle
                                  : Icons.info,
                              color: selectedOption == widget.answer
                                  ? Colors.green
                                  : Colors.red,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              selectedOption == widget.answer
                                  ? 'Correct!'
                                  : 'Incorrect',
                              style: GoogleFonts.montserrat(
                                fontWeight: FontWeight.bold,
                                color: selectedOption == widget.answer
                                    ? Colors.green
                                    : Colors.red,
                              ),
                            ),
                          ],
                        ),
                        if (selectedOption != widget.answer) ...[
                          const SizedBox(height: 8),
                          Text(
                            'Correct answer: $correctAnswer',
                            style: GoogleFonts.montserrat(
                              fontWeight: FontWeight.w500,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
