import 'dart:convert';

import 'package:uhordering/components/product_listing_screen.dart';

import '../config.dart';
import 'package:http/http.dart' as http;

class CustomerFeedbackAPI {
  Future<Map<String, dynamic>> getcredit(
    String orderid,
  ) async {
    final url = Uri.parse('${Config.apiUrl}${Config.customerFeedbackAPI}');
    final response = await http.post(url, body: {
      'orderid': orderid,
    });

    final responseData = json.decode(response.body);
    final status = response.statusCode;
    final msg = responseData['msg'];
    final results = responseData['data'];

    Map<String, dynamic> data = {};
    data = {'msg': msg, 'status': status, 'data': results};

    return data;
  }
}
