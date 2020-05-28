import 'dart:async';
import 'package:depremhackathon/api/api_models.dart';
import 'package:depremhackathon/api/device_api.dart';
import 'package:depremhackathon/auth/auth.dart';

import 'package:shared_preferences/shared_preferences.dart';

class AuthenticationService {
  AuthUser _currentUser;

  static const String _TOKEN = "token";
  static const String _REFRESH_TOKEN = "refreshToken";
  static const String _USER_SUB = "sub";
  static const String _USER_ID = "userId";
  static const String _USER_FIRST_NAME = "firstName";
  static const String _USER_LAST_NAME = "lastName";
  static const String _USER_TENANT_ID = "tenantId";
  static const String _USER_CUSTOMER_ID = "customerId";
  static const String _USER_TYPE = "user_type";
  static const String _TOKEN_IAT = "token_iat";
  static const String _TOKEN_EXP = "token_exp";

  Future<String> currentToken() async {
    AuthUser currentUser = await this.currentUser();
    if (currentUser == null)
      return null;
    else
      return currentUser.token;
  }

  Future<AuthUser> currentUser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String token = prefs.getString(_TOKEN);
    if (_currentUser == null && token != null) {
      _currentUser = AuthUser();
      _currentUser.token = token;
      _currentUser.refreshToken = prefs.getString(_REFRESH_TOKEN);
      _currentUser.sub = prefs.getString(_USER_SUB);
      _currentUser.userId = prefs.getString(_USER_ID);
      _currentUser.firstName = prefs.getString(_USER_FIRST_NAME);
      _currentUser.lastName = prefs.getString(_USER_LAST_NAME);
      _currentUser.tenantId = prefs.getString(_USER_TENANT_ID);
      _currentUser.customerId = prefs.getString(_USER_CUSTOMER_ID);
      _currentUser.scopes = List<String>();
      _currentUser.scopes.add(prefs.getString(_USER_TYPE));
      _currentUser.iat = prefs.getInt(_TOKEN_IAT);
      _currentUser.exp = prefs.getInt(_TOKEN_EXP);
    }

    return Future<AuthUser>.value(_currentUser);
  }

  Future<AuthUser> signInWithEmailAndPassword(
      String email, String password) async {
    email = email.trim();
    password = password.trim();

    AuthApi authApi = AuthApi();
    AuthUser loginUser = await authApi.login(email, password);

    if (loginUser != null) {
      _currentUser = loginUser;
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setString(_TOKEN, loginUser.token);
      prefs.setString(_REFRESH_TOKEN, loginUser.refreshToken);
      prefs.setString(_USER_SUB, loginUser.sub);
      prefs.setString(_USER_ID, loginUser.userId);
      prefs.setString(_USER_FIRST_NAME, loginUser.firstName);
      prefs.setString(_USER_LAST_NAME, loginUser.lastName);
      prefs.setString(_USER_TENANT_ID, loginUser.tenantId);
      prefs.setString(_USER_CUSTOMER_ID, loginUser.customerId);
      prefs.setInt(_TOKEN_IAT, loginUser.iat);
      prefs.setInt(_TOKEN_EXP, loginUser.exp);
      return Future.value(_currentUser);
    }

    return Future.value(loginUser);
  }

  Future<AuthUser> registerUserAsDevice(String identity,  String deviceId) async{

    DeviceApi deviceApi = DeviceApi();
    AuthUser loginUser = await deviceApi.registerPhone(identity, deviceId);

    return Future.value(null);
  }

  Future<void> signOut() async {
    _currentUser = null;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.remove(_TOKEN);
    prefs.remove(_REFRESH_TOKEN);
    prefs.remove(_USER_SUB);
    prefs.remove(_USER_ID);
    prefs.remove(_USER_TYPE);
    prefs.remove(_USER_FIRST_NAME);
    prefs.remove(_USER_LAST_NAME);
    prefs.remove(_USER_TENANT_ID);
    prefs.remove(_USER_CUSTOMER_ID);
    prefs.remove(_USER_TYPE);
    prefs.remove(_TOKEN_IAT);
    prefs.remove(_TOKEN_EXP);
    return;
  }
}
