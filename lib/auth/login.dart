import 'package:flutter/material.dart';
import 'package:my_app/auth/register.dart';
import 'package:my_app/layout/bottomnavbar.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:my_app/provider/user.dart';
import 'package:provider/provider.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool _passwordVisible = false;
  final _textControllerEmail = TextEditingController();
  final _textControllerPassword = TextEditingController();
  List listData = [];

  @override
  void initState() {
    super.initState();
    _getData();
    initialization();
  }

  void initialization() async {
    await Future.delayed(const Duration(seconds: 1));
    await Future.delayed(const Duration(seconds: 1));
    await Future.delayed(const Duration(seconds: 1));
    FlutterNativeSplash.remove();
  }

  _getData() async {
    final db = FirebaseFirestore.instance;
    await db.collection('users').get().then((value) {
      for (final data in value.docs) {
        listData.add({
          "email": data['email'],
          "user_id": data.id,
          "name": data['full_name'],
          "image": data['image_url'],
          "password": data['password'],
        });
      }
    });
  }

  _loginAction() async {
    final queryUser = listData
        .where((element) =>
            element['email'] == _textControllerEmail.text &&
            element['password'] == _textControllerPassword.text)
        .toList();
    if (queryUser.isNotEmpty) {
      for (final data in queryUser) {
        Provider.of<UserProvider>(context, listen: false).insertUserData(
            email: data['email'],
            user_id: data['user_id'],
            name: data['name'],
            image: data['image']);
      }
      return true;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
          gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFFFFD3D3), Color.fromRGBO(250, 180, 255, 100)])),
      child: Scaffold(
          backgroundColor: Colors.transparent,
          body: Padding(
            padding: const EdgeInsets.all(20.0),
            child: CustomScrollView(
              scrollDirection: Axis.vertical,
              slivers: [
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(height: 50),
                      Align(
                        alignment: Alignment.center,
                        child: Text(
                          'Login',
                          style: TextStyle(
                              fontSize: 30, fontWeight: FontWeight.bold),
                        ),
                      ),
                      SizedBox(height: 60),
                      TextField(
                        controller: _textControllerEmail,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.white,
                          labelText: "Email",
                          hintText: 'Email',
                          prefixIcon: Icon(Icons.person),
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
                      SizedBox(
                        height: 20,
                      ),
                      TextField(
                        controller: _textControllerPassword,
                        obscureText: !_passwordVisible,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.white,
                          labelText: "Password",
                          hintText: 'Password',
                          prefixIcon: Icon(Icons.key),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _passwordVisible
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                              color: Theme.of(context).primaryColorDark,
                            ),
                            onPressed: () {
                              setState(() {
                                _passwordVisible = !_passwordVisible;
                              });
                            },
                          ),
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
                      SizedBox(
                        height: 20,
                      ),
                      ElevatedButton(
                          onPressed: () async {
                            if (await _loginAction() && _textControllerEmail.text != "") {
                              Navigator.of(context).pushAndRemoveUntil(
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          NavigationBarPage()),
                                  (Route<dynamic> route) => false);
                            }
                          },
                          child: Text('Sign In')),
                      SizedBox(
                        height: 20,
                      ),
                      TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const RegisterPage()),
                            ).then((res) => _getData());
                          },
                          child: Text('Register'))
                    ],
                  ),
                ),
              ],
            ),
          )),
    );
  }
}
