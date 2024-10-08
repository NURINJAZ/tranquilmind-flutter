import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:tranquil_mindv1/components/appointment_card.dart';
import 'package:tranquil_mindv1/components/doctor_card.dart';
import 'package:tranquil_mindv1/models/auth_model.dart';
import 'package:tranquil_mindv1/screens/dass_page.dart'; // Import your DassFormScreen
import 'package:tranquil_mindv1/screens/viewdass_page.dart';
import 'package:tranquil_mindv1/utils/config.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late Map<String, dynamic> user;
  late Map<String, dynamic> doctor;
  late List<dynamic> favList;
  List<Map<String, dynamic>> medCat = [];

  @override
  void initState() {
    super.initState();
    // Initialize user, doctor, and favList
    user = Provider.of<AuthModel>(context, listen: false).getUser;
    doctor = Provider.of<AuthModel>(context, listen: false).getAppointment;
    favList = Provider.of<AuthModel>(context, listen: false).getFav;

    // Initialize medCat after user, doctor, and favList are fetched
    medCat = [
      {
        "icon": FontAwesomeIcons.stethoscope,
        "category": "DASS Test",
        "onTap": () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => DassFormScreen()),
          );
        },
      },
      {
        "icon": FontAwesomeIcons.heartPulse,
        "category": "DASS history",
        "onTap": () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => ViewDassPage()),
          );
        }, // You can define similar onTap functions for other categories
      },
    ];
  }

  @override
  Widget build(BuildContext context) {
    Config().init(context); // Initialize configuration

    return Scaffold(
      //if user is empty, then return progress indicator
      body: user.isEmpty
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 15,
                vertical: 15,
              ),
              child: SafeArea(
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Text(
                            user['name'],
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      Config.spaceMedium,
                      const Text(
                        'Self-Help Tools123',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Config.spaceSmall,
                      SizedBox(
                        height: Config.heightSize * 0.05,
                        child: ListView(
                          scrollDirection: Axis.horizontal,
                          children:
                              List<Widget>.generate(medCat.length, (index) {
                            return InkWell(
                              onTap: () {
                                medCat[index]
                                    ['onTap'](); // Invoke onTap function
                              },
                              child: Card(
                                margin: const EdgeInsets.only(right: 20),
                                color: Config.primaryColor,
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 15, vertical: 10),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceAround,
                                    children: <Widget>[
                                      FaIcon(
                                        medCat[index]['icon'],
                                        color: Colors.white,
                                      ),
                                      const SizedBox(
                                        width: 20,
                                      ),
                                      Text(
                                        medCat[index]['category'],
                                        style: const TextStyle(
                                          fontSize: 16,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          }),
                        ),
                      ),
                      Config.spaceSmall,
                      const Text(
                        'Appointment Today',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Config.spaceSmall,
                      doctor.isNotEmpty
                          ? AppointmentCard(
                              doctor: doctor,
                              color: Config.primaryColor,
                            )
                          : Container(
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: Colors.grey.shade300,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Center(
                                child: Padding(
                                  padding: EdgeInsets.all(20),
                                  child: Text(
                                    'No Appointment Today',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                      Config.spaceSmall,
                      const Text(
                        'Top Doctors',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Config.spaceSmall,
                      Column(
                        children: List.generate(user['doctor'].length, (index) {
                          return DoctorCard(
                            doctor: user['doctor'][index],
                            //if latest fav list contains particular doctor id, then show fav icon
                            isFav: favList
                                    .contains(user['doctor'][index]['doc_id'])
                                ? true
                                : false,
                          );
                        }),
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}
