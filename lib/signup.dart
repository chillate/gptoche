import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SignUpPage extends StatefulWidget {
  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Sign Up")),
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
              onPressed: _isLoading ? null : () => signUpUser(),
              child: Text(_isLoading ? "Loading..." : "Sign Up"),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> signUpUser() async {
    setState(() {
      _isLoading = true;
    });

    final String email = _emailController.text.trim();
    final String password = _passwordController.text.trim();

    // Vérifier la longueur du mot de passe
    if (password.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Le mot de passe doit contenir au moins 6 caractères.")));
      setState(() => _isLoading = false);
      return;
    }

    try {
      // Tentative d'inscription avec Supabase
      final response = await Supabase.instance.client.auth.signUp(email: email, password: password);

      if (response.user != null) {
        Navigator.of(context).pushReplacementNamed('/signin');
        print(1);
      } else {
        throw Exception("Une erreur est survenue lors de l'inscription.");
      }
    } catch (error) {
      print(2);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error.toString())));
      print(error.toString());
    }

    setState(() {
      _isLoading = false;
    });
  }
}
