import 'package:depremhackathon/api/api_models.dart';
import 'package:depremhackathon/api/device_api.dart';
import 'package:depremhackathon/pages/relative_list_card.dart';
import 'package:depremhackathon/services/authenction_service.dart';
import 'package:depremhackathon/styles/common_styles.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../locator.dart';
import '../utils.dart';

class YakinlarimPage extends StatefulWidget {
  @override
  _YakinlarimSayfasiState createState() => _YakinlarimSayfasiState();
}

class _YakinlarimSayfasiState extends State<YakinlarimPage> {
  final DeviceApi deviceApi = DeviceApi();
  final AuthenticationService _auth = locator<AuthenticationService>();
  List<String> _relativeList;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Yakınlarım",
          style: CommonWidgetAndStyles.appBarTitleStyle,
          textAlign: TextAlign.center,
        ),
      ),
      body: Container(
        color: Theme.of(context).primaryColorLight,
        child: Center(
          child: _getRelativesList(),
        ),
      ),
      floatingActionButton: FloatingActionButton(
          child: Icon(Icons.person_add),
          onPressed: () {
            _addNewRelativeDialog(context);
          }),
    );
  }

  FutureBuilder _getRelativesList() {
    return FutureBuilder(
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.none &&
            !snapshot.hasData) {
          return Center(
            child: CircularProgressIndicator(),
          );
        }
        if (snapshot.data == null) {
          return Center(
            child: CircularProgressIndicator(),
          );
        }
        if (snapshot.data.length == 0) {
          return Center(
              child: Text(
            "Yakınlarım Listesi Boş",
            textAlign: TextAlign.center,
          ));
        }
        return ListView.builder(
          itemCount: snapshot.data.length,
          itemBuilder: (context, index) {
            final String identifier = snapshot.data[index];
            return RelativeListCard(identifier);
            return Dismissible(
              key: UniqueKey(),
              child: GestureDetector(
                onTap: () {
//                  _relativeDetailShow(context, identifier);
                },
                child: Container(
                    padding: EdgeInsets.all(5),
                    decoration: BoxDecoration(color: Colors.blueGrey),
                    height: 55,
                    child: Row(
                      children: <Widget>[
                        Text(
                          identifier,
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 25),
                        ),
                      ],
                    )),
              ),
              confirmDismiss: (direction) async {
                if (direction == DismissDirection.endToStart)
                  return await _auth.removeRelative(identifier);
                return false;
              },
              onDismissed: (direction) {},
              background: Container(),
              secondaryBackground:
                  CommonWidgetAndStyles.removeListItemBackground(),
            );
          },
        );
      },
      future: _auth.getRelatives(),
    );
  }

  _addNewRelativeDialog(BuildContext context) async {
    return showDialog(
        context: context,
        builder: (context) {
          TextEditingController _textFieldController = TextEditingController();
          final _textKey = GlobalKey<FormState>();
          return AlertDialog(
            title: Text('Yeni Yakın Ekle'),
            content: TextField(
              key: _textKey,
              keyboardType: TextInputType.number,
              controller: _textFieldController,
              decoration: InputDecoration(hintText: "Kimlik Numarası Giriniz"),
              maxLines: 1,
              maxLength: 11,
            ),
            actions: <Widget>[
              new FlatButton(
                child: new Text('İptal'),
                onPressed: () {
                  _textFieldController.clear();
                  Navigator.of(context).pop();
                },
              ),
              new FlatButton(
                child: new Text('Ekle'),
                onPressed: () async {
                  String relativeIdentity = _textFieldController.text;

                  if (relativeIdentity != null &&
                      relativeIdentity.length >= 11 &&
                      int.tryParse(relativeIdentity) != null) {

                    print("$relativeIdentity");

                    List<String> list =
                        await _auth.addRelative(relativeIdentity);
                    setState(() {
                      _relativeList = list;
                    });
//                    String mesaj = "Yorum eklendi";
//                    Color color = Colors.grey;
//                    Fluttertoast.showToast(
//                        msg: mesaj,
//                        toastLength: Toast.LENGTH_LONG,
//                        gravity: ToastGravity.CENTER,
//                        timeInSecForIosWeb: 1,
//                        backgroundColor: color,
//                        textColor: Colors.white,
//                        fontSize: 16.0);
                    _textFieldController.clear();
                    Navigator.of(context).pop();
                  }
                },
              )
            ],
          );
        });
  }
}
