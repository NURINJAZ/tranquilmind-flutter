import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tranquil_mindv1/components/button.dart';
//import 'package:tranquil_mindv1/main.dart';
import 'package:tranquil_mindv1/models/auth_model.dart';
import 'package:tranquil_mindv1/providers/dio_provider.dart';
import 'package:tranquil_mindv1/utils/config.dart';
import '../components/custom_appbar.dart';
import '../screens/maps_page.dart';

class DoctorDetails extends StatefulWidget {
  const DoctorDetails({Key? key, required this.doctor, required this.isFav})
      : super(key: key);
  final Map<String, dynamic> doctor;
  final bool isFav;

  @override
  State<DoctorDetails> createState() => _DoctorDetailsState();
}

class _DoctorDetailsState extends State<DoctorDetails> {
  late Map<String, dynamic> doctor;
  late bool isFav;
  dynamic _ratingData;

  @override
  void initState() {
    doctor = widget.doctor;
    isFav = widget.isFav;
    super.initState();
    _fetchDoctorRating();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        appTitle: 'Doctor Details',
        icon: const FaIcon(Icons.arrow_back_ios),
        actions: [
          // Favorite Button
          IconButton(
            onPressed: () async {
              if (!mounted) return;

              final authModel = Provider.of<AuthModel>(context, listen: false);
              final list = authModel.getFav;

              if (list.contains(doctor['doc_id'])) {
                list.removeWhere((id) => id == doctor['doc_id']);
              } else {
                list.add(doctor['doc_id']);
              }

              authModel.setFavList(list);

              final SharedPreferences prefs =
                  await SharedPreferences.getInstance();
              final token = prefs.getString('token') ?? '';

              if (token.isNotEmpty) {
                final response = await DioProvider().storeFavDoc(token, list);
                if (response == 200) {
                  if (!mounted) return;
                  setState(() {
                    isFav = !isFav;
                  });
                }
              }
            },
            icon: FaIcon(
              isFav ? Icons.favorite_rounded : Icons.favorite_outline,
              color: Colors.red,
            ),
          )
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: <Widget>[
                    AboutDoctor(
                      doctor: doctor,
                    ),
                    DetailBody(
                      doctor: doctor,
                      ratingData: _ratingData,
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Button(
                    width: double.infinity,
                    title: 'Get Location',
                    onPressed: () async {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => MapsPage(doctor: doctor)),
                      );
                    },
                    disable: false,
                  ),
                  const SizedBox(height: 20),
                  Button(
                    width: double.infinity,
                    title: 'Book Appointment',
                    onPressed: () {
                      Navigator.of(context).pushNamed('booking_page',
                          arguments: {"doctor_id": doctor['doc_id']});
                    },
                    disable: false,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _fetchDoctorRating() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';
    if (token == '') {
      throw Exception('Token is empty');
    }
    try {
      final response =
          await DioProvider().getDoctorRating(widget.doctor['doc_id'], token);
      print(
          'Rating data fetched: $response'); // Print response data for debugging
      setState(() {
        _ratingData = response;
        print('Rating data set: $_ratingData'); // Print rating data in state
      });
    } catch (error) {
      print('Error fetching doctor rating: $error');
    }
  }

  void saveTokenAndDoctorId(String token, String doctorId) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', token);
    await prefs.setString('doctor_id', doctorId);
    print('Token and doctor ID saved: $token, $doctorId');
  }
}

class AboutDoctor extends StatelessWidget {
  const AboutDoctor({Key? key, required this.doctor}) : super(key: key);

  final Map<String, dynamic> doctor;

  @override
  Widget build(BuildContext context) {
    Config().init(context);
    return Container(
      width: double.infinity,
      child: Column(
        children: <Widget>[
          CircleAvatar(
            radius: 65.0,
            backgroundImage: NetworkImage(
              "http://tranquilmind.icu${doctor['doctor_profile']}",
            ),
            backgroundColor: Colors.white,
          ),
          Config.spaceMedium,
          Text(
            "Dr ${doctor['doctor_name']}",
            style: const TextStyle(
              color: Colors.black,
              fontSize: 24.0,
              fontWeight: FontWeight.bold,
            ),
          ),
          Config.spaceSmall,
          SizedBox(
            width: Config.widthSize * 0.75,
            child: const Text(
              'MBBS (International Medical University, Malaysia), MRCP (Royal College of Physicians, United Kingdom)',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 15,
              ),
              softWrap: true,
              textAlign: TextAlign.center,
            ),
          ),
          Config.spaceSmall,
          SizedBox(
            width: Config.widthSize * 0.75,
            child: const Text(
              'Sarawak General Hospital',
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
              softWrap: true,
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}

class DetailBody extends StatelessWidget {
  const DetailBody({Key? key, required this.doctor, required this.ratingData})
      : super(key: key);
  final Map<String, dynamic> doctor;
  final dynamic ratingData;

  @override
  Widget build(BuildContext context) {
    Config().init(context);
    return Container(
      padding: const EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Config.spaceSmall,
          DoctorInfo(
            patients: doctor['patients'],
            exp: doctor['experience'],
            ratingData: ratingData,
          ),
          Config.spaceMedium,
          const Text(
            'About Doctor',
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18),
          ),
          Config.spaceSmall,
          Text(
            'Dr. ${doctor['doctor_name']} is an experienced ${doctor['category']} at Sarawak, graduated since 2008, and completed his/her training at Sungai Buloh General Hospital.',
            style: const TextStyle(
              fontWeight: FontWeight.w500,
              height: 1.5,
            ),
            softWrap: true,
            textAlign: TextAlign.justify,
          )
        ],
      ),
    );
  }
}

class DoctorInfo extends StatelessWidget {
  const DoctorInfo(
      {Key? key,
      required this.patients,
      required this.exp,
      required this.ratingData})
      : super(key: key);

  final int patients;
  final int exp;
  final dynamic ratingData;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        InfoCard(
          label: 'Patients',
          value: '$patients',
        ),
        const SizedBox(
          width: 15,
        ),
        InfoCard(
          label: 'Experiences',
          value: '$exp years',
        ),
        const SizedBox(
          width: 15,
        ),
        InfoCard(
          label: 'Rating',
          value: (ratingData != null
              ? tryParseDouble(ratingData['average_rating'].toString())
                      ?.toStringAsFixed(1) ??
                  '0.0'
              : '0.0'),
        ),
      ],
    );
  }

  double? tryParseDouble(String value) {
    try {
      return double.parse(value);
    } catch (e) {
      return null;
    }
  }
}

class InfoCard extends StatelessWidget {
  const InfoCard({Key? key, required this.label, required this.value})
      : super(key: key);

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          color: Config.primaryColor,
        ),
        padding: const EdgeInsets.symmetric(
          vertical: 15,
          horizontal: 15,
        ),
        child: Column(
          children: <Widget>[
            Text(
              label,
              style: const TextStyle(
                color: Colors.black,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
