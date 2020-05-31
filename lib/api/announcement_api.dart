import 'package:depremhackathon/api/base_api.dart';

import 'api_models.dart';

class AnnouncementApi extends BaseApi{
  Future<List<Announcement>> getAnnouncements() {
    List<Announcement> fakeList = List<Announcement>();
    fakeList.add(Announcement(
        title: "Duyuru 1",
        message: "Duyuru 1 içeriği....",
        date: DateTime.parse("2019-05-31 04:27:00").millisecondsSinceEpoch
    ));

    fakeList.add(Announcement(
        title: "Duyuru 2",
        message: "Duyuru 2 içeriği....",
        date: DateTime.parse("2019-05-31 04:29:00").millisecondsSinceEpoch
    ));

    //TODO - duyuruları local storage üzerinden getir..

    return Future.value(fakeList);
  }

  void addAnnouncement(Announcement){
    //TODO - duyuruyu local storage'a kaydet'
  }

  void clearAnnouncements(){
    //TODO - duyuruları sil, çıkış yapılınca çağrılır.
  }

}