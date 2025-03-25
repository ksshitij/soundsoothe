import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:soundsoothe/screens/music_page.dart'; // Import the music page

class MoodInputPage extends StatefulWidget {
  @override
  _MoodInputPageState createState() => _MoodInputPageState();
}

class _MoodInputPageState extends State<MoodInputPage> {
  late VideoPlayerController _controller;

  final List<Map<String, String>> moods = [
    {"name": "Happy", "image": "assets/images/happy.jpg"},
    {"name": "Sad", "image": "assets/images/sad.jpeg"},
    {"name": "Stressed", "image": "assets/images/stressed.jpeg"},
    {"name": "Excited", "image": "assets/images/excited.jpeg"},
    {"name": "Angry", "image": "assets/images/angry.jpeg"},
    {"name": "Relaxed", "image": "assets/images/relaxed.jpeg"},
    {"name": "Headache", "image": "assets/images/headache.jpeg"},
    {"name": "Anxiety", "image": "assets/images/anxiety.jpeg"},
    {"name": "Insomnia", "image": "assets/images/insomnia.jpeg"},
    {"name": "Fatigue", "image": "assets/images/fatigue.jpeg"},
    {"name": "Depression", "image": "assets/images/depression.jpeg"},
    {"name": "Pain", "image": "assets/images/pain.jpeg"},
  ];

  String? selectedMood;

  @override
  void initState() {
    super.initState();
    _controller =
        VideoPlayerController.asset("assets/videos/mood_background.mp4")
          ..initialize().then((_) {
            setState(() {}); // Ensure UI rebuilds after video is ready
            _controller.setLooping(true);
            _controller.play();
          });
  }

  @override
  void dispose() {
    _controller.dispose(); // Free resources
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background Video
          Positioned.fill(
            child: _controller.value.isInitialized
                ? FittedBox(
                    fit: BoxFit.cover,
                    child: SizedBox(
                      width: _controller.value.size.width,
                      height: _controller.value.size.height,
                      child: VideoPlayer(_controller),
                    ),
                  )
                : Container(
                    color: Colors.black), // Fallback if video isn't loaded
          ),

          // UI Content
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Title
                Text(
                  "How are you feeling today?",
                  style: GoogleFonts.poppins(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 20),

                // Scrollable Mood Grid
                Expanded(
                  child: GridView.builder(
                    padding: EdgeInsets.symmetric(vertical: 10),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2, // 2 cards per row
                      crossAxisSpacing: 15,
                      mainAxisSpacing: 15,
                      childAspectRatio: 1.2,
                    ),
                    itemCount: moods.length,
                    itemBuilder: (context, index) {
                      String mood = moods[index]["name"]!;
                      String image = moods[index]["image"]!;

                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            selectedMood = mood;
                          });
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: selectedMood == mood
                                ? Colors.blueAccent
                                : Colors.black.withOpacity(0.6),
                            borderRadius: BorderRadius.circular(15),
                            border: Border.all(color: Colors.white30),
                          ),
                          child: Stack(
                            children: [
                              // Mood Image
                              Positioned.fill(
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(15),
                                  child: Image.asset(
                                    image,
                                    fit: BoxFit.cover,
                                    color: selectedMood == mood
                                        ? Colors.black.withOpacity(0.3)
                                        : null,
                                    colorBlendMode: BlendMode.darken,
                                  ),
                                ),
                              ),

                              // Mood Name
                              Center(
                                child: Text(
                                  mood,
                                  style: GoogleFonts.poppins(
                                    fontSize: 18,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),

                              // Checkmark when selected
                              if (selectedMood == mood)
                                Positioned(
                                  top: 8,
                                  right: 8,
                                  child: Icon(Icons.check_circle,
                                      color: Colors.white, size: 28),
                                ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),

                // Continue Button (Navigates to Music Page)
                if (selectedMood != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 20),
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => MusicPage(
                                mood: selectedMood!), // Fixed parameter name
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueAccent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding:
                            EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                      ),
                      child: Text("Continue",
                          style: GoogleFonts.poppins(
                              fontSize: 18, fontWeight: FontWeight.w600)),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
