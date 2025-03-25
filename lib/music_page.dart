import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:audioplayers/audioplayers.dart';
import 'music_api.dart';

class MusicPage extends StatefulWidget {
  final String mood;
  const MusicPage({Key? key, required this.mood}) : super(key: key);

  @override
  _MusicPageState createState() => _MusicPageState();
}

class _MusicPageState extends State<MusicPage> {
  List<String> songs = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchSongs();
  }

  Future<void> fetchSongs() async {
    final results = await MusicAPI.getSongs(widget.mood);
    setState(() {
      songs = results;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Songs for ${widget.mood}")),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : songs.isEmpty
              ? Center(child: Text("No songs found for this mood."))
              : ListView.builder(
                  itemCount: songs.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text(songs[index]),
                    );
                  },
                ),
    );
  }
}
