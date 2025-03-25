import 'dart:convert';
import 'package:http/http.dart' as http;

class MusicAPI {
  static const String apiKey =
      "3deffe7b1a1fc73b33cb8444751e6a43"; // Replace with your API Key
  static const String baseUrl = "http://ws.audioscrobbler.com/2.0/";

  // Function to get songs based on mood
  static Future<List<Map<String, String>>> getSongs(String mood) async {
    final url = Uri.parse(
      "$baseUrl?method=tag.getTopTracks&tag=$mood&api_key=$apiKey&format=json",
    );

    try {
      final response = await http.get(url);
      print("API Response: ${response.body}"); // Debugging Line

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['tracks'] == null || data['tracks']['track'] == null) {
          print("No tracks found for mood: $mood");
          return [];
        }
        final tracks = data['tracks']['track'] as List;
        return tracks.map((track) {
          return {
            "title": track['name'] as String,
            "artist": track['artist']['name'] as String
          };
        }).toList();
      } else {
        throw Exception("Failed to load songs");
      }
    } catch (e) {
      print("Error fetching songs: $e");
      return [];
    }
  }
}
