import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:my_app/provider/user.dart';
import 'package:provider/provider.dart';

class Settingpage extends StatefulWidget {
  const Settingpage({super.key});

  @override
  State<Settingpage> createState() => _SettingpageState();
}

class _SettingpageState extends State<Settingpage> {
  final _textFullName = TextEditingController();

  _updateProfile() {
    if (_textFullName.text.isNotEmpty) {
      final db = FirebaseFirestore.instance;
      final users = context.read<UserProvider>().users;
      db
          .collection('users')
          .doc(users['user_id'])
          .update({"full_name": _textFullName.text});
      Provider.of<UserProvider>(context, listen: false).editName(_textFullName.text);
      return true;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromRGBO(250, 180, 255, 100),
        title: const Text('Settings'),
      ),
        backgroundColor: const Color(0xFFFFD3D3),
        body: Align(
          alignment: Alignment.center,
          child: Container(
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: TextField(
                controller: _textFullName,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  labelText: "Full name",
                  hintText: 'Full name',
                  prefixIcon: Icon(Icons.person_add_alt),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide.none,
                    borderRadius: BorderRadius.circular(50.0),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide.none,
                    borderRadius: BorderRadius.circular(50.0),
                  ),
                ),
              ),
            ),
          ),
        ),
        floatingActionButton: FloatingActionButton(
          backgroundColor: const Color.fromRGBO(250, 180, 255, 100),
          onPressed: () async {
            if (await _updateProfile()) {
              Navigator.pop(context);
            }
          },
          child: Icon(Icons.edit_document),
        ));
  }
}
