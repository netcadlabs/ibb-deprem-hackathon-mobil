import 'package:depremhackathon/services/authenction_service.dart';
import 'package:depremhackathon/styles/common_styles.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../locator.dart';

class YakinlarimPage extends StatefulWidget {
  @override
  _YakinlarimSayfasiState createState() => _YakinlarimSayfasiState();
}

class _YakinlarimSayfasiState extends State<YakinlarimPage> {
  final AuthenticationService _auth = locator<AuthenticationService>();
  List<String> _relativeList;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _auth.getRelatives().then((value) {
      setState(() {
        _relativeList = value;
      });
    });
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
      body: Center(
        child: _getRelativesList(),
      ),
      floatingActionButton: FloatingActionButton(
//          backgroundColor: DersDetayRenkleri.yorumGenelRengi,
          child: Icon(Icons.person_add),
          onPressed: () {
            _yakinEklemeDialogGoster(context);
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
          return Center(child: Text("Bulunamadı"));
        }

        return ListView.builder(
          itemCount: snapshot.data.length,
          itemBuilder: (context, index) {
            final String identifier = snapshot.data[index];
            return Dismissible(
              key: UniqueKey(),
              child: GestureDetector(
                onTap: () {
                  print("${identifier} tıklandı...");
                },
                child: Container(
                    padding: EdgeInsets.all(5),
                    decoration: BoxDecoration(color: Colors.blueGrey),
                    height: 50,
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
                if (direction == DismissDirection.startToEnd) return false;

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

  TextEditingController _textFieldController = TextEditingController();

  _yakinEklemeDialogGoster(BuildContext context) async {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Yeni Yakın Ekle'),
            content: TextField(
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
                  String yorum = _textFieldController.text;
                  if (yorum != null && yorum.length >= 5) {
                    print("$yorum");

                    List<String> list = await _auth.addRelative(yorum);
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
