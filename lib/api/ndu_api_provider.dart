import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'dart:io';

class NDUApiProvider {
  static const _BASE_URL = "https://smartapp.netcad.com";
  static String _TOKEN = "";

  NDUApiProvider._privateConstructor();

  static final NDUApiProvider _instance = NDUApiProvider._privateConstructor();

  static NDUApiProvider get instance => _instance;

  static init(String apiKey) {
    _TOKEN = apiKey;
    _headers["X-Authorization"] = 'Barear $_TOKEN';
  }

  static Map<String, String> _headers = {"Content-Type": "application/json"};

  Future<http.Response> get(String path) async {
    try {
      final responseBody =
      await http.get('$_BASE_URL/$path', headers: _headers);
      return responseBody;
    } on SocketException {
      throw Exception('No Internet connection');
    }
  }

  Future<http.Response> post(String path, Object body) async {
    try {
      String bodyStr = body;
      if (body.runtimeType != String) bodyStr = json.encode(body);

      String url = "$_BASE_URL/$path";

      print("Sending post request to $url");
      print(bodyStr);

      final responseBody =
      await http.post(url, body: bodyStr, headers: _headers);

      return responseBody;
    } on SocketException {
      throw Exception('No Internet connection');
    }
  }
}
