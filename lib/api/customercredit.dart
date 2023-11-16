import 'dart:convert';

import 'package:uhordering/components/product_listing_screen.dart';

import '../config.dart';
import 'package:http/http.dart' as http;

class CustomerCreditAPI {
  Future<Map<String, dynamic>> getcredit(
    String customerid,
  ) async {
    final url = Uri.parse('${Config.apiUrl}${Config.customerCreditAPI}');
    final response = await http.post(url, body: {
      'customerid': customerid,
    });

    final responseData = json.decode(response.body);
    final status = response.statusCode;
    final msg = responseData['msg'];
    final results = responseData['data'];

    Map<String, dynamic> data = {};
    data = {'msg': msg, 'status': status, 'data': results};

    return data;
  }

   Future<Map<String, dynamic>> getbalancehistory(
    String customerid,
  ) async {
    final url = Uri.parse('${Config.apiUrl}${Config.getBalanceHistoryAPI}');
    final response = await http.post(url, body: {
      'customerid': customerid,
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
