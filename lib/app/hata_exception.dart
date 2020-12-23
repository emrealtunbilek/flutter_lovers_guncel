class Hatalar {
  static String goster(String hataKodu) {
    switch (hataKodu) {
      case 'email-already-in-use':
        return "Bu mail adresi zaten kullanımda, lütfen farklı bir mail kullanınız";

      case 'user-not-found':
        return "Bu kullanıcı sistemde bulunmamaktadır. Lütfen önce kullanıcı oluşturunuz";

      case 'account-exists-with-different-credential':
        return "Facebook hesabınızdaki mail adresi daha önce gmail veya email yöntemi ile sisteme kaydedilmiştir. Lütfen bu mail adresi ile giriş yapın";
      case 'too-many-requests':
        return "Yavaş gırdın gırdın, az bekle sonra tekrar denersin";
      case 'wrong-password':
        return "Email veya şifre yanlış";
      default:
        return "Bir hata olustu";
    }
  }
}
