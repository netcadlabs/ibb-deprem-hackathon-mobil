import 'package:depremhackathon/api/base_api.dart';

import 'api_models.dart';

class AnnouncementApi extends BaseApi {
  Future<List<Announcement>> getAnnouncements() {
    List<Announcement> fakeList = List<Announcement>();

    fakeList.add(Announcement(
        title: "Deprem Uyarı!",
        message:
            "Kandilli Rasathanesinden alınan bilgilere göre Silivri açıklarında 7.5 şiddetinde deprem olmuştur.\nArtçı depremlerin oluşturabileceği hasardan korunmak için panik yapmadan varsa deprem çantanızı alarak toplanma alanlarına gitmeniz önemle rica olunur",
        date: DateTime.parse("2019-05-31 18:02:00").millisecondsSinceEpoch));

    fakeList.add(Announcement(
        title: "Duyuru",
        message:
            "Lütfen ulaşamadığınzı yakınlarınıza ait durumu takip etmek için 'Yakınlarım' sayfasından yakınlarınızı kimlik numarası ile ekleynizi.",
        date: DateTime.parse("2019-05-31 19:38:00").millisecondsSinceEpoch));

    fakeList.add(Announcement(
        title: "İletişim Merkezi",
        message:
            "Yakınları ile iletişime geçemeyen afetzedeler için iletişim merkezimiz bulunduğunuz mahalledeki muhtarlıkta hizmetine başlamıştır",
        date: DateTime.parse("2019-05-31 19:43:00").millisecondsSinceEpoch));

    fakeList.add(Announcement(
        title: "Yemek Servisi",
        message: "Bulunduğunuz toplanma alanında yemek dağıtımı başlanmıştır.",
        date: DateTime.parse("2019-05-31 23:20:00").millisecondsSinceEpoch));

    //TODO - duyuruları local storage üzerinden getir..

    return Future.value(fakeList);
  }

  void addAnnouncement(Announcement) {
    //TODO - duyuruyu local storage'a kaydet'
  }

  void clearAnnouncements() {
    //TODO - duyuruları sil, çıkış yapılınca çağrılır.
  }
}
