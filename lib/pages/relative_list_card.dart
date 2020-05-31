import 'package:depremhackathon/api/api_models.dart';
import 'package:depremhackathon/api/device_api.dart';
import 'package:depremhackathon/services/authenction_service.dart';
import 'package:depremhackathon/styles/common_styles.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../locator.dart';
import '../utils.dart';

class RelativeListCard extends StatefulWidget {
  final String identity;

  RelativeListCard(this.identity);

  @override
  _RelativeListCardState createState() => _RelativeListCardState();
}

class _RelativeListCardState extends State<RelativeListCard> {
  final DeviceApi deviceApi = DeviceApi();
  final AuthenticationService _auth = locator<AuthenticationService>();
  int currentStatus;
  SharedPreferences _sharedPreferences;
  String _STATUS_KEY;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _STATUS_KEY = "status-${widget.identity}";
    SharedPreferences.getInstance().then((sharedPrefs) {
      _sharedPreferences = sharedPrefs;
      int state = sharedPrefs.getInt(_STATUS_KEY);
      if (state != null)
        setState(() {
          currentStatus = state;
        });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: UniqueKey(),
      child: GestureDetector(
        onTap: () {
          _relativeDetailShow(context, this.widget.identity);
        },
        child: Container(
            padding: EdgeInsets.all(5),
            margin: EdgeInsets.only(bottom: 4),
            decoration: BoxDecoration(color: Colors.blueGrey),
            height: 55,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(
                  this.widget.identity,
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 25),
                ),
                _getStatusIcon(),
              ],
            )),
      ),
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.endToStart)
          return await _auth.removeRelative(this.widget.identity);
        return false;
      },
      onDismissed: (direction) {},
      background: Container(),
      secondaryBackground: CommonWidgetAndStyles.removeListItemBackground(),
    );
  }

  Widget _getStatusIcon() {
    if (currentStatus == 1) {
      return Icon(
        Icons.check_circle,
        color: Colors.green,
      );
    } else if (currentStatus == -1) {
      return Icon(
        Icons.error,
        color: Colors.red,
      );
    } else {
      return Icon(
        Icons.help,
        color: Colors.white,
      );
    }
  }

  _relativeDetailShow(BuildContext context, String identifier) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          child: new Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              new CircularProgressIndicator(),
              new Text("Yükleniyor"),
            ],
          ),
        );
      },
    );

    deviceApi
        .getRegisteredDeviceDetails(identifier)
        .then((DeviceDetails deviceDetails) {
      Navigator.pop(context); //pop dialog

      String durum = "Bilinmiyor";
      String dateStr = "Bilinmiyor";

      if (deviceDetails == null) {
        return showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: Text(identifier),
                content: Container(
                  child: Text(
                      "Bu kimlik bilgisine sahip sisteme kayıtlı kullanıcı bulunamadı."),
                ),
                actions: <Widget>[
                  new FlatButton(
                    child: new Text('Tamam'),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              );
            });
      }

      dateStr = Utils.formatTimeStamp(deviceDetails.lastSeen);
      if (deviceDetails.status == 1) {
        durum = "Güvende";
      } else if (deviceDetails.status == -1) {
        durum = "Yardım Bekliyor";
      }

      return showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text(identifier),
              content: Container(
                height: 100,
                child: Column(
                  children: <Widget>[
                    Row(
                      children: <Widget>[Text("Durum : "), Text(durum)],
                    ),
                    SizedBox(
                      height: 3,
                    ),
                    Row(
                      children: <Widget>[
                        Text("Son Güncelleme : "),
                        Text(dateStr)
                      ],
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    _getHaritaButton(deviceDetails)
                  ],
                ),
              ),
              actions: <Widget>[
                new FlatButton(
                  child: new Text('Tamam'),
                  onPressed: () {
                    Navigator.of(context).pop();
                    if (deviceDetails != null) {
                      _sharedPreferences.setInt(
                          _STATUS_KEY, deviceDetails.status);
                      setState(() {
                        currentStatus = deviceDetails.status;
                      });
                    }
                  },
                ),
              ],
            );
          });
    });
  }

  Widget _getHaritaButton(DeviceDetails deviceDetails) {
    if (deviceDetails == null ||
        deviceDetails.lat == 0 ||
        deviceDetails.lon == 0) return Container();

    Color color = Colors.green;
    if (deviceDetails.status == -1) color = Colors.redAccent;

    return Container(
      child: RaisedButton(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(
              Icons.map,
              color: color,
            ),
            SizedBox(
              width: 6,
            ),
            Text("Konumu Haritada Göster"),
          ],
        ),
        onPressed: () {
          MapUtils.openMap(deviceDetails.lat, deviceDetails.lon);
        },
      ),
    );
  }
}
