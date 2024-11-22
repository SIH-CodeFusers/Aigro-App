import 'package:flutter/material.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class CoursesPlayer extends StatefulWidget {
  const CoursesPlayer({super.key, required this.coursetitle});

  final String coursetitle;
  @override
  State<CoursesPlayer> createState() => _CoursesPlayerState();
}

class _CoursesPlayerState extends State<CoursesPlayer> {
  int assessScore = 0;

  final Map<String, List<Map<String, String>>> courseData = {
    "Soil Health & Preparation": [
      {"title": "Understanding Soil Types", "url": "https://youtu.be/_dXGJooB0Qw?si=b_3A5WjhxXmeoRFe"},
      {"title": "Soil Classification Methods", "url": "https://youtu.be/ilmXUhsHaZg?si=FbZrWGqkB0pdb5PD"},
      {"title": "How to test soil", "url": "https://youtu.be/hDTwuO9PHp8?si=cMdSJ5unu3-w4RMZ"},
      {"title": "Soil Management Techniques", "url": "https://youtu.be/dtFS8s4gE54?si=xf8LUp1Tj9Gi-hwJ"},
    ],
    "Water Management Techniques": [
      {"title": "Water Management Techniques", "url": "https://youtu.be/_dXGJooB0Qw?si=b_3A5WjhxXmeoRFe"},
      {"title": "Soil Classification Methods", "url": "https://youtu.be/ilmXUhsHaZg?si=FbZrWGqkB0pdb5PD"},
      {"title": "How to test soil", "url": "https://youtu.be/hDTwuO9PHp8?si=cMdSJ5unu3-w4RMZ"},
      {"title": "Soil Management Techniques", "url": "https://youtu.be/dtFS8s4gE54?si=xf8LUp1Tj9Gi-hwJ"},
    ],
     "default": [
      {"title": "Default", "url": "https://youtu.be/_dXGJooB0Qw?si=b_3A5WjhxXmeoRFe"},
      {"title": "Soil Classification Methods", "url": "https://youtu.be/ilmXUhsHaZg?si=FbZrWGqkB0pdb5PD"},
      {"title": "How to test soil", "url": "https://youtu.be/hDTwuO9PHp8?si=cMdSJ5unu3-w4RMZ"},
      {"title": "Soil Management Techniques", "url": "https://youtu.be/dtFS8s4gE54?si=xf8LUp1Tj9Gi-hwJ"},
    ],
  };

  late List<Map<String, String>> currentCourse;
  late List<bool> checkedState;

  int videoNum = 0;
  late YoutubePlayerController _controller;

  String title = "";
  double perc = 0;

  @override
  void initState() {
    super.initState();

    currentCourse = courseData[widget.coursetitle] ?? courseData["default"]!;

    checkedState = List.generate(currentCourse.length, (index) => false);

    if (currentCourse.isNotEmpty) {
      title = currentCourse[videoNum]["title"]!;
      _controller = YoutubePlayerController(
        initialVideoId: _getVideoId(videoNum),
        flags: const YoutubePlayerFlags(
          autoPlay: false,
          mute: false,
          enableCaption: true,
          showLiveFullscreenButton: true,
        ),
      );
    }
  }

  void _loadVideo(int index) {
    videoNum = index;
    _controller.load(_getVideoId(videoNum));
    setState(() {
      title = currentCourse[videoNum]["title"]!;
    });
  }

  @override
  void dispose() {
    super.dispose();
    _controller.pause();
    _controller.dispose();
  }

  String _getVideoId(int index) {
    final url = currentCourse[index]["url"]!;
    return YoutubePlayer.convertUrlToId(url)!;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.theme.canvasColor,
      appBar: AppBar(
        title: Text(widget.coursetitle, style: TextStyle(fontSize: 22)),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              YoutubePlayer(controller: _controller),
              Padding(
                padding: EdgeInsets.all(20),
                child: Text(title, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: context.theme.primaryColorDark)),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                child: Text(
                  "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Fusce vitae dictum risus. Duis ut ornare risus, at pretium mauris.",
                  style: TextStyle(fontSize: 14, color: context.theme.splashColor),
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  "Completion : ${perc.round()} %",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: context.theme.primaryColorDark),
                ),
              ),
              SizedBox(height: 30),
              Container(
                height: 250,
                child: ListView.builder(
                  itemCount: currentCourse.length,
                  itemBuilder: (BuildContext context, int index) {
                    return GestureDetector(
                      onTap: () {
                        _loadVideo(index);
                      },
                      child: Container(
                        color: videoNum == index ? context.theme.focusColor : context.theme.highlightColor,
                        child: ListTile(
                          title: Text(currentCourse[index]["title"]!, style: TextStyle(color: context.theme.splashColor)),
                          trailing: Checkbox(
                            value: checkedState[index],
                            onChanged: (bool? value) {
                              setState(() {
                                checkedState[index] = value!;
                                perc = value ? perc + (100 / currentCourse.length) : perc - (100 / currentCourse.length);
                              });
                            },
                            activeColor: context.theme.cardColor,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
