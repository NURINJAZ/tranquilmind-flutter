import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:tranquil_mindv1/components/button.dart';
import 'package:tranquil_mindv1/main.dart';
import 'package:tranquil_mindv1/models/booking_datetime_converted.dart';
import 'package:tranquil_mindv1/providers/dio_provider.dart';
import 'package:tranquil_mindv1/utils/config.dart';
import '../components/custom_appbar.dart';
import 'package:intl/intl.dart';

class RescheduleBookingPage extends StatefulWidget {
  final Key key;

  RescheduleBookingPage({required this.key}) : super(key: key);

  @override
  State<RescheduleBookingPage> createState() => _RescheduleBookingPageState();
}

class _RescheduleBookingPageState extends State<RescheduleBookingPage> {
  Map<String, dynamic>? doctor;
  Map<String, dynamic>? currentAppointment;

  CalendarFormat _format = CalendarFormat.month;
  DateTime _focusDay = DateTime.now();
  DateTime _currentDay = DateTime.now();
  int? _currentIndex;
  bool _isWeekend = false;
  bool _dateSelected = false;
  bool _timeSelected = false;
  String?
      token; // get token for inserting rescheduled booking date and time into db

  Future<void> getToken() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    token = prefs.getString('token') ?? '';
  }

  @override
  void initState() {
    super.initState();
    getToken();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    doctor = args['doctor'];
    currentAppointment = args['currentAppointment'];

    try {
      // Use 'MM/dd/yyyy' if the time is not included in the date string
      final dateFormat = DateFormat('MM/dd/yyyy');
      _focusDay = dateFormat.parse(currentAppointment!['date']);
      _currentDay = dateFormat.parse(currentAppointment!['date']);
    } catch (e) {
      print('Error parsing date: $e');
      _focusDay = DateTime.now();
      _currentDay = DateTime.now();
    }

    try {
      _currentIndex = int.parse(currentAppointment!['time'].split(':')[0]) - 9;
    } catch (e) {
      print('Error parsing time: $e');
      _currentIndex = 0;
    }

    _dateSelected = true;
    _timeSelected = true;
  }

  @override
  Widget build(BuildContext context) {
    Config().init(context);
    return Scaffold(
      appBar: const CustomAppBar(
        appTitle: 'Reschedule Appointment',
        icon: FaIcon(Icons.arrow_back_ios),
      ),
      body: CustomScrollView(
        slivers: <Widget>[
          SliverToBoxAdapter(
            child: Column(
              children: <Widget>[
                _tableCalendar(),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 25),
                  child: Center(
                    child: Text(
                      'Select New Appointment Time',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          _isWeekend
              ? SliverToBoxAdapter(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 30,
                    ),
                    alignment: Alignment.center,
                    child: const Text(
                      'Weekend is not available, please select another date',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                )
              : SliverGrid(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      return InkWell(
                        splashColor: Colors.transparent,
                        onTap: () {
                          setState(() {
                            _currentIndex = index;
                            _timeSelected = true;
                          });
                        },
                        child: Container(
                          margin: const EdgeInsets.all(5),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: _currentIndex == index
                                  ? Colors.white
                                  : Colors.black,
                            ),
                            borderRadius: BorderRadius.circular(15),
                            color: _currentIndex == index
                                ? Config.primaryColor
                                : null,
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            '${index + 9}:00 ${index + 9 > 11 ? "PM" : "AM"}',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color:
                                  _currentIndex == index ? Colors.white : null,
                            ),
                          ),
                        ),
                      );
                    },
                    childCount: 8,
                  ),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4,
                    childAspectRatio: 1.5,
                  ),
                ),
          SliverToBoxAdapter(
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 10,
                vertical: 80,
              ),
              child: Button(
                width: double.infinity,
                title: 'Confirm Reschedule',
                onPressed: () async {
                  if (_timeSelected && _dateSelected) {
                    final getDate = DateConverted.getDate(_currentDay);
                    final getDay = DateConverted.getDay(_currentDay.weekday);
                    final getTime = DateConverted.getTime(_currentIndex!);

                    final reschedule = await DioProvider()
                        .rescheduleAppointment(currentAppointment!['id'],
                            getDate, getDay, getTime, token!);

                    //if booking return status code 200, then redirect to success booking page

                    if (reschedule == 200) {
                      MyApp.navigatorKey.currentState!
                          .pushNamed('success_booking');
                    }
                  } else {
                    // Show a message or handle the case where time or date is not selected
                  }
                },
                disable: _timeSelected && _dateSelected ? false : true,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _tableCalendar() {
    return TableCalendar(
      focusedDay: _focusDay,
      firstDay: DateTime.now(),
      lastDay: DateTime(2050, 12, 31),
      calendarFormat: _format,
      currentDay: _currentDay,
      rowHeight: 48,
      calendarStyle: const CalendarStyle(
        todayDecoration: BoxDecoration(
          color: Config.primaryColor,
          shape: BoxShape.circle,
        ),
      ),
      availableCalendarFormats: const {
        CalendarFormat.month: 'Month',
      },
      onFormatChanged: (format) {
        setState(() {
          _format = format;
        });
      },
      onDaySelected: ((selectedDay, focusedDay) {
        setState(() {
          _currentDay = selectedDay;
          _focusDay = focusedDay;
          _dateSelected = true;

          if (selectedDay.weekday == 6 || selectedDay.weekday == 7) {
            _isWeekend = true;
            _timeSelected = false;
            _currentIndex = null;
          } else {
            _isWeekend = false;
          }
        });
      }),
    );
  }
}
