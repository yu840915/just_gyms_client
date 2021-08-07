import 'package:flutter/widgets.dart';
import 'package:where_gym/user_verifications/phone_verification_page.dart';

final Map<String, Widget Function(BuildContext)> namedRoutes = {
  RouteNames.phoneVerification: (context) => PhoneVerificationPage(),
};

class RouteNames {
  static final phoneVerification = '/phone-verify';
}
