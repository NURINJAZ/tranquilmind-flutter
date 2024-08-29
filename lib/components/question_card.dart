import 'package:flutter/material.dart';

class QuestionCard extends StatelessWidget {
  final String question;
  final int? index;
  final Function(int) onChanged;

  QuestionCard({
    required this.question,
    required this.index,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              question,
              style: TextStyle(fontSize: 16.0),
            ),
            Column(
              children: List.generate(4, (i) {
                return Row(
                  children: <Widget>[
                    Radio<int>(
                      value: i,
                      groupValue: index,
                      onChanged: (int? value) {
                        if (value != null) {
                          onChanged(value);
                        }
                      },
                    ),
                    Text('$i'),
                  ],
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
} 

/*import 'package:flutter/material.dart';

class QuestionCard extends StatelessWidget {
  final String question;
  final int? index;
  final Function(int) onChanged;

  QuestionCard({
    required this.question,
    required this.index,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              question,
              style: TextStyle(fontSize: 16.0),
            ),
            Slider(
              value: index?.toDouble() ?? 0.0,
              min: 0.0,
              max: 3.0,
              divisions: 3,
              label: index?.toString() ?? '0',
              onChanged: (double value) {
                onChanged(value.round());
              },
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text('0'),
                Text('1'),
                Text('2'),
                Text('3'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}*/
