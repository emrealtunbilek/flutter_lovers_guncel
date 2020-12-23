import 'package:flutter_lovers/model/user.dart';
import 'package:flutter_lovers/services/auth_base.dart';

class FakeAuthenticationService implements AuthBase {
  String userID = "123123123123123213123123123";

  @override
  Future<MyUser> getCurrentUser() async {
    return await Future.value(MyUser(userID: userID, email: "fakeuser@fake.com"));
  }

  @override
  Future<bool> signOut() {
    return Future.value(true);
  }

  @override
  Future<MyUser> singInAnonymously() async {
    return await Future.delayed(Duration(seconds: 2), () => MyUser(userID: userID, email: "fakeuser@fake.com"));
  }

  @override
  Future<MyUser> signInWithGoogle() async {
    return await Future.delayed(Duration(seconds: 2), () => MyUser(userID: "google_user_id_123456", email: "fakeuser@fake.com"));
  }

  @override
  Future<MyUser> signInWithFacebook() async {
    return await Future.delayed(Duration(seconds: 2), () => MyUser(userID: "facebook_user_id_123456", email: "fakeuser@fake.com"));
  }

  @override
  Future<MyUser> createUserWithEmailandPassword(String email, String sifre) async {
    return await Future.delayed(Duration(seconds: 2), () => MyUser(userID: "created_user_id_123456", email: "fakeuser@fake.com"));
  }

  @override
  Future<MyUser> signInWithEmailandPassword(String email, String sifre) async {
    return await Future.delayed(Duration(seconds: 2), () => MyUser(userID: "signIn_user_id_123456", email: "fakeuser@fake.com"));
  }
}
