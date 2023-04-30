import 'package:flutter/material.dart';

class UserProvider with ChangeNotifier {
  Map<dynamic, dynamic> _users = {};
  get users => _users;
  void insertUserData(
      {required String email,
      required String user_id,
      required String name,
      required String image}) {
    _users = {"email": email, "user_id": user_id, "name": name, "image": image};
    notifyListeners();
  }

  void editName(String name) {
    _users['name'] = name;
    notifyListeners();
  }
}
