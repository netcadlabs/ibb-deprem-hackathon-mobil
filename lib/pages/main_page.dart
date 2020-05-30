import 'package:depremhackathon/api/api_models.dart';
import 'package:depremhackathon/api/device_api.dart';
import 'package:depremhackathon/locator.dart';
import 'package:depremhackathon/pages/login.dart';
import 'package:depremhackathon/services/authenction_service.dart';
import 'package:device_info/device_info.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class MainPage extends StatefulWidget {
  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  List<Choice> choices = const <Choice>[
    const Choice(title: 'Çıkış', icon: Icons.exit_to_app, code: "exit")
  ];

  final DeviceApi deviceApi = DeviceApi();
  final AuthenticationService _auth = locator<AuthenticationService>();

  DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
  DeviceCredentials _deviceCredentials;
  RegisteredUser _registeredUser;

  Color safeColor = Color.fromRGBO(0, 102, 0, 1);
  Color dangerColor = Color.fromRGBO(153, 0, 0, 1);
  Color safeBackgroundColor = Color.fromRGBO(0, 102, 0, 0.5);
  Color dangerBackgroundColor = Color.fromRGBO(153, 0, 0, 0.5);

  @override
  Future<void> initState() {
    super.initState();
//    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
//    deviceInfo.androidInfo.then((value) {
//      _androidDeviceInfo = value;
//    });
    _auth.currentDeviceCredentials().then((value) {
      setState(() {
        _deviceCredentials = value;
      });
    });

    _auth.currentRegisteredUser().then((value) {
      setState(() {
        _registeredUser = value;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("İBB Deprem Hackathon"),
        actions: <Widget>[
          PopupMenuButton<Choice>(
            enabled: true,
            onSelected: _actionsPopUpMenu,
            itemBuilder: (BuildContext context) {
              return choices.map((Choice choice) {
                return PopupMenuItem<Choice>(
                  value: choice,
                  child: Text(choice.title),
                );
              }).toList();
            },
          ),
        ],
      ),
      body: Center(
        child: Container(
          color: getCurrentBackgroundColor(),
          padding: EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Center(
                  child: GestureDetector(
                onTap: () async {
                  sendStatus(true);
                },
                child: ClipOval(
                  child: Container(
                    color: safeColor,
                    height: 120.0, // height of the button
                    width: 120.0, // width of the button
                    child: Center(
                        child: Text(
                      'Güvendeyim',
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold),
                    )),
                  ),
                ),
              )),
              SizedBox(
                height: 50,
              ),
              Center(
                  child: GestureDetector(
                onTap: () async {
                  sendStatus(false);
                },
                child: ClipOval(
                  child: Container(
                    color: dangerColor,
                    height: 120.0, // height of the button
                    width: 120.0, // width of the button
                    child: Center(
                        child: Text('Güvende Değilim',
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold))),
                  ),
                ),
              )),
              Container(
                child: _getOptions(),
              ),
              Expanded(
                child: Container(),
              ),
              Container(
                margin: EdgeInsets.all(5),
                child: _lastStatus(),
              ),
              Container(
                margin: EdgeInsets.all(20),
                child: _registeredUser != null
                    ? Text("${_registeredUser.identity} olarak giriş yaptınız.")
                    : SizedBox(
                        height: 1,
                      ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Color getCurrentBackgroundColor() {
    if (_registeredUser == null) return Colors.grey;

    return _registeredUser.status == 1
        ? safeBackgroundColor
        : dangerBackgroundColor;
  }

  void sendStatus(bool status) async {
    int deviceTime = DateTime.now().millisecondsSinceEpoch;

    bool result = await deviceApi.sendAttribute(_deviceCredentials.deviceId,
        {"status": status, "deviceTime": deviceTime});

    int statusInt = status ? 1 : -1;
    _auth.setLocalUserStatus(statusInt, deviceTime);

    setState(() {
      _registeredUser.status = statusInt;
      _registeredUser.lastUpdateTime = deviceTime;
    });

    if (result)
      Fluttertoast.showToast(
          msg: "Durum Güncellendi",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.grey.withOpacity(0.9),
          textColor: Colors.white,
          fontSize: 16.0);
  }

  Widget _getOptions() {
    if (_registeredUser == null || _registeredUser.lastUpdateTime == 0)
      return Container();

    return _registeredUser.status == -1 ? _dangerOptions() : Container();
  }

  Widget _lastStatus() {
    if (_registeredUser == null ||
        _registeredUser.lastUpdateTime == null ||
        _registeredUser.lastUpdateTime == 0) return Container();

    DateTime lastUpdated =
        DateTime.fromMillisecondsSinceEpoch(_registeredUser.lastUpdateTime);

    String dateStr =
        "${lastUpdated.year.toString()}-${lastUpdated.month.toString().padLeft(2, '0')}-${lastUpdated.day.toString().padLeft(2, '0')} ${lastUpdated.hour.toString().padLeft(2, '0')}:${lastUpdated.minute.toString().padLeft(2, '0')}";
    return Container(
        child: Column(
      children: <Widget>[Text("Son Güncelleme : ${dateStr}")],
    ));
  }

  void _actionsPopUpMenu(Choice choice) async {
    if (choice.code == "exit") {
      final bool res = await showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text("Çıkış Onay"),
            content: Text("Çıkış yapmak istediğinize emin misiniz?"),
            actions: <Widget>[
              FlatButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text("İptal"),
              ),
              FlatButton(
                  onPressed: () async {
                    _auth.signOut();
                    Navigator.of(context).pop(true);
                  },
                  child: const Text("Evet")),
            ],
          );
        },
      );

      if (res)
        Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => LoginPage()),
            (Route<dynamic> route) => false);
    }
  }

  Widget _dangerOptions() {
    return Container(
      padding: EdgeInsets.all(10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          GestureDetector(
            onTap: () async {
              sendDangerStatus("YARALI", true);
            },
            child: ClipOval(
              child: Container(
                color: Colors.red,
                height: 60.0, // height of the button
                width: 60.0, // width of the button
                child: Center(
                    child: Text('Yaralıyım',
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 12))),
              ),
            ),
          ),
          GestureDetector(
            onTap: () async {
              sendDangerStatus("GÖÇÜK", true);
            },
            child: ClipOval(
              child: Container(
                color: Colors.red,
                height: 60.0, // height of the button
                width: 60.0, // width of the button
                child: Center(
                    child: Text('Göçük Altındayım',
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 12))),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void sendDangerStatus(String dangerStatus, bool value) async {
    bool result = await deviceApi
        .sendAttribute(_deviceCredentials.deviceId, {dangerStatus: value});

    if (result)
      Fluttertoast.showToast(
          msg: "Durum Güncellendi",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.grey.withOpacity(0.9),
          textColor: Colors.white,
          fontSize: 16.0);
  }
}

class Choice {
  const Choice({this.title, this.icon, this.code});

  final String title;
  final String code;
  final IconData icon;
}
