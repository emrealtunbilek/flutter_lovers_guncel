import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:flutter_lovers/services/storage_base.dart';

class FirebaseStorageService implements StorageBase {
  firebase_storage.FirebaseStorage storage = firebase_storage.FirebaseStorage.instance;
  firebase_storage.Reference _storageReference;

  @override
  Future<String> uploadFile(String userID, String fileType, File yuklenecekDosya) async {
    _storageReference = firebase_storage.FirebaseStorage.instance.ref().child(userID).child(fileType).child("profil_foto.png");

    firebase_storage.UploadTask uploadTask = _storageReference.putFile(yuklenecekDosya);

    firebase_storage.TaskSnapshot snapshot = await uploadTask;

    var url = await _storageReference.getDownloadURL();
    return url;
  }
}
