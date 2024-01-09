
import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';


class SignInPage extends StatefulWidget {
  @override
  _SignInPageState createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  late StreamSubscription<AuthState> authStateListener;


  @override
  void initState() {
    super.initState();
    authStateListener = Supabase.instance.client.auth.onAuthStateChange.listen((data) {
      if (data.event == AuthChangeEvent.signedIn) {
        Navigator.of(context).pushReplacementNamed('/home');
      }
      // Vous pouvez gérer d'autres événements d'authentification ici si nécessaire
    });
  }
  @override
  void dispose() {
    authStateListener.cancel();
    super.dispose();
  }




  Future<void> signInUser() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final response = await Supabase.instance.client.auth.signInWithPassword(email: _emailController.text.trim(), password: _passwordController.text.trim());
      if (response.user != null) {
        Navigator.of(context).pushReplacementNamed('/home');
      } else {
        // Handle the case where the user is not returned
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error.toString())));
    }


  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Sign In")),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            TextField(
              controller: _emailController,
              decoration: InputDecoration(labelText: "Email"),
            ),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(labelText: "Password"),
              obscureText: true,
            ),
            ElevatedButton(
              onPressed: signInUser,
              child: Text(_isLoading ? "Loading..." : "Sign In"),
            ),
            ElevatedButton(
                onPressed: signInWithGithub,
                child: Text('Sign in with GitHub')
            ),
            //... vos champs de texte et boutons pour la connexion ...
            TextButton(
              onPressed: () {
                Navigator.of(context).pushNamed('/signup');
              },
              child: Text("Pas de compte ? S'inscrire"),
            ),
          ],
        ),
      ),
    );
  }
  Future<void> signInWithGithub() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Déclenche la connexion OAuth avec GitHub.
      await Supabase.instance.client.auth.signInWithOAuth(
        OAuthProvider.github,
        redirectTo: kIsWeb ? null : 'gptoche://callback', // Utilisez votre schéma d'URL personnalisé ici
      );

      // Pas besoin d'un écouteur d'état d'authentification ici car il est déjà configuré dans initState.

    } catch (error) {
      // Affiche une erreur si la connexion échoue
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error.toString())));
      print(error.toString());
    } finally {
      // Réinitialise le flag de chargement
      setState(() {
        _isLoading = false;
      });
    }
  }



}
