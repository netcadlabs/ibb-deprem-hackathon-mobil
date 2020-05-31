import 'package:depremhackathon/api/api_models.dart';
import 'package:depremhackathon/api/device_api.dart';
import 'package:depremhackathon/locator.dart';
import 'package:depremhackathon/pages/login.dart';
import 'package:depremhackathon/pages/yakinlarim_page.dart';
import 'package:depremhackathon/services/authenction_service.dart';
import 'package:depremhackathon/styles/common_styles.dart';
import 'package:device_info/device_info.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';

import '../utils.dart';
import 'duyurular_page.dart';

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
  bool _locationSent = false;

  Color safeColor = Color.fromRGBO(0, 102, 0, 1);
  Color dangerColor = Color.fromRGBO(153, 0, 0, 1);
  Color safeBackgroundColor = Color.fromRGBO(0, 102, 0, 0.3);
  Color dangerBackgroundColor = Color.fromRGBO(153, 0, 0, 0.3);
  String userIdentity = "-";

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

      _getCurrentLocation();
    });

    _auth.currentRegisteredUser().then((value) {
      setState(() {
        _registeredUser = value;
        userIdentity = _registeredUser.identity;
      });
    });
  }

  GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
//        backgroundColor: Colors.red,
        title: Text(
          "İBB Deprem Hackathon",
          style: CommonWidgetAndStyles.appBarTitleStyle,
        ),
        automaticallyImplyLeading: false,
        leading: IconButton(
            icon: Icon(Icons.dehaze),
            onPressed: () {
              if (_scaffoldKey.currentState.isDrawerOpen == false) {
                _scaffoldKey.currentState.openDrawer();
              } else {
                _scaffoldKey.currentState.openEndDrawer();
              }
            }),
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
//      drawer:
      body: Scaffold(
        key: _scaffoldKey,
        drawer: getdrawer(),
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
                      height: getCircleSize(1, 120, 90),
                      width: getCircleSize(1, 120, 90),
                      child: Center(
                          child: Text(
                        'Güvendeyim',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold),
                      )),
                    ),
                  ),
                )),
                Container(
                  child: _getSafeOptions(),
                ),
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
                      height: getCircleSize(-1, 120, 90),
                      width: getCircleSize(-1, 120, 90),
                      child: Center(
                          child: Text('Güvende Değilim',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold))),
                    ),
                  ),
                )),
                Container(
                  child: _getDangerOptions(),
                ),
                Expanded(
                  child: Container(),
                ),
                Container(
                  margin: EdgeInsets.only(bottom: 5),
                  child: _lastStatus(),
                ),
                Container(
                  margin: EdgeInsets.only(bottom: 5),
                  child: _locationStatus(),
                ),
//                Container(
//                  child: _currentUserDetails(),
//                )
              ],
            ),
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

  double getCircleSize(
      int checkStatus, double activeSize, double deactiveSize) {
    if (_registeredUser == null) return deactiveSize;

    return _registeredUser.status == checkStatus ? activeSize : deactiveSize;
  }

  Widget getdrawer() {
    return Container(
      width: 260,
      child: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            Container(
              height: 150,
              child: DrawerHeader(
                padding: EdgeInsets.only(top: 20, left: 20),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor,
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    ClipOval(
                      child: Container(
                        padding: EdgeInsets.all(2),
                        color: Colors.white,
                        height: 45.0,
                        width: 45.0,
                        child: Center(child: Icon(Icons.person)),
                      ),
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    Container(
                      height: 45,
                      child: Column(
//                        crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Text(
                            userIdentity,
                            style: TextStyle(fontSize: 20, color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            ListTile(
              leading: Icon(
                Icons.supervisor_account,
                color: Colors.grey,
              ),
              title: Text('Yakınlarım'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => YakinlarimPage(),
                  ),
                );
              },
            ),
            ListTile(
              leading: Icon(
                Icons.announcement,
                color: Colors.grey,
              ),
              title: Text('Duyurular'),
              onTap: () {
                print("Duyurular tıklandı");
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => DuyurularPage(),
                  ),
                );
              },
            ),
            ListTile(
              leading: Icon(
                Icons.map,
                color: Colors.grey,
              ),
              title: Text('Toplanma Alanları'),
              onTap: () {
                print("Toplanma tıklandı");
              },
            ),
            Divider(
              color: Colors.grey,
              thickness: 1,
            ),
            ListTile(
              leading: Icon(
                Icons.help,
                color: Colors.grey,
              ),
              title: Text('Yardım'),
              onTap: () {
                print("Yardım tıklandı");
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _getDangerOptions() {
    if (_registeredUser == null) return Container();

    return _registeredUser.status == -1
        ? Container(
            padding: EdgeInsets.all(10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                GestureDetector(
                  onTap: () async {
                    sendDangerStatus("YARALI", true);
                  },
                  child: ClipOval(
                    child: getOptionCircle("Yaralıyım",
                        color: dangerColor.withOpacity(0.7)),
                  ),
                ),
                SizedBox(
                  width: 6,
                ),
                GestureDetector(
                  onTap: () async {
                    sendDangerStatus("GÖÇÜK", true);
                  },
                  child: ClipOval(
                    child: getOptionCircle("Göçük Altındayım",
                        color: dangerColor.withOpacity(0.7)),
                  ),
                ),
              ],
            ),
          )
        : Container();
  }

  Widget _getSafeOptions() {
    if (_registeredUser == null || _registeredUser.status != 1)
      return Container();

    return Container(
      padding: EdgeInsets.all(10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          GestureDetector(
            onTap: () async {
              sendDangerStatus("TOPLANMA_ALANI", true);
            },
            child: ClipOval(
              child: getOptionCircle("Toplanma Alanındayım",
                  color: safeColor.withOpacity(0.7)),
            ),
          ),
          SizedBox(
            width: 6,
          ),
          GestureDetector(
            onTap: () async {
              sendDangerStatus("GÖÇÜK", true);
            },
            child: getOptionCircle("Göçük Altındayım",
                color: dangerColor.withOpacity(0.7)),
          ),
        ],
      ),
    );
  }

  Widget _lastStatus() {
    if (_registeredUser == null ||
        _registeredUser.lastUpdateTime == null ||
        _registeredUser.lastUpdateTime == 0) return Container();

    String dateStr = Utils.formatTimeStamp(_registeredUser.lastUpdateTime);
    return Container(
      child: Row(
        children: <Widget>[
          Icon(
            Icons.access_time,
            size: 20,
          ),
          SizedBox(
            width: 6,
          ),
          Text("Son Güncelleme : ${dateStr}"),
        ],
      ),
    );
  }

  Widget _locationStatus() {
    Color locationColor = _locationSent ? Colors.green : Colors.grey;
    String locationText = _locationSent
        ? "Konum bilgisi paylaşıldı"
        : "Konum bilgisi paylaşılamadı";
    return Container(
      child: Row(
        children: <Widget>[
          Icon(
            Icons.my_location,
            color: locationColor,
            size: 20,
          ),
          SizedBox(
            width: 6,
          ),
          Text(locationText)
        ],
      ),
    );
  }

  Widget _currentUserDetails() {
    if (_registeredUser == null)
      return Container();
    else
      return Row(
        children: <Widget>[
          Icon(
            Icons.person,
//            color: locationColor,
            size: 20,
          ),
          SizedBox(
            width: 6,
          ),
          Text("${_registeredUser.identity} olarak giriş yaptınız."),
        ],
      );
  }

  Widget getOptionCircle(String text, {Color color}) {
    if (color == null) color = Colors.grey;
    return ClipOval(
      child: Container(
        padding: EdgeInsets.all(2),
        color: color,
        height: 66.0,
        width: 66.0,
        child: Center(
            child: Text(text,
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 11))),
      ),
    );
  }

  void sendStatus(bool status) async {
    int deviceTime = DateTime.now().millisecondsSinceEpoch;

    bool result = await deviceApi.sendAttribute(_deviceCredentials.deviceId, {
      "status": status,
      "error": status == false, //Durum false ise error true gönder
      "deviceTime": deviceTime
    });

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

  void _getCurrentLocation() async {
    final Geolocator geolocator = Geolocator()..forceAndroidLocationManager;

    geolocator
        .getCurrentPosition(desiredAccuracy: LocationAccuracy.best)
        .then((Position position) {
      deviceApi.sendAttribute(_deviceCredentials.deviceId, {
        "latitude": position.latitude,
        "longitude": position.longitude,
      }).then((res) {
        if (res)
          setState(() {
            _locationSent = true;
          });
      });
    }).catchError((e) {
      print(e);
    });
  }
}

class Choice {
  const Choice({this.title, this.icon, this.code});

  final String title;
  final String code;
  final IconData icon;
}
