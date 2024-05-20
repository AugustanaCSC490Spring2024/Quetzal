// ignore_for_file: use_build_context_synchronously

import 'dart:math';
import 'package:flutter/material.dart';
import 'package:auth_screen/questions.dart';
import 'package:auth_screen/screens/home_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class QuizScreen extends StatefulWidget {
  const QuizScreen({super.key});

  @override
  QuizScreenState createState() => QuizScreenState();
}

class QuizScreenState extends State<QuizScreen> {
  late List<Map<String, dynamic>> questions;
  int currentQuestionIndex = 0;
  int correctAnswers = 0;
  bool showQuestion = true;
  bool showNextButton = false;

  @override
  void initState() {
    super.initState();
    questions = List.from(questionData);
    questions.shuffle();
    questions = questions.sublist(0, min(3, questions.length));
    _showInstructionsPopup();
  }

  void _showInstructionsPopup() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Quiz Instructions'),
          content: const SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Test your stock IQ'),
                Text('You get one point per correct answer.'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Start'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void updateCorrectAnswers(bool isCorrect) {
    setState(() {
      if (isCorrect) {
        correctAnswers++;
      }
      showNextButton = true;
    });
  }

  Future<void> updatePointsInFirestore() async {
    String userId = FirebaseAuth.instance.currentUser!.uid;
    var userDocRef = FirebaseFirestore.instance.collection('users').doc(userId).collection('portfolio').doc('details');

    var userDocSnapshot = await userDocRef.get();
    var userData = userDocSnapshot.data() ?? {};

    double currentPoints = userData.containsKey('points') ? userData['points'] : 0;
    double newPoints = currentPoints + correctAnswers;

    await userDocRef.set({
      'points': newPoints,
    }, SetOptions(merge: true));
  }

  void nextQuestion() {
    if (currentQuestionIndex < questions.length - 1) {
      setState(() {
        showQuestion = false;
      });
      Future.delayed(const Duration(seconds: 1), () {
        setState(() {
          currentQuestionIndex++;
          showQuestion = true;
          showNextButton = false;
        });
      });
    } else {
      _showResultsDialog();
    }
  }

  void _showResultsDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Quiz Result'),
          backgroundColor: const Color.fromRGBO(171, 200, 192, 1),
          content: Text('You got $correctAnswers out of ${questions.length} correct!'),
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
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('QUIZ'),
        automaticallyImplyLeading: true, // Add back button
      ),
      body: Stack(
        children: [
          // Background image
          Positioned.fill(
            child: Image.asset(
              'assets/images/fin.jpg', // Ensure the path is correct
              fit: BoxFit.cover,
            ),
          ),
          Center(
            child: AnimatedOpacity(
              opacity: showQuestion ? 1.0 : 0.0,
              duration: const Duration(seconds: 1),
              child: QuestionCard(
                key: ValueKey(currentQuestionIndex),
                question: questions[currentQuestionIndex]['question'],
                options: questions[currentQuestionIndex]['options'],
                answer: questions[currentQuestionIndex]['answer'],
                updateCorrectAnswers: updateCorrectAnswers,
                showNextButton: showNextButton,
                nextQuestion: nextQuestion,
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showResultsDialog,
        child: const Icon(Icons.check),
      ),
    );
  }
}

class QuestionCard extends StatefulWidget {
  final String question;
  final Map<String, String> options;
  final String answer;
  final Function(bool) updateCorrectAnswers;
  final bool showNextButton;
  final VoidCallback nextQuestion;

  const QuestionCard({
    required Key key,
    required this.question,
    required this.options,
    required this.answer,
    required this.updateCorrectAnswers,
    required this.showNextButton,
    required this.nextQuestion,
  }) : super(key: key);

  @override
  QuestionCardState createState() => QuestionCardState();
}

class QuestionCardState extends State<QuestionCard> {
  String? selectedOption;
  String? correctAnswer;
  bool answerChecked = false;

  void handleAnswerCheck() {
    bool isCorrect = selectedOption == widget.answer;
    widget.updateCorrectAnswers(isCorrect);
    setState(() {
      correctAnswer = widget.options[widget.answer];
      answerChecked = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16.0),
      color: const Color.fromARGB(255, 12, 144, 201),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.question,
              style: const TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            const SizedBox(height: 16.0),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: widget.options.entries.map((option) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: RadioListTile(
                    title: Text(option.value, style: const TextStyle(color: Colors.white)),
                    groupValue: selectedOption,
                    value: option.key,
                    onChanged: answerChecked
                        ? null
                        : (value) {
                            setState(() {
                              selectedOption = value.toString();
                            });
                          },
                  ),
                );
              }).toList(),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (selectedOption != null)
                  ElevatedButton(
                    onPressed: answerChecked ? null : handleAnswerCheck,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.green,
                      padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 24.0),
                      textStyle: const TextStyle(fontSize: 18),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text('Check Answer'),
                  ),
                if (widget.showNextButton)
                  ElevatedButton(
                    onPressed: widget.nextQuestion,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.blue,
                      padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 24.0),
                      textStyle: const TextStyle(fontSize: 18),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text('Next'),
                  ),
              ],
            ),
            if (correctAnswer != null)
              Text(
                'Correct answer: $correctAnswer',
                style: TextStyle(
                  color: selectedOption == widget.answer ? const Color.fromARGB(255, 4, 60, 3) : Colors.red,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
