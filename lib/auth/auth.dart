import 'dart:convert';
import 'dart:async';
import 'package:undisaster/api/api_models.dart';
import 'package:undisaster/api/ndu_api_provider.dart';

abstract class BaseApi{
  NDUApiProvider provider = NDUApiProvider.instance;
}

class AuthApi extends BaseApi {
  Future<AuthUser> login(String email, String password) async {
    var path = 'api/auth/login';
    var body = json.encode({'username': email, 'password': password});

    final response = await provider.post(path, body);
    var data = jsonDecode(response.body);

    if (response.statusCode != 200) {
      print('API Login Error : $data');
      if (response.statusCode == 401) {
        throw Exception("Giriş bilgileri geçersiz");
      }
      throw Exception("API Login Error : status code : ${response.statusCode}");
    }
    return AuthUser.fromJson(data);
  }

  Future<void> registerFirebaseToken(String token) async {
    var path = 'api/user/deviceToken';
    var body = json.encode({'device_token': token});
    final response = await provider.post(path, body);

    if (response.statusCode != 200) {
      if (response.body != null && response.body != "") {
        var data = jsonDecode(response.body);
        print('API Error in registerFirebaseToken : $data');
      }
      print('API Error in registerFirebaseToken');
      return Future.error(null);
    }
    return;
  }
}
