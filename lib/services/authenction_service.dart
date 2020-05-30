import 'dart:async';
import 'package:depremhackathon/api/api_models.dart';

import 'package:shared_preferences/shared_preferences.dart';

class AuthenticationService {
  RegisteredUser _registeredUser;
  DeviceCredentials _registeredDeviceCredentials;

  static const String _IDENTITY = "identity";
  static const String _STATUS = "status";
  static const String _LAST_UPDATE = "_lastUpdate";
  static const String _DEVICE_ID = "device_id";
  static const String _DEVICE_CREDENTIAL = "device_credential";
  static const String _RELATIVES = "relatives";

  Future<RegisteredUser> currentRegisteredUser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String identity = prefs.getString(_IDENTITY);
    int status = prefs.getInt(_STATUS);
    int lastUpdateTime = prefs.getInt(_LAST_UPDATE);
    if (_registeredUser == null && identity != null) {
      _registeredUser = RegisteredUser();
      _registeredUser.identity = identity;
      _registeredUser.status = status;
      _registeredUser.lastUpdateTime = lastUpdateTime;
    }

    return Future<RegisteredUser>.value(_registeredUser);
  }

  Future<DeviceCredentials> currentDeviceCredentials() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String deviceCredential = prefs.getString(_DEVICE_CREDENTIAL);
    String deviceId = prefs.getString(_DEVICE_ID);
    if (_registeredDeviceCredentials == null && deviceId != null) {
      _registeredDeviceCredentials = DeviceCredentials();
      _registeredDeviceCredentials.deviceId = deviceId;
      _registeredDeviceCredentials.deviceCredential = deviceCredential;
    }

    return Future<DeviceCredentials>.value(_registeredDeviceCredentials);
  }

  void setLocalUser(String identity) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString(_IDENTITY, identity);
  }

  void setLocalUserStatus(int status, int lastUpdate) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setInt(_STATUS, status);
    prefs.setInt(_LAST_UPDATE, lastUpdate);
  }

  void setLocalDeviceCredentials(DeviceCredentials deviceCredentials) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString(_DEVICE_ID, deviceCredentials.deviceId);
    prefs.setString(_DEVICE_CREDENTIAL, deviceCredentials.deviceCredential);
  }

  Future<List<String>> addRelative(String identifier) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    List<String> list = prefs.getStringList(_RELATIVES);
    if (list == null) list = List<String>();

    list.add(identifier);
    prefs.setStringList(_RELATIVES, list);
    return list;
  }

  Future<List<String>> getRelatives() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> list = prefs.getStringList(_RELATIVES);
    if (list == null) list = List<String>();
    return Future.value(list);
  }

  Future<void> signOut() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.remove(_IDENTITY);
    prefs.remove(_DEVICE_ID);
    prefs.remove(_DEVICE_CREDENTIAL);

    prefs.remove(_STATUS);
    prefs.remove(_LAST_UPDATE);
    prefs.remove(_RELATIVES);

    _registeredDeviceCredentials = null;
    _registeredUser = null;
    return;
  }

  Future<bool> removeRelative(String identifier) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    List<String> list = prefs.getStringList(_RELATIVES);
    if (list == null) return false;

    List<String> listTemp = List<String>();
    list.forEach((element) {
      if (element != identifier) listTemp.add(element);
    });

    prefs.setStringList(_RELATIVES, listTemp);

    return true;
  }
}
