import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:my_app/auth/login.dart';
import 'package:my_app/auth/register.dart';
import 'package:my_app/layout/bottomnavbar.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:my_app/provider/user.dart';
import 'firebase_options.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => UserProvider()),
        ],
        child: MaterialApp(
            title: 'My-day-diary',
            theme: ThemeData(
              primarySwatch: Colors.deepPurple,
            ),
            home: const LoginPage()));
  }
}
