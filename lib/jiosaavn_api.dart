import 'dart:convert';
import 'package:http/http.dart' as http;

class JioSaavnAPI {
  static const String baseUrl = "https://saavn.dev/api/search/songs?query=";

  static Future<String?> getSongUrl(String songName) async {
    final url = Uri.parse("$baseUrl$songName");

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data["data"] != null && data["data"].isNotEmpty) {
          return data["data"][0]["downloadUrl"][0]["link"];
        }
      }
    } catch (e) {
      print("Error fetching song URL: $e");
    }
    return null;
  }
}
