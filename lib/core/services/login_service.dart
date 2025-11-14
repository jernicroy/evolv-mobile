import 'package:evolv_mobile/core/dto/user_info_dto.dart';

class LoggedInUser {
  static UserDTO? _user;

  static UserDTO? get user => _user;

  static set user(UserDTO? user) {
    _user = user;
  }

  static bool get isLoggedIn => _user != null;

  static void logout() {
    _user = null;
  }
}