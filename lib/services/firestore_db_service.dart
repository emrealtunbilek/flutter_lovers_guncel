import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_lovers/model/konusma.dart';
import 'package:flutter_lovers/model/mesaj.dart';
import 'package:flutter_lovers/model/user.dart';
import 'package:flutter_lovers/services/database_base.dart';

class FirestoreDBService implements DBBase {
  final FirebaseFirestore _firebaseDB = FirebaseFirestore.instance;

  @override
  Future<bool> saveUser(MyUser user) async {
    DocumentSnapshot _okunanUser = await FirebaseFirestore.instance.doc("users/${user.userID}").get();

    if (_okunanUser.data() == null) {
      print("nullll");
      print(_okunanUser.toString());
      await _firebaseDB.collection("users").doc(user.userID).set(user.toMap());
      return true;
    } else {
      return true;
    }
  }

  @override
  Future<MyUser> readUser(String userID) async {
    DocumentSnapshot _okunanUser = await _firebaseDB.collection("users").doc(userID).get();
    Map<String, dynamic> _okunanUserBilgileriMap = _okunanUser.data();

    MyUser _okunanUserNesnesi = MyUser.fromMap(_okunanUserBilgileriMap);
    return _okunanUserNesnesi;
  }

  @override
  Future<bool> updateUserName(String userID, String yeniUserName) async {
    var users = await _firebaseDB.collection("users").where("userName", isEqualTo: yeniUserName).get();
    if (users.docs.length >= 1) {
      return false;
    } else {
      await _firebaseDB.collection("users").doc(userID).update({'userName': yeniUserName});
      return true;
    }
  }

  @override
  Future<bool> updateProfilFoto(String userID, String profilFotoURL) async {
    await _firebaseDB.collection("users").doc(userID).update({'profilURL': profilFotoURL});
    return true;
  }

  @override
  Future<List<Konusma>> getAllConversations(String userID) async {
    QuerySnapshot querySnapshot =
        await _firebaseDB.collection("konusmalar").where("konusma_sahibi", isEqualTo: userID).orderBy("olusturulma_tarihi", descending: true).get();

    List<Konusma> tumKonusmalar = [];

    for (DocumentSnapshot tekKonusma in querySnapshot.docs) {
      Konusma _tekKonusma = Konusma.fromMap(tekKonusma.data());
      /*print("okunan konusma tarisi:" +
          _tekKonusma.olusturulma_tarihi.toDate().toString());*/
      tumKonusmalar.add(_tekKonusma);
    }

    return tumKonusmalar;
  }

  /*
  @override
  Stream<Mesaj> getMessage(String currentUserID, String sohbetEdilenUserID) {
    var snapShot = _firebaseDB
        .collection("konusmalar")
        .document(currentUserID + "--" + sohbetEdilenUserID)
        .collection("mesajlar")
        .document(currentUserID)
        .snapshots();


    return snapShot.map((snapShot)=>Mesaj.fromMap(snapShot.data));
  }
*/

  @override
  Stream<List<Mesaj>> getMessages(String currentUserID, String sohbetEdilenUserID) {
    var snapShot = _firebaseDB
        .collection("konusmalar")
        .doc(currentUserID + "--" + sohbetEdilenUserID)
        .collection("mesajlar")
        .where("konusmaSahibi", isEqualTo: currentUserID)
        .orderBy("date", descending: true)
        .limit(1)
        .snapshots();
    return snapShot.map((mesajListesi) => mesajListesi.docs.map((mesaj) => Mesaj.fromMap(mesaj.data())).toList());
  }

  Future<bool> saveMessage(Mesaj kaydedilecekMesaj) async {
    var _mesajID = _firebaseDB.collection("konusmalar").doc().id;
    var _myDocumentID = kaydedilecekMesaj.kimden + "--" + kaydedilecekMesaj.kime;
    var _receiverDocumentID = kaydedilecekMesaj.kime + "--" + kaydedilecekMesaj.kimden;

    var _kaydedilecekMesajMapYapisi = kaydedilecekMesaj.toMap();

    await _firebaseDB.collection("konusmalar").doc(_myDocumentID).collection("mesajlar").doc(_mesajID).set(_kaydedilecekMesajMapYapisi);

    await _firebaseDB.collection("konusmalar").doc(_myDocumentID).set({
      "konusma_sahibi": kaydedilecekMesaj.kimden,
      "kimle_konusuyor": kaydedilecekMesaj.kime,
      "son_yollanan_mesaj": kaydedilecekMesaj.mesaj,
      "konusma_goruldu": false,
      "olusturulma_tarihi": FieldValue.serverTimestamp(),
    });

    _kaydedilecekMesajMapYapisi.update("bendenMi", (deger) => false);
    _kaydedilecekMesajMapYapisi.update("konusmaSahibi", (deger) => kaydedilecekMesaj.kime);

    await _firebaseDB.collection("konusmalar").doc(_receiverDocumentID).collection("mesajlar").doc(_mesajID).set(_kaydedilecekMesajMapYapisi);

    await _firebaseDB.collection("konusmalar").doc(_receiverDocumentID).set({
      "konusma_sahibi": kaydedilecekMesaj.kime,
      "kimle_konusuyor": kaydedilecekMesaj.kimden,
      "son_yollanan_mesaj": kaydedilecekMesaj.mesaj,
      "konusma_goruldu": false,
      "olusturulma_tarihi": FieldValue.serverTimestamp(),
    });

    return true;
  }

  @override
  Future<DateTime> saatiGoster(String userID) async {
    await _firebaseDB.collection("server").doc(userID).set({
      "saat": FieldValue.serverTimestamp(),
    });

    var okunanMap = await _firebaseDB.collection("server").doc(userID).get();
    Timestamp okunanTarih = okunanMap.data()["saat"];
    return okunanTarih.toDate();
  }

  @override
  Future<List<MyUser>> getUserwithPagination(MyUser enSonGetirilenUser, int getirilecekElemanSayisi) async {
    QuerySnapshot _querySnapshot;
    List<MyUser> _tumKullanicilar = [];

    if (enSonGetirilenUser == null) {
      _querySnapshot = await FirebaseFirestore.instance.collection("users").orderBy("userName").limit(getirilecekElemanSayisi).get();
    } else {
      _querySnapshot = await FirebaseFirestore.instance
          .collection("users")
          .orderBy("userName")
          .startAfter([enSonGetirilenUser.userName])
          .limit(getirilecekElemanSayisi)
          .get();

      await Future.delayed(Duration(seconds: 1));
    }

    for (DocumentSnapshot snap in _querySnapshot.docs) {
      MyUser _tekUser = MyUser.fromMap(snap.data());
      _tumKullanicilar.add(_tekUser);
    }

    return _tumKullanicilar;
  }

  Future<List<Mesaj>> getMessagewithPagination(String currentUserID, String sohbetEdilenUserID, Mesaj enSonGetirilenMesaj, int getirilecekElemanSayisi) async {
    QuerySnapshot _querySnapshot;
    List<Mesaj> _tumMesajlar = [];

    if (enSonGetirilenMesaj == null) {
      _querySnapshot = await FirebaseFirestore.instance
          .collection("konusmalar")
          .doc(currentUserID + "--" + sohbetEdilenUserID)
          .collection("mesajlar")
          .where("konusmaSahibi", isEqualTo: currentUserID)
          .orderBy("date", descending: true)
          .limit(getirilecekElemanSayisi)
          .get();
    } else {
      _querySnapshot = await FirebaseFirestore.instance
          .collection("konusmalar")
          .doc(currentUserID + "--" + sohbetEdilenUserID)
          .collection("mesajlar")
          .where("konusmaSahibi", isEqualTo: currentUserID)
          .orderBy("date", descending: true)
          .startAfter([enSonGetirilenMesaj.date])
          .limit(getirilecekElemanSayisi)
          .get();

      await Future.delayed(Duration(seconds: 1));
    }

    for (DocumentSnapshot snap in _querySnapshot.docs) {
      Mesaj _tekMesaj = Mesaj.fromMap(snap.data());
      _tumMesajlar.add(_tekMesaj);
    }

    return _tumMesajlar;
  }

  Future<String> tokenGetir(String kime) async {
    DocumentSnapshot _token = await _firebaseDB.doc("tokens/" + kime).get();
    if (_token != null)
      return _token.data()["token"];
    else
      return null;
  }
}
