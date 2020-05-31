import 'package:undisaster/api/device_api.dart';
import 'package:undisaster/pages/relative_list_card.dart';
import 'package:undisaster/services/authenction_service.dart';
import 'package:undisaster/styles/common_styles.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../locator.dart';

class YakinlarimPage extends StatefulWidget {
  @override
  _YakinlarimSayfasiState createState() => _YakinlarimSayfasiState();
}

class _YakinlarimSayfasiState extends State<YakinlarimPage> {
  final DeviceApi deviceApi = DeviceApi();
  final AuthenticationService _auth = locator<AuthenticationService>();

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

                    await _auth.addRelative(relativeIdentity);
                    setState(() {
//                      _relativeList = list;
                    });
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
