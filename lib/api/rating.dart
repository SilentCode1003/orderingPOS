import 'dart:convert';

import '../config.dart';
import 'package:http/http.dart' as http;

class RateAPI {
  Future<Map<String, dynamic>> getRate() async {
    final url = Uri.parse('${Config.apiUrl}${Config.getActiveRatingAPI}');
    final response = await http.get(url);

    final responseData = json.decode(response.body);
    final status = response.statusCode;
    final msg = responseData['msg'];
    final results = responseData['data'];

    Map<String, dynamic> data = {};
    data = {'msg': msg, 'status': status, 'data': results};

    return data;
  }

  Future<Map<String, dynamic>> feedback(
      String orderid, String rating, String message) async {
    final url = Uri.parse('${Config.apiUrl}${Config.customerFeedbackAPI}');
    final response = await http.post(url,
        body: {'orderid': orderid, 'rating': rating, 'message': message});

    final responseData = json.decode(response.body);
    final status = response.statusCode;
    final msg = responseData['msg'];
    final results = responseData['data'];

    Map<String, dynamic> data = {};
    data = {'msg': msg, 'status': status, 'data': results};

    return data;
  }
}
