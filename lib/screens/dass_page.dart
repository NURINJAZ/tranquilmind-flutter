import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tranquil_mindv1/main.dart';
import 'package:tranquil_mindv1/providers/dio_provider.dart';
import '../components/question_card.dart';
import '../utils/config.dart';

class DassFormScreen extends StatefulWidget {
  @override
  _DassFormScreenState createState() => _DassFormScreenState();
}

class _DassFormScreenState extends State<DassFormScreen> {
  final PageController _pageController = PageController();
  final List<String> depressionQuestions = [
    "I couldn't seem to experience any positive feeling at all*",
    "I found it difficult to work up the initiative to do things*",
    "I felt that I had nothing to look forward to*",
    "I felt down-hearted and blue*",
    "I was unable to become enthusiastic about anything*",
    "I felt I wasn't worth much as a person*",
    "I felt that life was meaningless*"
  ];

  final List<String> anxietyQuestions = [
    "I was aware of dryness of my mouth*",
    "I experienced breathing difficulty (e.g., excessively rapid breathing, breathlessness in the absence of physical exertion)*",
    "I experienced trembling (e.g., in the hands)*",
    "I was worried about situations in which I might panic and make a fool of myself*",
    "I felt I was close to panic*",
    "I was aware of the action of my heart in the absence of physical exertion (e.g., sense of heart rate increase, heart missing a beat)*",
    "I felt scared without any good reason*"
  ];

  final List<String> stressQuestions = [
    "I found it hard to wind down*",
    "I tended to over-react to situations*",
    "I felt that I was using a lot of nervous energy*",
    "I found myself getting agitated*",
    "I found it difficult to relax*",
    "I was intolerant of anything that kept me from getting on with what I was doing*",
    "I felt that I was rather touchy*"
  ];

  final List<int?> depressionAnswers = List.filled(7, null);
  final List<int?> anxietyAnswers = List.filled(7, null);
  final List<int?> stressAnswers = List.filled(7, null);

  int currentPage = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('DASS Form'),
        backgroundColor: Config.primaryColor,
      ),
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            currentPage = index;
          });
        },
        children: <Widget>[
          _buildQuestionPage(
              'Depression', depressionQuestions, depressionAnswers),
          _buildQuestionPage('Anxiety', anxietyQuestions, anxietyAnswers),
          _buildQuestionPage('Stress', stressQuestions, stressAnswers),
        ],
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            if (currentPage > 0)
              ElevatedButton(
                onPressed: () {
                  _pageController.previousPage(
                      duration: Duration(milliseconds: 300),
                      curve: Curves.ease);
                },
                child: Text('Previous'),
              ),
            ElevatedButton(
              onPressed: () {
                if (_areAllQuestionsAnswered(currentPage)) {
                  if (currentPage < 2) {
                    _pageController.nextPage(
                        duration: Duration(milliseconds: 300),
                        curve: Curves.ease);
                  } else {
                    _calculateAndShowResults();
                  }
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Please answer all the questions.'),
                    ),
                  );
                }
              },
              child: Text(currentPage < 2 ? 'Next' : 'Submit'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuestionPage(
      String title, List<String> questions, List<int?> answers) {
    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            'DEPRESSION ANXIETY STRESS TEST (DASS)',
            style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            'Please read each statement and select a number 0, 1, 2, or 3 that indicates how much the statement applied to you over the past week.\n\n'
            'Sila baca setiap kenyataan di bawah dan pilih jawapan 0, 1, 2, or 3 bagi menggambarkan keadaan anda sepanjang minggu yang lalu.',
            style: TextStyle(fontSize: 16.0),
          ),
        ),
        Divider(),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            title,
            style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
          ),
        ),
        ...List.generate(questions.length, (index) {
          return QuestionCard(
            question: questions[index],
            index: answers[index],
            onChanged: (value) {
              setState(() {
                answers[index] = value;
              });
            },
          );
        }),
      ],
    );
  }

  bool _areAllQuestionsAnswered(int page) {
    List<int?> answers;
    if (page == 0) {
      answers = depressionAnswers;
    } else if (page == 1) {
      answers = anxietyAnswers;
    } else {
      answers = stressAnswers;
    }
    return answers.every((answer) => answer != null);
  }

  void _calculateAndShowResults() async {
    final depressionScore =
        depressionAnswers.where((e) => e != null).reduce((a, b) => a! + b!)!;
    final anxietyScore =
        anxietyAnswers.where((e) => e != null).reduce((a, b) => a! + b!)!;
    final stressScore =
        stressAnswers.where((e) => e != null).reduce((a, b) => a! + b!)!;

    String getScoreStatus(int score) {
      if (score >= 0 && score <= 5) {
        return 'Normal';
      } else if (score >= 6 && score <= 9) {
        return 'Mild';
      } else if (score >= 10 && score <= 13) {
        return 'Moderate';
      } else if (score >= 14 && score <= 17) {
        return 'Severe';
      } else if (score >= 18 && score <= 21) {
        return 'Extremely Severe';
      } else {
        return 'Unknown';
      }
    }

    final depressionStatus = getScoreStatus(depressionScore);
    final anxietyStatus = getScoreStatus(anxietyScore);
    final stressStatus = getScoreStatus(stressScore);
    final totalScore = depressionScore + anxietyScore + stressScore;

    String getTotalScoreStatus(int score) {
      if (score >= 0 && score <= 18) {
        return 'Normal';
      } else if (score >= 19 && score <= 23) {
        return 'Mild';
      } else if (score >= 24 && score <= 33) {
        return 'Moderate';
      } else if (score >= 34 && score <= 48) {
        return 'Severe';
      } else if (score >= 49 && score <= 63) {
        return 'Extremely Severe';
      } else {
        return 'Unknown';
      }
    }

    String getMessageBasedOnTotalStatus(String status) {
      switch (status) {
        case 'Normal':
          return "You're managing well. Remember to take time for self-care.";
        case 'Mild':
          return "It's okay to feel this way sometimes. Taking breaks and talking about it can help.";
        case 'Moderate':
          return "It's important to take care of yourself right now. Consider seeking professional advice.";
        case 'Severe':
          return "This level of stress deserves attention. Don't hesitate to reach out for professional help.";
        case 'Extremely Severe':
          return "Please prioritize your well-being and seek professional support immediately.";
        default:
          return 'Unknown';
      }
    }

    final totalStatus = getTotalScoreStatus(totalScore);
    final totalMessage = getMessageBasedOnTotalStatus(totalStatus);

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';

    final dioProvider = DioProvider();
    final result = await dioProvider.storeDassResults(
      depressionScore,
      anxietyScore,
      stressScore,
      totalScore,
      token,
    );

    if (result == 200) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('DASS Results'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Depression: $depressionScore ($depressionStatus)'),
                Text('Anxiety: $anxietyScore ($anxietyStatus)'),
                Text('Stress: $stressScore ($stressStatus)'),
                SizedBox(height: 16),
                Text('Total Score: $totalScore ($totalStatus)'),
                SizedBox(height: 16),
                Text(totalMessage,
                    style: TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
            actions: <Widget>[
              TextButton(
                child: Text('OK'),
                onPressed: () {
                  Navigator.of(context).pop(); // Close the dialog
                  MyApp.navigatorKey.currentState!
                      .pushNamed('main'); // Navigate to 'main' route
                },
              ),
            ],
          );
        },
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to store DASS results. Please try again.'),
        ),
      );
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
}
