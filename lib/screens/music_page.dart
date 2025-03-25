import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:audioplayers/audioplayers.dart';

class MusicPage extends StatefulWidget {
  final String mood;
  const MusicPage({Key? key, required this.mood}) : super(key: key);

  @override
  _MusicPageState createState() => _MusicPageState();
}

class _MusicPageState extends State<MusicPage> {
  List<Map<String, String>> songs = []; // Ensuring correct type
  bool isLoading = true;
  final AudioPlayer _audioPlayer = AudioPlayer();
  String? currentPlayingUrl;

  @override
  void initState() {
    super.initState();
    fetchSongs(widget.mood);
  }

  Future<void> fetchSongs(String mood) async {
    final url = Uri.parse(
        'https://api.deezer.com/search?q=${Uri.encodeComponent(mood)}');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data.containsKey('data') && data['data'] is List) {
          final List<dynamic> tracks = data['data'];

          setState(() {
            songs = tracks.map((track) {
              return {
                'title': track['title']?.toString() ?? 'Unknown Title',
                'artist':
                    (track['artist']?['name']?.toString() ?? 'Unknown Artist'),
                'preview': track['preview']?.toString() ?? '',
              };
            }).toList();
            isLoading = false;
          });
        } else {
          print('No data found');
          setState(() => isLoading = false);
        }
      } else {
        print('Failed to fetch songs: ${response.statusCode}');
        setState(() => isLoading = false);
      }
    } catch (e) {
      print('Error fetching songs: $e');
      setState(() => isLoading = false);
    }
  }

  void playPreview(String url) async {
    if (currentPlayingUrl == url) {
      await _audioPlayer.stop();
      setState(() => currentPlayingUrl = null);
    } else {
      await _audioPlayer.stop();
      await _audioPlayer.play(UrlSource(url), mode: PlayerMode.lowLatency);
      setState(() => currentPlayingUrl = url);
    }
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Music for ${widget.mood}'),
        backgroundColor: Colors.blueAccent,
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : songs.isEmpty
              ? Center(child: Text('No songs found for this mood.'))
              : ListView.builder(
                  padding: EdgeInsets.all(10),
                  itemCount: songs.length,
                  itemBuilder: (context, index) {
                    final song = songs[index];
                    return Card(
                      elevation: 4,
                      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 10),
                      child: ListTile(
                        title: Text(song['title']!,
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text(song['artist']!),
                        trailing: song['preview']!.isNotEmpty
                            ? IconButton(
                                icon: Icon(
                                  currentPlayingUrl == song['preview']
                                      ? Icons.pause_circle
                                      : Icons.play_circle,
                                  size: 32,
                                  color: Colors.blueAccent,
                                ),
                                onPressed: () => playPreview(song['preview']!),
                              )
                            : Text('No Preview',
                                style: TextStyle(color: Colors.grey)),
                      ),
                    );
                  },
                ),
    );
  }
}
