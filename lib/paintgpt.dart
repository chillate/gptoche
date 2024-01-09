import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:supabase_flutter/supabase_flutter.dart';

class PaintGPT extends StatefulWidget {
  @override
  _PaintGPTState createState() => _PaintGPTState();
}

class _PaintGPTState extends State<PaintGPT> {
  final TextEditingController _textController = TextEditingController();
  String _imageUrl = ''; // Pour stocker l'URL de l'image générée

  final SupabaseClient _supabaseClient = SupabaseClient(
      'https://mlwfbepdgdgysulfvage.supabase.co', // Votre URL Supabase
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im1sd2ZiZXBkZ2RneXN1bGZ2YWdlIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MDQ3MzQwODIsImV4cCI6MjAyMDMxMDA4Mn0.Gnz31kxuQxKw4z6w-Xs-YDJ-ldXJnukfKGMAmRQS-QY'
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('PaintGPT'),
      ),
      body: Column(
        children: <Widget>[
          Padding(
            padding: EdgeInsets.all(16.0),
            child: TextField(
              controller: _textController,
              decoration: InputDecoration(labelText: 'Entrez votre texte ici'),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              // Appeler l'API DALL·E pour générer l'image avec le prompt saisi par l'utilisateur
              generateImage(_textController.text);
              //generateImageDeepAI(_textController.text);
            },
            child: Text('Générer Image'),
          ),
          // Afficher l'image générée s'il y en a une
          if (_imageUrl.isNotEmpty)
            Image.network(_imageUrl),
        ],
      ),
    );
  }

  Future<void> generateImageDeepAI(String text) async {
    final String apiKey = '161b9885-8970-4262-abfd-4e97fa419dc4';

    try {
      final response = await http.post(
        Uri.parse('https://api.deepai.org/api/text2img'),
        headers: {
          'api-key': apiKey,
        },
        body: {
          'text': text,
        },
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        final imageUrl = responseData['output_url'];

        // Insérer le texte dans la table "history" de Supabase

        setState(() {
          _imageUrl = imageUrl; // Mettez à jour l'URL de l'image générée
        });
        await insertTextIntoHistory(text);
      } else {
        print('Erreur lors de la génération de l\'image: ${response
            .reasonPhrase}');
      }
    } catch (e) {
      print('Erreur lors de la requête HTTP: $e');
    }
  }

  Future<void> insertTextIntoHistory(String text) async {
    final response = await _supabaseClient
        .from('history')
        .insert({'text': text})
        .then((response) {
      if (response.error != null) {
        print('Erreur lors de l\'insertion dans Supabase: ${response.error!
            .message}');
      } else {
        print('Insertion réussie');
      }
    })
        .catchError((error) {
      print('Erreur lors de l\'insertion: $error');
    });
  }

  Future<void> generateImage(String text) async {
    final String apiKey = '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'; // Assurez-vous que c'est la clé API correcte
    await insertTextIntoHistory(text);
    try {
      // D'abord, on fait la requête pour générer l'image
      final response = await http.post(
        Uri.parse('https://api.openai.com/v1/images/generations'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $apiKey',
        },
        body: jsonEncode({
          'model': 'dall-e-3',
          // Vérifiez que c'est le bon modèle
          'prompt': text,
          // Utilisez directement text, pas besoin de variable intermédiaire
          'size': '1024x1024',
          'quality': 'standard',
          'n': 1,
        }),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        final imageUrl = responseData['data'][0]['url'];
        setState(() {
          _imageUrl = imageUrl; // Mettez à jour l'URL de l'image générée
        });

        // Ensuite, on insère le texte dans l'historique
      } else {
        print('Erreur lors de la génération de l\'image: ${response
            .reasonPhrase}');
        print('Détails de l\'erreur: ${response.body}');
      }
    } catch (e) {
      print('Erreur lors de la requête HTTP: $e');
    }
  }
}
