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
  int correctAnswers = 0;

  @override
  void initState() {
    super.initState();
    questions = List.from(questionData);
    questions.shuffle();
    questions = questions.sublist(0, min(3, questions.length));
  }

  void updateCorrectAnswers(bool isCorrect) {
    setState(() {
      if (isCorrect) {
        correctAnswers++;
      }
    });
  }

  Future<void> updatePointsInFirestore() async {
    String userId = FirebaseAuth.instance.currentUser!.uid;
    var userDocRef = FirebaseFirestore.instance.collection('users').doc(userId).collection('portfolio').doc('details');

    var userDocSnapshot = await userDocRef.get();
    var userData = userDocSnapshot.data() ?? {};

    int currentPoints = userData.containsKey('points') ? userData['points'] : 0;
    int newPoints = currentPoints + correctAnswers;

    await userDocRef.set({
      'points': newPoints,
    }, SetOptions(merge: true));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('QUIZ'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const HomePage()),
            );
          },
        ),
      ),
      backgroundColor: const Color.fromRGBO(171, 200, 192, 1),
      body: ListView.builder(
        itemCount: questions.length,
        itemBuilder: (context, index) {
          return QuestionCard(
            question: questions[index]['question'],
            options: questions[index]['options'],
            answer: questions[index]['answer'],
            updateCorrectAnswers: updateCorrectAnswers,
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await updatePointsInFirestore();
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text('Quiz Result'),
                backgroundColor: const Color.fromRGBO(171, 200, 192, 1),
                content: Text('You got $correctAnswers out of ${questions.length} correct!'),
                actions: <Widget>[
                  TextButton(
                    onPressed: () {
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
        },
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

class QuestionCardState extends State<QuestionCard> {
  String? selectedOption;
  String? correctAnswer;
  bool answerChecked = false;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(6.0),
      color: const Color.fromARGB(255, 12, 144, 201),
      child: Padding(
        padding: const EdgeInsets.all(14.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.question,
              style: const TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8.0),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: widget.options.entries.map((option) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 6.0),
                  child: RadioListTile(
                    title: Text(option.value),
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
            if (selectedOption != null)
              ElevatedButton(
                onPressed: answerChecked
                    ? null
                    : () {
                        bool isCorrect = selectedOption == widget.answer;
                        widget.updateCorrectAnswers(isCorrect);
                        setState(() {
                          correctAnswer = widget.options[widget.answer];
                          answerChecked = true;
                        }); // <- Missing parenthesis added here
                      },
                child: const Text('Check Answer'),
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
