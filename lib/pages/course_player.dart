import 'package:flutter/material.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';


class CoursesPlayer extends StatefulWidget {
  const CoursesPlayer({super.key, required this.coursetitle});

  final String coursetitle;
  @override
  State<CoursesPlayer> createState() => _CoursesPlayerState();
}

class _CoursesPlayerState extends State<CoursesPlayer> {
  
  int assessScore=0;
  List<String> items = [
    "Empowering Future Innovators",
    "AI for science students",
    "Transforming Lives Through AI Education For Science Students",
    "AI for Technology Students",
  ];

  final urls = [
    'https://youtu.be/aKW857bS67E?si=0NzASftqgbUkTIYB',
    'https://youtu.be/qczE92jDz4A?si=iWbGGHdYBLsvn2Ws',
    'https://youtu.be/MxbR7dsi0Ng?si=XWVjDoZmsn7ANZF4',
    'https://youtu.be/mWL8erVVr1k?si=0OhiXL7EeKWvyLax',
  ];


  late List<bool> checkedState;
  int videoNum = 0;
  late YoutubePlayerController _controller;
  String title = "";
  double perc = 0;

  @override
  void initState() {
    title = items[videoNum];
    super.initState();
    checkedState = List.generate(urls.length, (index) => assessScore > 0 ? (index != urls.length) : false);
    perc = assessScore > 0 ? assessScore >= 75 ? 100 : 80 : 0;

    _controller = YoutubePlayerController.fromVideoId(
     videoId: _getVideoId(videoNum),
      autoPlay: false,
      params: const YoutubePlayerParams(showFullscreenButton: true),
    );
  }

  @override
  void dispose() {
    _controller.close();
    super.dispose();
  }

  String _getVideoId(int index) {
    final url = urls[index];
    return YoutubePlayerController.convertUrlToId(url)!;
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.theme.canvasColor,
      appBar: AppBar(
      //   leading: IconButton(
      //       icon: Icon(Icons.arrow_back), 
      //       onPressed: () {
      //         dispose();
      //         Navigator.pushNamed(context, "/coursesTechno");     
      //       },
      // ),
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
                child: Text(title, style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold,color: context.theme.splashColor)),
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
                 
                  style: TextStyle(fontSize: 16,fontWeight: FontWeight.w500,color: context.theme.splashColor),
                ),
              ),
              SizedBox(height: 30,),
              Container(
                
                height: 250,
                child: ListView.builder(
                  itemCount: items.length,
                  itemBuilder: (BuildContext context, int index) {
                    return GestureDetector(
                      // onTap: (){
                      //   if(items[index]=="Assessment"){
                      //     // _controller.dispose();
                      //     dispose();
                      //     Navigator.push(
                      //       context,
                      //       MaterialPageRoute(builder: (context) =>  QuizPage(title: widget.coursetitle,)),
                      //     );
                      //   }            
                      //   videoNum = index;
                      //   _controller.load(_getVideoId(videoNum));
                      //   setState(() {
                      //     title=items[videoNum];
                      //   });            
                      // },
                      child: Container(
                        color:videoNum == index? context.theme.cardColor:context.theme.highlightColor,
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
                            activeColor: context.theme.focusColor,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),

              SizedBox(height: 20,),
              assessScore >= 75
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 40, right: 40, bottom: 20),
                    child: GestureDetector(
                      onTap: () {},
                      child: Container(
                        height: 70,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15),
                          color: context.theme.highlightColor,
                          border: Border.all(
                            color: context.theme.cardColor,
                            width: 2,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            "Download Certificate",
                            style: TextStyle(
                              color: context.theme.splashColor,
                              fontSize: 20,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                )
              : SizedBox.shrink(),

            ],
          ),
        ),
      ),
    );
  }
}