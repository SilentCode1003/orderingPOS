import 'dart:convert';

import 'package:smallproject/components/product_listing_screen.dart';

import '../config.dart';
import 'package:http/http.dart' as http;

class CustomerOrderAPI {
  Future<Map<String, dynamic>> order(
    String customerid,
    String details,
    String total,
    String paymenttype,
  ) async {
    final url = Uri.parse('${Config.apiUrl}${Config.customerOrderAPI}');
    final response = await http.post(url, body: {
      'customerid': customerid,
      'details': details,
      'total': total,
      'paymenttype': paymenttype,
    });

    final responseData = json.decode(response.body);
    final status = response.statusCode;
    final msg = responseData['msg'];
    final results = responseData['data'];

    Map<String, dynamic> data = {};
    data = {'msg': msg, 'status': status, 'data': results};

    return data;
  }

  Future<Map<String, dynamic>> orderhistory(
    String customerid,
  ) async {
    final url = Uri.parse('${Config.apiUrl}${Config.orderhistoryAPI}');
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

  Future<Map<String, dynamic>> getactiveorder(
    String customerid,
  ) async {
    final url = Uri.parse('${Config.apiUrl}${Config.activeOrederAPI}');
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
