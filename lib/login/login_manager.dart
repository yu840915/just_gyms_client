import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class LoginManager {
  static Future<UserCredential> signInWithFacebook() async {
    final AccessToken result = await FacebookAuth.instance.login();
    if (result == null) {
      return null;
    }
    final facebookAuthCredential =
        FacebookAuthProvider.credential(result.token);
    return await FirebaseAuth.instance
        .signInWithCredential(facebookAuthCredential);
  }

  static Future<UserCredential> signInWithGoogle() async {
    final GoogleSignInAccount googleUser = await GoogleSignIn().signIn();
    final GoogleSignInAuthentication googleAuth =
        await googleUser.authentication;
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );
    return await FirebaseAuth.instance.signInWithCredential(credential);
  }
}
