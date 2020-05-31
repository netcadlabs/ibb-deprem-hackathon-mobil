import 'dart:convert';

import 'package:undisaster/api/base_api.dart';

import 'api_models.dart';

class DeviceApi extends BaseApi {
  Future<DeviceCredentials> registerPhone(
      String identity, String deviceId) async {
    String path = "api/mobile/device";

    var response = await provider
        .post(path, {"name": identity, "type": "mobile", "desc": deviceId});

    var data = jsonDecode(response.body);

    if (response.statusCode != 200) {
      print('API registerPhone Error : $data');
      return Future.error(data);
    }

    var credentials = DeviceCredentials.fromJson(data);

    return Future.value(credentials);
  }

  Future<bool> sendAttribute(String deviceId, Map attributes,
      {String scope = "SHARED_SCOPE"}) async {
    String path = "api/mobile/$deviceId/$scope";

    var response = await provider.post(path, attributes);

    var data;
    if (response.body != null && response.body != "")
      data = jsonDecode(response.body);

    if (response.statusCode != 200) {
      print('API sendAttribute Error : $data');
      return Future.error(false);
    }

    return Future.value(true);
  }

  Future<DeviceDetails> getRegisteredDeviceDetails(identifier) async {
    String path = "api/mobile/details?name=$identifier";
    DeviceDetails deviceDetails;

    try {
      var response = await provider.get(path);
      var data = jsonDecode(response.body);

      if (response.statusCode != 200) {
        print('API getRegisteredDeviceDetails Error : $data');
        return Future.value(null);
      }

      deviceDetails = DeviceDetails.fromJson(data);
      return Future.value(deviceDetails);
    } catch (error) {
      print('API getRegisteredDeviceDetails Parse Error : $error');
      return Future.value(null);
    }
  }
}
