import 'package:aigro/local_db/db.dart';
import 'package:aigro/widgets/voice_icon.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:aigro/widgets/circle_painter.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:hive/hive.dart';
import 'package:velocity_x/velocity_x.dart';


class GetStarted extends StatefulWidget {
  const GetStarted({super.key});

  @override
  State<GetStarted> createState() => _GetStartedState();
}

class _GetStartedState extends State<GetStarted> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    if(languageBox.get("LANG") == null){
      ldb.createLang();
    }
    else{
      ldb.loadLang();
    }
  }
  final languageBox = Hive.box("Language_db");
  LanguageDB ldb = LanguageDB();
  FlutterTts flutterTts = FlutterTts();
  _speak(String text) async {
    await flutterTts.setLanguage(ldb.language); 
    await flutterTts.setPitch(0.7); 
    await flutterTts.speak(text); 
  }
  @override
  Widget build(BuildContext context) {
    return  Scaffold(
    
    backgroundColor: context.theme.canvasColor,

      body: Stack(
        children: [
          Positioned.fill(
              child: CustomPaint(
                painter: ScatteredBallsPainter(),
              ),
            ),
          SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                  const SizedBox(height: 60,),
                   Center(
                      child: ClipOval(
                        child: Container(
                          decoration: const BoxDecoration(
                            color:  Color.fromRGBO(255, 204, 187,1)
                          ),
                          padding: const EdgeInsets.all(15),
                          child: ClipOval(
                            child: Image.asset(
                              "assets/images/get_started.png",
                              width: MediaQuery.of(context).size.width*0.75,
                              height: MediaQuery.of(context).size.width*0.75,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const Spacer(),
                                    
                     const Center(
                       child: Text(
                          "Cultivating Crops for a",
                          style: TextStyle(fontSize: 28,fontFamily: 'FontMain',letterSpacing: 1,inherit: false,color: Colors.black, ),
                        ),
                     ),
                      Center(
                        child: Text.rich(
                          TextSpan(
                            children: [
                              TextSpan(
                                text: "greener ",
                                style: TextStyle(
                                  fontSize: 28,
                                  fontFamily: 'FontMain',
                                  letterSpacing: 1,
                                  fontWeight: FontWeight.w600,
                                  color: context.theme.cardColor, 
                                  inherit: false,
                                ),
                              ),
                              const TextSpan(
                                text: "tommorow",
                                style: TextStyle(
                                  fontSize: 28,
                                  fontFamily: 'FontMain',
                                  letterSpacing: 1,
                                  inherit: false,
                                  color: Colors.black, 
                                ),
                              ),
                            ],
                          ),
                        )
                    ),
                           
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20,vertical: 15),
                      child: Container(
                        decoration: const BoxDecoration(
                          color: Colors.transparent
                        ),
                        child: Text(
                          textAlign: TextAlign.center,
                          "Empowering farmers for optimal and better outcomes.",
                          style: TextStyle(
                            fontSize: 16, 
                            color: context.theme.splashColor,
                            fontFamily: 'FontMain',
                            height: 1.5,
                            wordSpacing: 2.0,
                            inherit: false,
                          ),
                        ),
                      ),      
                    ),
                    
                   GestureDetector(
                      onTap: (){
                        _speak("Cultivating Crops for a greener tommorow. Empowering farmers for optimal and better outcomes.");
                      },
                      child: voiceIcon(context),
                    ),
                    
                
                    const SizedBox(height: 20,),
                
                    GestureDetector(
                      onTap: (){
                        Navigator.pushNamed(context, '/onboarding');
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 40),
                        child: Container(
                          width: double.infinity,
                          height:60,
                          decoration: BoxDecoration(
                            color: context.theme.cardColor,
                            borderRadius: BorderRadius.circular(40)
                          ),
                          child: Center(child: Text("Get Started",
                            style: TextStyle(color: context.theme.canvasColor,fontSize: 20,inherit: false,),
                          )),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20,)
                  ],
                ),
              ),
              
            ),
        ],
      ),
      );
    
  }
}


