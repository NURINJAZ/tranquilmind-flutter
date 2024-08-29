import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tranquil_mindv1/main.dart';
import 'package:tranquil_mindv1/providers/dio_provider.dart';
import 'package:tranquil_mindv1/screens/doctor_details.dart';
import 'package:tranquil_mindv1/utils/config.dart';

class DoctorCard extends StatefulWidget {
  const DoctorCard({
    Key? key,
    required this.doctor,
    required this.isFav,
  }) : super(key: key);

  final Map<String, dynamic> doctor;
  final bool isFav;
  @override
  _DoctorCardState createState() => _DoctorCardState();
}

class _DoctorCardState extends State<DoctorCard> {
  dynamic _ratingData;

  @override
  void initState() {
    super.initState();
    _fetchDoctorRating();
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

  @override
  Widget build(BuildContext context) {
    Config().init(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      height: 150,
      child: GestureDetector(
        child: Card(
          elevation: 5,
          color: Colors.white,
          child: Row(
            children: [
              SizedBox(
                width: Config.widthSize * 0.33,
                child: CachedNetworkImage(
                  imageUrl:
                      "http://tranquilmind.icu${widget.doctor['doctor_profile']}",
                  fit: BoxFit.fill,
                  placeholder: (context, url) =>
                      const CircularProgressIndicator(),
                  errorWidget: (context, url, error) => const Icon(Icons.error),
                ),
              ),
              Flexible(
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        "Dr ${widget.doctor['doctor_name']}",
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      /*Text(
                        "${widget.doctor['category']}",
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.normal,
                        ),
                      ),*/
                      const Spacer(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          Icon(
                            Icons.star_border,
                            color: Colors.yellow,
                            size: 16,
                          ),
                          Spacer(
                            flex: 1,
                          ),
                          Text(_ratingData != null
                              ? tryParseDouble(_ratingData['average_rating']
                                          .toString())
                                      ?.toStringAsFixed(1) ??
                                  '0.0'
                              : '0.0'),
                          Spacer(
                            flex: 1,
                          ),
                          Text('Reviews'),
                          Spacer(
                            flex: 1,
                          ),
                          Text(_ratingData != null
                              ? '(${_ratingData['total_reviews']})'
                              : '(0)'),
                          Spacer(
                            flex: 7,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        onTap: () {
          //pass the details to detail page
          MyApp.navigatorKey.currentState!.push(MaterialPageRoute(
              builder: (_) => DoctorDetails(
                    doctor: widget.doctor,
                    isFav: widget.isFav,
                  )));
        },
      ),
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
