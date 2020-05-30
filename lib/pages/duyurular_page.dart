import 'package:depremhackathon/styles/common_styles.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class DuyurularPage extends StatefulWidget {
  @override
  _DuyurularPageState createState() => _DuyurularPageState();
}

class _DuyurularPageState extends State<DuyurularPage> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Duyurular",
          style: CommonWidgetAndStyles.appBarTitleStyle,
          textAlign: TextAlign.center,
        ),
      ),
      body: Center(
        child: _getRelativesList(),
      ),
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
          return Center(child: Text("Duyuru bulunmuyor"));
        }
        return ListView.builder(
          itemCount: snapshot.data.length,
          itemBuilder: (context, index) {
            final String duyuru = snapshot.data[index];
            return GestureDetector(
              onTap: () {
//                print("${duyuru} tıklandı...");
              },
              child: Container(
                  padding: EdgeInsets.all(5),
                  decoration: BoxDecoration(color: Colors.blueGrey),
                  height: 100,
                  child: Row(
                    children: <Widget>[
                      Text(
                        duyuru,
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                    ],
                  )),
            );
          },
        );
      },
//      future: _duyuruApi.getAnnouncements(), //?? nereden? - gelen bildirimler localde saklanır oradan çekilebilir..
    );
  }
}
