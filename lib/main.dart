import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:iQuotes/auth/loginPage.dart';
import 'package:iQuotes/screens/MainBody.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'iQuotes',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.white),
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  late Widget screen;
  @override
  void initState() {
    super.initState();
    screen = checkIsLoggedin();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
    // home: MainBody(),
    //   home: LoginPage(),
      home: screen
    );
  }

  Widget checkIsLoggedin() {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null && user.uid.isNotEmpty) {
      return MainBody();
    } else {
      return LoginPage();
    }
  }
}
