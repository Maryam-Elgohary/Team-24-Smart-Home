import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:updated_smart_home/core/helps%20functions/getUserData.dart';

class ApiServices {
  final Dio _dio;
  ApiServices(this._dio);

  final String baseUrl = "https://fakestoreapi.com/";

  Future<dynamic> get({
    required String endPoint,
    @required String? token,
  }) async {
    Map<String, String> headers = {};

    if (token != null) {
      headers.addAll({'Authorization': 'Bearer ${getUser().ha_token}'});
    }

    var response = await _dio.get(
      '${getUser().ha_url}$endPoint',
      options: Options(headers: headers),
    );

    return response.data;
  }
}
