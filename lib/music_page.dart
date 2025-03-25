import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';
import 'lastfm_api.dart';

class MusicPage extends StatefulWidget {
  final String mood;
  const MusicPage({Key? key, required this.mood}) : super(key: key);

  @override
  _MusicPageState createState() => _MusicPageState();
}

class _MusicPageState extends State<MusicPage> {
  List<Map<String, String>> songs = []; // Fixed type issue
  bool isLoading = true;
  String? currentlyPlayingVideoId;
  YoutubePlayerController? _youtubeController;

  @override
  void initState() {
    super.initState();
    fetchSongs();
  }

  Future<void> fetchSongs() async {
    final results = await MusicAPI.getSongs(widget.mood);
    print("Fetched Songs: $results"); // Debugging output

    setState(() {
      songs = results; // Now correctly storing List<Map<String, String>>
      isLoading = false;
    });
  }

  Future<String?> fetchYouTubeVideoId(String query) async {
    final yt = YoutubeExplode();
    try {
      final searchResults = await yt.search.getVideos(query);
      return searchResults.isNotEmpty ? searchResults.first.id.value : null;
    } catch (e) {
      print("Error fetching YouTube video ID: $e");
      return null;
    } finally {
      yt.close();
    }
  }

  void playSong(String songTitle) async {
    String? videoId = await fetchYouTubeVideoId(songTitle);
    if (videoId != null) {
      setState(() {
        currentlyPlayingVideoId = videoId;
        _youtubeController?.dispose();
        _youtubeController = YoutubePlayerController(
          initialVideoId: videoId,
          flags: YoutubePlayerFlags(autoPlay: true, mute: false),
        );
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Could not find a YouTube video for this song")),
      );
    }
  }

  @override
  void dispose() {
    _youtubeController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Songs for ${widget.mood}")),
      body: Column(
        children: [
          if (currentlyPlayingVideoId != null && _youtubeController != null)
            YoutubePlayer(controller: _youtubeController!),
          Expanded(
            child: isLoading
                ? Center(child: CircularProgressIndicator())
                : songs.isEmpty
                    ? Center(child: Text("No songs found for this mood."))
                    : ListView.builder(
                        itemCount: songs.length,
                        itemBuilder: (context, index) {
                          final songTitle =
                              songs[index]["title"] ?? "Unknown Title";
                          return ListTile(
                            title: Text(songTitle),
                            trailing: IconButton(
                              icon: Icon(Icons.play_arrow),
                              onPressed: () => playSong(songTitle),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}
