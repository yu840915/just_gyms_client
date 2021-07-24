import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:where_gym/api_services/api_services.dart';
import 'package:where_gym/app_bloc.dart';

class PhoneVerification {
  Future<void> sendSMS(String phoneNum) async {
    phoneNum = phoneNum.replaceAll(' ', '');
    if (phoneNum.length == 10 && phoneNum.startsWith('0')) {
      phoneNum = '+886${phoneNum.substring(1)}';
    } else {
      if (phoneNum.length != 13 || !phoneNum.startsWith('+886')) {
        throw LocalError('請確認電話格式是否正確');
      }
    }
    final task = Completer();
    FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: phoneNum,
        verificationCompleted: (cred) {
          _onComplete(cred, task);
        },
        verificationFailed: (err) {
          _onFail(err, task);
        },
        codeSent: (id, token) {
          _onCodeSent(id, token);
        },
        codeAutoRetrievalTimeout: (id) {
          _onTimeout(id, task);
        });
    return task;
  }

  void _onComplete(PhoneAuthCredential cred, Completer completer) {}

  void _onFail(FirebaseAuthException error, Completer completer) {}

  void _onCodeSent(String id, [int forceResendingToken]) {}

  void _onTimeout(String id, Completer completer) {}
}
