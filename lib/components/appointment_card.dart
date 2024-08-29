import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:rating_dialog/rating_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tranquil_mindv1/main.dart';
import 'package:tranquil_mindv1/providers/dio_provider.dart';
import 'package:tranquil_mindv1/utils/config.dart';

class AppointmentCard extends StatefulWidget {
  const AppointmentCard({Key? key, required this.doctor, required this.color})
      : super(key: key);

  final Map<String, dynamic> doctor;
  final Color color;

  @override
  State<AppointmentCard> createState() => _AppointmentCardState();
}

class _AppointmentCardState extends State<AppointmentCard> {
  late Future<List<dynamic>> _appointmentsFuture;

  @override
  void initState() {
    super.initState();
    _appointmentsFuture = _fetchAppointments();
  }

  Future<List<dynamic>> _fetchAppointments() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';
    final appointments = await DioProvider().getAppointments(token);

    if (appointments != 'Error') {
      return json.decode(appointments);
    } else {
      throw Exception('Failed to load appointments');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: widget.color,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: FutureBuilder<List<dynamic>>(
          future: _appointmentsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicator();
            } else if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Container(
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
              );
            } else {
              var appointment = snapshot
                  .data![0]; // Assuming you're using the first appointment
              return Column(
                children: <Widget>[
                  Row(
                    children: [
                      CircleAvatar(
                        backgroundImage: NetworkImage(
                            "http://tranquilmind.icu${widget.doctor['doctor_profile']}"), // Insert doctor profile
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            'Dr ${widget.doctor['doctor_name']}',
                            style: const TextStyle(color: Colors.white),
                          ),
                          const SizedBox(
                            height: 2,
                          ),
                        ],
                      ),
                    ],
                  ),
                  Config.spaceSmall,
                  ScheduleCard(appointment: appointment),
                  Config.spaceSmall,
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                          ),
                          child: const Text(
                            'Cancel',
                            style: TextStyle(color: Colors.white),
                          ),
                          onPressed: () async {
                            final SharedPreferences prefs =
                                await SharedPreferences.getInstance();
                            final token = prefs.getString('token') ?? '';

                            // Log token
                            print('Token: $token');

                            // Call the cancelAppointment function
                            final response = await DioProvider()
                                .cancelAppointment(
                                    widget.doctor['appointments']['id'], token);

                            // Log response
                            print('Cancel response: $response');

                            // Check the response
                            if (response == 200) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                    content: Text(
                                        'Appointment canceled successfully')),
                              );
                              MyApp.navigatorKey.currentState!
                                  .pushNamed('main');
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                    content: Text(
                                        'Failed to cancel the appointment: $response')),
                              );
                            }
                          },
                        ),
                      ),
                      const SizedBox(
                        width: 20,
                      ),
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                          ),
                          onPressed: () {
                            showDialog(
                                context: context,
                                builder: (context) {
                                  return RatingDialog(
                                      initialRating: 1.0,
                                      title: const Text(
                                        'Rate the Doctor',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontSize: 25,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      message: const Text(
                                        'Please help us to rate our Doctor',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontSize: 15,
                                        ),
                                      ),
                                      image: const FlutterLogo(
                                        size: 100,
                                      ),
                                      submitButtonText: 'Submit',
                                      commentHint: 'Your Reviews',
                                      onSubmitted: (response) async {
                                        final SharedPreferences prefs =
                                            await SharedPreferences
                                                .getInstance();
                                        final token =
                                            prefs.getString('token') ?? '';

                                        final rating = await DioProvider()
                                            .storeReviews(
                                                response.comment,
                                                response.rating,
                                                widget.doctor['appointments'][
                                                    'id'], //this is appointment id
                                                widget.doctor[
                                                    'doc_id'], //this is doctor id
                                                token);

                                        //if successful, then refresh
                                        if (rating == 200 && rating != '') {
                                          MyApp.navigatorKey.currentState!
                                              .pushNamed('main');
                                        }
                                      });
                                });
                          },
                          child: const Text(
                            'Completed',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              );
            }
          },
        ),
      ),
    );
  }
}

class ScheduleCard extends StatelessWidget {
  const ScheduleCard({Key? key, required this.appointment}) : super(key: key);
  final Map<String, dynamic> appointment;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey,
        borderRadius: BorderRadius.circular(10),
      ),
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          const Icon(
            Icons.calendar_today,
            color: Colors.white,
            size: 15,
          ),
          const SizedBox(
            width: 5,
          ),
          Text(
            '${appointment['day']}, ${appointment['date']}',
            style: const TextStyle(
              color: Colors.white,
            ),
          ),
          const SizedBox(
            width: 20,
          ),
          const Icon(
            Icons.access_alarm,
            color: Colors.white,
            size: 17,
          ),
          const SizedBox(
            width: 5,
          ),
          Flexible(
            child: Text(
              appointment['time'],
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
