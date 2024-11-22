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
  
  int assessScore=0;
  List<String> items = [
    "Understanding Soil Types",
    "Soil Classification Methods",
    "How to test soil",
    "Soil Management Techniques",
  ];

  final urls = [
    'https://youtu.be/_dXGJooB0Qw?si=b_3A5WjhxXmeoRFe',
    'https://youtu.be/ilmXUhsHaZg?si=FbZrWGqkB0pdb5PD',
    'https://youtu.be/hDTwuO9PHp8?si=cMdSJ5unu3-w4RMZ',
    'https://youtu.be/dtFS8s4gE54?si=xf8LUp1Tj9Gi-hwJ',
  ];


  late List<bool> checkedState;

    void initializeCheckedState() {
      checkedState = List.generate(
        urls.length,
        (index) => false,
      );
    }

  int videoNum = 0;
  late YoutubePlayerController _controller;

  String title="";
  double perc=0;

@override
void initState() {
  super.initState();
  
  initializeCheckedState();
  
  title = items[videoNum];
  perc = assessScore > 0 ? (assessScore >= 75 ? 100 : 80) : 0;

  _controller = YoutubePlayerController(
    initialVideoId: _getVideoId(videoNum),
    flags: const YoutubePlayerFlags(
      autoPlay: true,
      mute: false,
      enableCaption: true,
      showLiveFullscreenButton: true,
    ),
  );
}

void _loadVideo(int index) {
  videoNum = index;
  _controller.load(_getVideoId(videoNum));
  setState(() {
    title = items[videoNum];
  });
}


  @override
  void dispose() {
    super.dispose();
    _controller.pause();
    _controller.dispose();
  }

  String _getVideoId(int index) {
    final url = urls[index];
    return YoutubePlayer.convertUrlToId(url)!;
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.theme.canvasColor,
      appBar: AppBar(
        title: Text(widget.coursetitle,style: TextStyle(fontSize: 22),),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              YoutubePlayer(controller: _controller),
              Padding(
                padding: EdgeInsets.only(top: 20,left: 20,right: 20,bottom: 10),
                child: Text(title, style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold,color: context.theme.primaryColorDark)),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                child: Text(
                  "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Fusce vitae dictum risus. Duis ut ornare risus, at pretium mauris. Fusce.",
                  style: TextStyle(fontSize: 14,color: context.theme.splashColor),
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 0),
                child: Text(
                  "Completion : ${perc.round()} %", 
                  style: TextStyle(fontSize: 16,fontWeight: FontWeight.w500,color: context.theme.primaryColorDark),
                ),
              ),
              SizedBox(height: 30,),
              Container(
                
                height: 250,
                child: ListView.builder(
                  itemCount: items.length,
                  itemBuilder: (BuildContext context, int index) {
                    return GestureDetector(
                     onTap: () {
                          _loadVideo(index);          
                      },
                      child: Container(
                        color:videoNum == index? context.theme.focusColor:context.theme.highlightColor,
                        child: ListTile(
                          title: Text(items[index],style: TextStyle(color: context.theme.splashColor),),
                          trailing: Checkbox(
                            value: items[index]=="Assessment"?assessScore>=75?true :false:checkedState[index],
                            onChanged: (bool? value) {
                              
                              if(items[index]!="Assessment"){

                                setState(() {                           
                                    checkedState[index] = value!;
                                    if(value==true)
                                      perc=perc+ (100/items.length);
                                    else
                                      perc=perc- (100/items.length);                                       
                                });
                              }
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