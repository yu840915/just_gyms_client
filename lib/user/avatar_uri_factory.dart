import 'package:where_gym/api_services/api_services.dart';

class AvatarUriFactory {
  static Uri uriForUserId(String userId) {
    return APIServices.instances.makeServiceUri('/users/$userId/avatar');
  }
}
