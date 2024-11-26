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
      {"title": "Irrigation Methods", "url": "https://youtu.be/jDXGPw0VP6A?si=_BUht4Z59C_JJ25X"},
      {"title": "Water Conservation Practices", "url": "https://youtu.be/1H7cABbXJ74?si=y76RLLg3M4xV9Ka3"},
      {"title": "Sustainable Water Use", "url": "https://youtu.be/kngMC8AIRBI?si=L6VS_Zr-EAE-SSAC"},
      {"title": "Introduction to Drip Irrigation", "url": "https://youtu.be/4ucbtnYIgjo?si=gAdhOQ9Y0pVtjiq7"},
      {"title": "Setting Up Drip Irrigation Systems", "url": "https://youtu.be/05Ll3LuHZAs?si=O8Fpp5WZor6zkbuw"},
    ],
    "Crop-Specific Courses": [
      {"title": "Growing Rice: A Beginner's Guide", "url": "https://youtu.be/FW_bw9jdrlQ?si=FIT4sAFQdPgoTdhP"},
      {"title": "Corn Planting and Harvesting", "url": "https://youtu.be/UzLZ8jbZF4s?si=VAicBi1w5wPQluCq"},
      {"title": "How to Grow Tomatoes", "url": "https://youtu.be/TGmYy7P80V8?si=WRma0Tvc3iHaLLa-"},
      {"title": "Banana Farming Basics", "url": "https://youtu.be/bnRRrdW7gU0?si=LeVNGwfo3fgnip-5"},
      {"title": "Mango Farming Basics", "url": "https://youtu.be/5sPn2FidZZw?si=AL9Mogo3ZGYYaXP-"},
      {"title": "Starting a Tea Plantation", "url": "https://youtu.be/cjxX8NpS0No?si=6z1Odlo8qjVcFfbG"},
    ],
    "Sustainable & Organic Farming": [
      {"title": "Introduction to Organic Farming", "url": "https://youtu.be/wougJaN_Ha0?si=1X8gtn1rWm_r-yoB"},
      {"title": "Principles of Organic Agriculture", "url": "https://youtu.be/_RAzW23-kDA?si=USo7GwxSnatl08YR"},
      {"title": "Composting for Sustainable Farming", "url": "https://youtu.be/1iEpSHQg9rk?si=wG1O5jUEMV7S8DaL"},
      {"title": "How to Make Organic Compost", "url": "https://youtu.be/mDIVpJgjoXQ?si=MeyDdNhbqSoZkIJ6"},
    ],
    "Livestock Management": [
      {"title": "Starting a Livestock Farm", "url": "https://youtu.be/YP_5owNtFuM?si=-fawsLqp9eXTv4ke"},
      {"title": "Care and Management of Livestock", "url": "https://youtu.be/MBAlx3MExgM?si=i1eVDwSS7tCFVOU7"},
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
        title: Text(widget.coursetitle, style: const TextStyle(fontSize: 22)),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              YoutubePlayer(controller: _controller),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Text(title, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: context.theme.primaryColorDark)),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                child: Text(
                  "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Fusce vitae dictum risus. Duis ut ornare risus, at pretium mauris.",
                  style: TextStyle(fontSize: 14, color: context.theme.splashColor),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  "Completion : ${perc.round()} %",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: context.theme.primaryColorDark),
                ),
              ),
              const SizedBox(height: 30),
              SizedBox(
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
