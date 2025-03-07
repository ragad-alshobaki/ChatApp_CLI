import 'package:flutter/material.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:chat_app_cli/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';

import 'package:chat_app_cli/screens/auth.dart';
import 'package:chat_app_cli/screens/chat.dart';
import 'package:chat_app_cli/screens/splash.dart';

void main() async{
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
      title: 'Flutter Demo',
      theme: ThemeData(

        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: StreamBuilder(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if(snapshot.connectionState == ConnectionState.waiting){
            return SplashScreen();     //or use circle progress indicator
          }
          if(snapshot.hasData){
            return const ChatScreen();
          }
          return AuthScreen();
        }
      )
    );
  }
}