import 'dart:convert'; // Make sure to import for JSON decoding
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tranquil_mindv1/main.dart';
import 'package:tranquil_mindv1/screens/edit_profile_page.dart';
import 'package:tranquil_mindv1/utils/config.dart';
import '../providers/dio_provider.dart';

class ProfilePage extends StatefulWidget {
  ProfilePage({Key? key}) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String name = '';
  String age = '';
  String gender = '';
  String profilePhotoUrl =
      ''; // Assuming profile photo URL might also be needed

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';

    if (token.isNotEmpty) {
      final userData = await DioProvider().getUser(token);
      if (userData != null) {
        final decodedData = json.decode(userData);
        setState(() {
          name = decodedData['name'] ?? 'N/A';
          age =
              decodedData['age']?.toString() ?? 'N/A'; // Convert age to string
          gender = decodedData['gender'] ?? 'N/A';
          profilePhotoUrl = decodedData['profile_photo_url'] ??
              ''; // If profile photo URL is included
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          flex: 4,
          child: Container(
            width: double.infinity,
            color: Config.primaryColor,
            child: Column(
              children: [
                SizedBox(height: 150),
                SizedBox(height: 10),
                Text(
                  name.isNotEmpty ? name : 'Loading...',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  age.isNotEmpty && gender.isNotEmpty
                      ? '$age Years Old | $gender'
                      : 'Loading...',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                  ),
                ),
              ],
            ),
          ),
        ),
        Expanded(
          flex: 5,
          child: Container(
            color: Colors.grey[200],
            child: Center(
              child: Card(
                margin: const EdgeInsets.fromLTRB(0, 45, 0, 0),
                child: Container(
                  width: 300,
                  height: 190,
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          const Text(
                            'Profile',
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          Divider(
                            color: Colors.grey[300],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Icon(
                                Icons.person,
                                color: Colors.blueAccent[400],
                                size: 35,
                              ),
                              const SizedBox(width: 20),
                              TextButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            EditProfilePage()),
                                  );
                                },
                                child: const Text(
                                  "Profile",
                                  style: TextStyle(
                                    color: Config.primaryColor,
                                    fontSize: 15,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Config.spaceSmall,
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Icon(
                                Icons.logout_outlined,
                                color: Colors.lightGreen[400],
                                size: 35,
                              ),
                              const SizedBox(width: 20),
                              TextButton(
                                onPressed: () async {
                                  final SharedPreferences prefs =
                                      await SharedPreferences.getInstance();
                                  final token = prefs.getString('token') ?? '';

                                  if (token.isNotEmpty && token != '') {
                                    final response =
                                        await DioProvider().logout(token);

                                    if (response == 200) {
                                      await prefs.remove('token');
                                      setState(() {
                                        MyApp.navigatorKey.currentState!
                                            .pushReplacementNamed('/');
                                      });
                                    }
                                  }
                                },
                                child: const Text(
                                  "Logout",
                                  style: TextStyle(
                                    color: Config.primaryColor,
                                    fontSize: 15,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
