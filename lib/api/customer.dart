import 'dart:convert';

import '../config.dart';
import 'package:http/http.dart' as http;

class CustomerAPI {
  Future<Map<String, dynamic>> registerCustomer(
    String firstname,
    String middlename,
    String lastname,
    String contactnumber,
    String gender,
    String address,
    String username,
    String password,
  ) async {
    final url = Uri.parse('${Config.apiUrl}${Config.registrationAPI}');
    final response = await http.post(url, body: {
      'firstname': firstname,
      'middlename': middlename,
      'lastname': lastname,
      'contactnumber': contactnumber,
      'gender': gender,
      'address': address,
      'username': username,
      'password': password,
    });

    final responseData = json.decode(response.body);
    final status = response.statusCode;
    final msg = responseData['msg'];
    final results = responseData['data'];

    Map<String, dynamic> data = {};
    data = {'msg': msg, 'status': status, 'data': results};

    return data;
  }

  Future<Map<String, dynamic>> getCustomerInfo() async {
    final url = Uri.parse('${Config.apiUrl}${Config.registrationAPI}');
    final response = await http.post(url);

    final responseData = json.decode(response.body);
    final status = response.statusCode;
    final msg = responseData['msg'];
    final results = responseData['data'];

    Map<String, dynamic> data = {};
    data = {'msg': msg, 'status': status, 'data': results};

    return data;
  }
}
