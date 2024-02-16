// import 'package:flutter/material.dart';
import 'package:flutter/material.dart';
import 'package:modernlogintute/pages/add_task.dart';
import 'package:modernlogintute/pages/auth_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:modernlogintute/pages/shared_task.dart';
import 'package:modernlogintute/pages/home_page.dart';
import 'package:modernlogintute/pages/login_page.dart';
import 'package:modernlogintute/pages/register.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: AuthPage(),
      routes : {
        '/home' : (context) => HomePage(),
        '/login': (context) => LoginPage(),
        '/register':(context) => RegisterPage(),
        '/sharedtasks' : (context) => CompletedTasks(),
        '/addtask' : (context) => AddTaskDialog(),
      }
    );
  }
}
