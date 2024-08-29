import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tranquil_mindv1/components/login_form.dart';
import 'package:tranquil_mindv1/models/auth_model.dart';
import 'package:tranquil_mindv1/screens/booking_page.dart';
import 'package:tranquil_mindv1/screens/dass_page.dart';
import 'package:tranquil_mindv1/screens/reschedule_booking_page.dart';
import 'package:tranquil_mindv1/screens/profile_page.dart';
//import 'package:tranquil_mindv1/screens/maps_page.dart';
import 'package:tranquil_mindv1/screens/success_booked.dart';
import 'package:tranquil_mindv1/screens/viewdass_page.dart';
import 'package:tranquil_mindv1/utils/config.dart';
import 'package:tranquil_mindv1/screens/auth_page.dart';
import 'package:tranquil_mindv1/main_layout.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  //this is for push navigator
  static final navigatorKey = GlobalKey<NavigatorState>();

  @override
  Widget build(BuildContext context) {
    //define ThemeData here
    return ChangeNotifierProvider<AuthModel>(
      create: (context) => AuthModel(),
      child: MaterialApp(
        navigatorKey: navigatorKey,
        title: 'Tranquil Mind',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          //pre-define input decoration
          inputDecorationTheme: const InputDecorationTheme(
            focusColor: Config.primaryColor,
            border: Config.outlinedBorder,
            focusedBorder: Config.focusBorder,
            errorBorder: Config.errorBorder,
            enabledBorder: Config.outlinedBorder,
            floatingLabelStyle: TextStyle(color: Config.primaryColor),
            prefixIconColor: Colors.black38,
          ),
          scaffoldBackgroundColor: Colors.white,
          bottomNavigationBarTheme: BottomNavigationBarThemeData(
            backgroundColor: Config.primaryColor,
            selectedItemColor: Colors.white,
            showSelectedLabels: true,
            showUnselectedLabels: false,
            unselectedItemColor: Colors.grey.shade700,
            elevation: 10,
            type: BottomNavigationBarType.fixed,
          ),
        ),
        initialRoute: '/',
        routes: {
          '/': (context) => const AuthPage(),
          'login': (context) => const LoginForm(),
          'main': (context) => const MainLayout(),
          'dass': (context) => DassFormScreen(),
          'viewdass': (context) => ViewDassPage(),
          'profile': (context) => ProfilePage(),
          'booking_page': (context) => BookingPage(),
          'reschedule_booking_page': (context) =>
              RescheduleBookingPage(key: UniqueKey()),
          'success_booking': (context) => const AppointmentBooked(),
        },
      ),
    );
  }
}
