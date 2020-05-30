import 'dart:async';

import 'package:connectivity/connectivity.dart';
import 'package:depremhackathon/api/device_api.dart';
import 'package:depremhackathon/services/authenction_service.dart';
import 'package:device_info/device_info.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../locator.dart';
import './main_page.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool _isLoading = false;
  String errorMessage = "";
  final AuthenticationService _auth = locator<AuthenticationService>();

//  final MQTTClientWrapper _mqttClientWrapper = locator<MQTTClientWrapper>();
  final Connectivity _connectivity = Connectivity();
  StreamSubscription<ConnectivityResult> _connectivitySubscription;
  ConnectivityResult _connectivityResult = ConnectivityResult.none;
  final DeviceApi deviceApi = DeviceApi();

  @override
  void initState() {
    super.initState();
    initConnectivity();
    _connectivitySubscription =
        _connectivity.onConnectivityChanged.listen(_updateConnectionStatus);

//    _mqttClientWrapper.addConnectionListener(() {
//      setState(() {});
//    });
//    _mqttClientWrapper.addDisConnectionListener(() {
//      setState(() {});
//    });
  }

  Future<void> _updateConnectionStatus(ConnectivityResult result) async {
    setState(() {
      _connectivityResult = result;
    });
  }

  Future<void> initConnectivity() async {
    ConnectivityResult result;
    try {
      result = await _connectivity.checkConnectivity();
      setState(() {
        _connectivityResult = result;
      });
    } on PlatformException catch (e) {
      print(e.toString());
    }

    if (!mounted) {
      return Future.value(null);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Colors.white,
        padding: EdgeInsets.symmetric(horizontal: 15.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
              child: Column(
                children: <Widget>[
                  Text(
                    "Sesimi Duyan Var Mı ?",
                    style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Text(
                    "Uygulama hakkında kısa kısa açıklama..",
                    style: TextStyle(fontSize: 21),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 60,
            ),
            formSection(),
            buttonSection(),
            connectivityStatus()
          ],
        ),
      ),
    );
  }

  startRegistration(String identity) async {
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    AndroidDeviceInfo androidDeviceInfo = await deviceInfo.androidInfo;

    deviceApi.registerPhone(identity, androidDeviceInfo.id).then((value) {
      _auth.setLocalUser(identity);
      _auth.setLocalDeviceCredentials(value);

      Fluttertoast.showToast(
          msg: "Kayıt Başarılı",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.green.withOpacity(0.3),
          textColor: Colors.white,
          fontSize: 16.0);

      Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (BuildContext context) => MainPage()),
          (Route<dynamic> route) => false);
    }).catchError((error) {
      setState(() {
        _isLoading = false;
      });
      String message = "Bir hata oluştu";
      if (error != null) message = error.toString();
      Fluttertoast.showToast(
          msg: message,
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0);
    });
  }

  Container buttonSection() {
    return Container(
      child: RaisedButton(
        onPressed: _connectivityResult == ConnectivityResult.none
            ? null
            : onStartClicked,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Text("Başla", style: TextStyle(color: Colors.black)),
            Icon(Icons.arrow_forward),
          ],
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5.0)),
      ),
    );
  }

  void onStartClicked() {
    if (identityNumberController.text == "") return null;
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });
    startRegistration(identityNumberController.text);
  }

  Widget connectivityStatus() {
    if (_connectivityResult == ConnectivityResult.none)
      return Container(
        child: Text(
          "İnternet bağlantınızı kontrol ediniz...",
          style: TextStyle(color: Colors.red, fontSize: 14),
        ),
      );
    return Container();
  }

  final TextEditingController identityNumberController =
      new TextEditingController();

  Container formSection() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 15.0, vertical: 20.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          TextFormField(
            controller: identityNumberController,
            style: TextStyle(color: Colors.black),
            decoration: InputDecoration(
              icon: Icon(Icons.confirmation_number, color: Colors.red),
              hintText: "Kimlik No",
              border: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.deepPurple)),
            ),
          ),
//          SizedBox(height: 30.0),
//          TextFormField(
//            controller: passwordController,
//            obscureText: true,
//            style: TextStyle(color: Colors.black),
//            decoration: InputDecoration(
//              icon: Icon(Icons.lock, color: Colors.deepPurple),
//              hintText: "Password",
//              border: UnderlineInputBorder(
//                  borderSide: BorderSide(color: Colors.deepPurple)),
//            ),
//          ),
        ],
      ),
    );
  }
}
