// viewdass_page.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tranquil_mindv1/providers/dio_provider.dart';
//import 'package:tranquil_mindv1/utils/config.dart';

class ViewDassPage extends StatefulWidget {
  @override
  _ViewDassPageState createState() => _ViewDassPageState();
}

class _ViewDassPageState extends State<ViewDassPage> {
  late Future<List<dynamic>> dassResults;

  @override
  void initState() {
    super.initState();
    dassResults = fetchDassResults();
  }

  Future<List<dynamic>> fetchDassResults() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';
    if (token == '') {
      throw Exception('Token is empty');
    }
    return DioProvider().getDASS(token);
  }

  String getCategoryDescription(int category) {
    if (category >= 0 && category <= 18) {
      return 'Normal';
    } else if (category >= 19 && category <= 23) {
      return 'Mild';
    } else if (category >= 24 && category <= 33) {
      return 'Moderate';
    } else if (category >= 34 && category <= 48) {
      return 'Severe';
    } else if (category >= 49 && category <= 63) {
      return 'Extremely Severe';
    } else {
      return 'Unknown';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('DASS Results'),
      ),
      body: FutureBuilder<List<dynamic>>(
        future: dassResults,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No results found'));
          } else {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                var result = snapshot.data![index];
                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Depression Score: ${result['depression_score']}',
                          style: TextStyle(fontSize: 16),
                        ),
                        Text(
                          'Anxiety Score: ${result['anxiety_score']}',
                          style: TextStyle(fontSize: 16),
                        ),
                        Text(
                          'Stress Score: ${result['stress_score']}',
                          style: TextStyle(fontSize: 16),
                        ),
                        Text(
                          'Category: ${getCategoryDescription(result['category'])}',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          'Date: ${result['created_at']}',
                          style: TextStyle(fontSize: 14, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}
