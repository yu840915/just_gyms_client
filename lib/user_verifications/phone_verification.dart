import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:rxdart/subjects.dart';
import 'package:where_gym/api_services/api_services.dart';
import 'package:where_gym/app_bloc.dart';

class PhoneVerification {
  String _verificationId;
  final AppBloc appBloc;
  final _isPhoneVerified = BehaviorSubject<bool>();
  Stream<bool> get onPhoneVerified => _isPhoneVerified;
  String _lastPhoneNum;
  PhoneVerification(this.appBloc);

  Future<void> sendSMS(String phoneNum) async {
    assert(phoneNum != null);
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
          _onComplete(cred);
        },
        verificationFailed: (err) {
          _onFail(err, task);
        },
        codeSent: (id, token) {
          _onCodeSent(id, task, phoneNum, token);
        },
        codeAutoRetrievalTimeout: (id) {
          _onTimeout(id);
        });
    return task.future;
  }

  Future<void> resendSms() async {
    await sendSMS(_lastPhoneNum);
  }

  void _onComplete(PhoneAuthCredential cred) async {
    try {
      await _linkPhoneCredential(cred);
      _lastPhoneNum = null;
    } catch (e) {
      print(e);
    }
  }

  void _onFail(FirebaseAuthException error, Completer completer) {
    completer.completeError(error);
  }

  void _onCodeSent(String id, Completer completer, String phoneNum,
      [int forceResendingToken]) {
    _verificationId = id;
    _lastPhoneNum = phoneNum;
    completer.complete();
  }

  void _onTimeout(String id) {
    _verificationId = id;
  }

  Future<void> submitSmsCode(String code) async {
    if (_verificationId == null) {
      throw LocalError('請確認驗證碼已發送');
    }
    await _linkPhoneCredential(
      PhoneAuthProvider.credential(
        verificationId: _verificationId,
        smsCode: code,
      ),
    );
  }

  Future _linkPhoneCredential(AuthCredential credential) async {
    await appBloc.firebaseUser.linkWithCredential(credential);
    _isPhoneVerified.add(true);
  }
}
