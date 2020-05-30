import 'dart:convert';
import 'dart:core';

class RegisteredUser {
  String identity;
  int status;
  int lastUpdateTime;

  RegisteredUser({this.identity, this.status, this.lastUpdateTime});

  RegisteredUser.fromJson(Map json)
      : identity = json["identity"],
        lastUpdateTime = 0,
        status = 0;
}

class DeviceCredentials {
  String deviceId;
  String deviceCredential;

  DeviceCredentials({this.deviceId, this.deviceCredential});

  DeviceCredentials.fromJson(Map json)
      : deviceId = json["deviceId"]["id"],
        deviceCredential = json["credentialsId"];
}

class DeviceDetails {
  int status;
  int lastSeen;

  DeviceDetails({this.status, this.lastSeen});

  DeviceDetails.fromJson(Map json)
      : status = json["status"] == null ? 0 : int.parse(json["status"]),
        lastSeen = json["lastSeen"] == null ? 0 : int.parse(json["lastSeen"]);
}

class AuthUser {
  String token;
  String refreshToken;
  String sub;
  List<String> scopes;
  String userId;
  String firstName;
  String lastName;
  bool enabled;
  bool isPublic;
  String tenantId;
  String customerId;
  String iss;
  int iat;
  int exp;

  AuthUser({this.token, this.refreshToken});

  factory AuthUser.fromJson(Map json) {
    AuthUser user = AuthUser();
    user.token = json['token'];
    user.refreshToken = json['refreshToken'];

    Map<String, dynamic> data = parseJwt(user.token);

    user.sub = data["sub"];
    user.userId = data["userId"];
    user.firstName = data["firstName"];
    user.lastName = data["lastName"];
    user.enabled = data["enabled"];
    user.isPublic = data["isPublic"];
    user.tenantId = data["tenantId"];
    user.customerId = data["customerId"];
    user.iss = data["iss"];
    user.iat = data["iat"];
    user.exp = data["exp"];
//    user.scopes = data["scopes"];

    return user;
  }

  static Map<String, dynamic> parseJwt(String token) {
    final parts = token.split('.');
    if (parts.length != 3) {
      throw Exception('invalid token');
    }

    final payload = _decodeBase64(parts[1]);
    final payloadMap = json.decode(payload);
    if (payloadMap is! Map<String, dynamic>) {
      throw Exception('invalid payload');
    }

    return payloadMap;
  }

  static String _decodeBase64(String str) {
    String output = str.replaceAll('-', '+').replaceAll('_', '/');
    switch (output.length % 4) {
      case 0:
        break;
      case 2:
        output += '==';
        break;
      case 3:
        output += '=';
        break;
      default:
        throw Exception('Illegal base64url string!"');
    }
    return utf8.decode(base64Url.decode(output));
  }
}

class ResponseData {
  int status;
  ErrorDetail error;
  dynamic data;
}

class ErrorDetail {
  String message;
  int errorCode;
  int timestamp;
}
