import 'dart:convert';

import 'package:depremhackathon/api/base_api.dart';

import 'api_models.dart';

class DeviceApi extends BaseApi {
  Future<DeviceCredentials> registerPhone(
      String identity, String deviceId) async {
    String path = "api/mobile/device";

    var response = await provider.post(path,
        {"name": identity, "type": "DEPREM-MOBIL-USER", "desc": deviceId});

    var data = jsonDecode(response.body);

    if (response.statusCode != 200) {
      print('API Login Error : $data');
      return Future.error(data);
    }

    var credentials = DeviceCredentials.fromJson(data);

    return Future.value(credentials);
  }

  Future<bool> sendAttribute(String deviceId, Map attributes,
      {String SCOPE = "SHARED_SCOPE"}) async {
    String path = "api/mobile/${deviceId}/${SCOPE}";

    var response = await provider.post(path, attributes);

    var data;
    if (response.body != null && response.body != "")
      var data = jsonDecode(response.body);

    if (response.statusCode != 200) {
      print('API Login Error : $data');
      return Future.error(false);
    }

    return Future.value(true);
  }
}
