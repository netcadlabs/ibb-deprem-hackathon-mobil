import 'package:depremhackathon/api/announcement_api.dart';
import 'package:depremhackathon/api/api_models.dart';
import 'package:depremhackathon/styles/common_styles.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../utils.dart';

class DuyurularPage extends StatefulWidget {
  @override
  _DuyurularPageState createState() => _DuyurularPageState();
}

class _DuyurularPageState extends State<DuyurularPage> {
  AnnouncementApi _announcementApi = AnnouncementApi();

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
            final Announcement announcement = snapshot.data[index];
            return GestureDetector(
              onTap: () {
//                print("${duyuru} tıklandı...");
              },
              child: Container(
                  padding: EdgeInsets.all(5),
                  decoration: BoxDecoration(color: Colors.blueGrey),
//                  height: 100,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        announcement.title,
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 20),
                      ),
                      Text(
                        announcement.message,
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                      Container(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: <Widget>[
                            Text(
                              Utils.formatTimeStamp(announcement.date),
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 14),
                            )
                          ],
                        ),
                      )
                    ],
                  )),
            );
          },
        );
      },
      future: _announcementApi
          .getAnnouncements(), //?? nereden? - gelen bildirimler localde saklanır oradan çekilebilir..
    );
  }
}
