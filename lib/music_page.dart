import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:audioplayers/audioplayers.dart';
import 'lastfm_api.dart';

class MusicPage extends StatefulWidget {
  final String mood;
  const MusicPage({Key? key, required this.mood}) : super(key: key);

  @override
  _MusicPageState createState() => _MusicPageState();
}

class _MusicPageState extends State<MusicPage> {
  List<Map<String, String>> songs = [];
  bool isLoading = true;
  final AudioPlayer _audioPlayer = AudioPlayer();
  String? currentlyPlayingUrl;

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

  Future<String?> fetchSongUrl(String title, String artist) async {
    final encodedTitle = Uri.encodeComponent(title);
    final encodedArtist = Uri.encodeComponent(artist);
    final url = Uri.parse(
        "https://saavn.dev/api/search/songs?query=$encodedTitle $encodedArtist");

    try {
      final response = await http.get(url);
      print("JioSaavn API Response: ${response.body}"); // 🔍 Debugging line

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data["data"].isNotEmpty) {
          return data["data"][0]["downloadUrl"][0]["url"]; // ✅ Correct URL
        }
      }
    } catch (e) {
      print("Error fetching song URL: $e");
    }
    return null;
  }

  void playSong(String title, String artist) async {
    String? songUrl = await fetchSongUrl(title, artist);
    if (songUrl != null) {
      print("Playing song: $songUrl"); // 🔍 Debugging line
      await _audioPlayer.play(UrlSource(songUrl));
      setState(() {
        currentlyPlayingUrl = songUrl;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Song not available")),
      );
    }
  }

  void stopSong() {
    _audioPlayer.stop();
    setState(() {
      currentlyPlayingUrl = null;
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
                    final song = songs[index];
                    return ListTile(
                      title: Text(song["title"]!),
                      subtitle: Text(song["artist"]!),
                      trailing: IconButton(
                        icon: Icon(
                          currentlyPlayingUrl == song["title"]
                              ? Icons.pause
                              : Icons.play_arrow,
                        ),
                        onPressed: () {
                          if (currentlyPlayingUrl == song["title"]) {
                            stopSong();
                          } else {
                            playSong(song["title"]!, song["artist"]!);
                          }
                        },
                      ),
                    );
                  },
                ),
    );
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }
}
