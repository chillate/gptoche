import 'package:flutter/material.dart';
import 'package:gptoche/paintgpt.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'signIn.dart';  // Assurez-vous que le chemin d'accès est correct
import 'signUp.dart';  // Assurez-vous que le chemin d'accès est correct

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
      url: 'https://mlwfbepdgdgysulfvage.supabase.co', // Votre URL Supabase
      anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im1sd2ZiZXBkZ2RneXN1bGZ2YWdlIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MDQ3MzQwODIsImV4cCI6MjAyMDMxMDA4Mn0.Gnz31kxuQxKw4z6w-Xs-YDJ-ldXJnukfKGMAmRQS-QY'
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'APP',
      initialRoute: '/',
      routes: {
        '/': (context) => SignInPage(),
        '/signup': (context) => SignUpPage(),
        '/home': (context) => PaintGPT(),
        '/signin': (context) => SignInPage(),


      },
    );
  }
}
