import 'package:course_app_1/quiz.dart';
import 'package:course_app_1/result.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  var _questionIndex = 0;
  int _totalScore = 0;

  static const _questions = [
    {
      "questionText": "What's your favorite color?",
      "answers": [
        {"text": "Black", "score": 10},
        {"text": "Red", "score": 6},
        {"text": "Green", "score": 3},
        {"text": "White", "score": 1}
      ],
    },
    {
      "questionText": "What's your favorite animal?",
      "answers": [
        {"text": "Rabbit", "score": 10},
        {"text": "Snake", "score": 6},
        {"text": "Elephant", "score": 3},
        {"text": "Lion", "score": 1}
      ],
    },
    {
      "questionText": "Who's your favorite instructor?",
      "answers": [
        {"text": "Max", "score": 10},
        {"text": "Max", "score": 10},
        {"text": "Max", "score": 10},
        {"text": "Max", "score": 1}
      ],
    }
  ];

  void _answerQuestion(int score) {
    _totalScore += score;

    setState(() {
      _questionIndex++;
    });

    if (_questionIndex < _questions.length) {
      print("We have more questions");
    }

    print(_questionIndex);
    print(_totalScore);
  }

  void _resetQuiz() {
    setState(() {
      _questionIndex = 0;
      _totalScore = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        home: Scaffold(
      appBar: AppBar(
        title: Text("My First App"),
      ),
      body: _questionIndex < _questions.length
          ? Quiz(
              answerQuestion: _answerQuestion,
              questions: _questions,
              questionIndex: _questionIndex)
          : Result(_totalScore, _resetQuiz),
    ));
  }
}
