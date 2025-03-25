import 'package:flutter/material.dart';
import 'signin_page.dart';
import 'package:just_audio/just_audio.dart';

final AudioPlayer _audioPlayer = AudioPlayer();


void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(), // Dark theme for a premium look
      home: SignInPage(),
    );
  }
}
