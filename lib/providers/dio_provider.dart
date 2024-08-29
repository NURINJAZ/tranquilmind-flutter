import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DioProvider {
  //get token
  Future<String?> getToken(String email, String password) async {
    try {
      var response = await Dio().post('http://tranquilmind.icu/api/login',
          data: {'email': email, 'password': password});

      if (response.statusCode == 200 && response.data != '') {
        final SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', response.data);
        return null; // Indicating success with no error message
      } else {
        return 'Invalid email or password'; // Error message for invalid credentials
      }
    } catch (error) {
      return 'An error occurred. Please try again.'; // General error message
    }
  }

  //get user data
  Future<dynamic> getUser(String token) async {
    try {
      var user = await Dio().get('http://tranquilmind.icu/api/user',
          options: Options(headers: {'Authorization': 'Bearer $token'}));
      if (user.statusCode == 200 && user.data != '') {
        return json.encode(user.data);
      }
    } catch (error) {
      return error;
    }
  }

  //register new user
  Future<String?> registerUser(
      String username, String email, String password) async {
    try {
      var user = await Dio().post('http://tranquilmind.icu/api/register',
          data: {'name': username, 'email': email, 'password': password});
      if (user.statusCode == 201 && user.data != '') {
        return null; // Indicating success with no error message
      } else {
        return 'Registration failed. Please try again.'; // General error message
      }
    } catch (error) {
      if (error is DioError && error.response != null) {
        // Handle specific DioError responses if available
        if (error.response!.statusCode == 400) {
          return 'Invalid data. Please check your inputs.';
        } else if (error.response!.statusCode == 409) {
          return 'Email already exists.';
        }
      }
      return 'An error occurred. Please try again.'; // General error message
    }
  }

  Future<String?> updateUser(Map<String, dynamic> data, String token) async {
    try {
      final formData = FormData.fromMap(data);
      final response = await Dio().post(
        'http://tranquilmind.icu/api/update',
        data: formData,
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      return response.data;
    } catch (e) {
      print(e);
      return null;
    }
  }

  //store booking details
  Future<dynamic> bookAppointment(
      String date, String day, String time, int doctor, String token) async {
    try {
      var response = await Dio().post('http://tranquilmind.icu/api/book',
          data: {'date': date, 'day': day, 'time': time, 'doctor_id': doctor},
          options: Options(headers: {'Authorization': 'Bearer $token'}));

      if (response.statusCode == 200 && response.data != '') {
        return response.statusCode;
      } else {
        return 'Error';
      }
    } catch (error) {
      return error;
    }
  }

  //retrieve booking details
  Future<dynamic> getAppointments(String token) async {
    try {
      var response = await Dio().get('http://tranquilmind.icu/api/appointments',
          options: Options(headers: {'Authorization': 'Bearer $token'}));

      if (response.statusCode == 200 && response.data != '') {
        return json.encode(response.data);
      } else {
        return 'Error';
      }
    } catch (error) {
      return error;
    }
  }

  // Reschedule appointment
  Future<dynamic> rescheduleAppointment(int appointmentId, String newDate,
      String newDay, String newTime, String token) async {
    try {
      print('Rescheduling appointment with ID: $appointmentId');
      print('New date: $newDate');
      print('New day: $newDay');
      print('New time: $newTime');
      print('Using token: $token');

      var response = await Dio().post(
        'http://tranquilmind.icu/api/reschedule',
        data: {
          'appointment_id': appointmentId,
          'new_date': newDate,
          'new_day': newDay,
          'new_time': newTime,
        },
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      print('halu');
      print('Response status: ${response.statusCode}');
      print('Response data: ${response.data}');

      if (response.statusCode == 200 && response.data != '') {
        return response.statusCode;
      } else {
        print('Error: ${response.statusCode} - ${response.data}');
        print('nino');
        return 'Error: ${response.statusCode} - ${response.data}';
      }
    } catch (error) {
      print('Error: $error');
      print('comel');
      return 'Error: $error';
    }
  }

  //cancel appointment details
  Future<dynamic> cancelAppointment(int appointmentId, String token) async {
    try {
      print('Cancelling appointment with ID: $appointmentId');
      print('Using token: $token');

      var response = await Dio().post(
        'http://tranquilmind.icu/api/cancel',
        data: {
          'appointment_id': appointmentId,
        },
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      print('Response status: ${response.statusCode}');
      print('Response data: ${response.data}');

      if (response.statusCode == 200 && response.data != '') {
        return response.statusCode;
      } else {
        return 'Error: ${response.statusCode} - ${response.data}';
      }
    } catch (error) {
      print('Error: $error');
      return error;
    }
  }

  Future<dynamic> getAdminLocation(int docId, String token) async {
    try {
      var response = await Dio().get(
          'http://tranquilmind.icu/api/admin-location/$docId',
          options: Options(headers: {'Authorization': 'Bearer $token'}));

      if (response.statusCode == 200 && response.data != '') {
        return response.data;
      } else {
        return 'Error';
      }
    } catch (error) {
      return error;
    }
  }

  Future<dynamic> storeDassResults(int depressionScore, int anxietyScore,
      int stressScore, int totalScore, String token) async {
    try {
      var response = await Dio().post('http://tranquilmind.icu/api/dass',
          data: {
            'depression_score': depressionScore,
            'anxiety_score': anxietyScore,
            'stress_score': stressScore,
            'category': totalScore,
          },
          options: Options(headers: {'Authorization': 'Bearer $token'}));

      print('Response status code: ${response.statusCode}');
      print('Response data: ${response.data}');

      if (response.statusCode == 200 && response.data != '') {
        return response.statusCode;
      } else {
        return 'Error';
      }
    } catch (error) {
      return error;
    }
  }

  //get user data of dass test
  Future<List<dynamic>> getDASS(String token) async {
    try {
      var response = await Dio().get(
        'http://tranquilmind.icu/api/viewdass',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (response.statusCode == 200 && response.data != '') {
        return response.data
            as List<dynamic>; // Cast response data to List<dynamic>
      } else {
        throw Exception('Failed to load DASS results');
      }
    } catch (error) {
      throw Exception('Error: $error');
    }
  }

  //store rating details
  Future<dynamic> storeReviews(
      String reviews, double ratings, int id, int doctor, String token) async {
    try {
      var response = await Dio().post('http://tranquilmind.icu/api/reviews',
          data: {
            'ratings': ratings,
            'reviews': reviews,
            'appointment_id': id,
            'doctor_id': doctor
          },
          options: Options(headers: {'Authorization': 'Bearer $token'}));

      if (response.statusCode == 200 && response.data != '') {
        return response.statusCode;
      } else {
        return 'Error';
      }
    } catch (error) {
      return error;
    }
  }

  Future<dynamic> getDoctorRating(int docId, String token) async {
    try {
      var response = await Dio().get(
          'http://tranquilmind.icu/api/rating/$docId',
          options: Options(headers: {'Authorization': 'Bearer $token'}));

      if (response.statusCode == 200 && response.data != '') {
        return response.data;
      } else {
        return 'Error';
      }
    } catch (error) {
      return error;
    }
  }

  //store fav doctor
  Future<dynamic> storeFavDoc(String token, List<dynamic> favList) async {
    try {
      var response = await Dio().post('http://tranquilmind.icu/api/fav',
          data: {
            'favList': favList,
          },
          options: Options(headers: {'Authorization': 'Bearer $token'}));

      if (response.statusCode == 200 && response.data != '') {
        return response.statusCode;
      } else {
        return 'Error';
      }
    } catch (error) {
      return error;
    }
  }

//logout
  Future<dynamic> logout(String token) async {
    try {
      var response = await Dio().post('http://tranquilmind.icu/api/logout',
          options: Options(headers: {'Authorization': 'Bearer $token'}));

      if (response.statusCode == 200 && response.data != '') {
        return response.statusCode;
      } else {
        return 'Error';
      }
    } catch (error) {
      return error;
    }
  }
}
