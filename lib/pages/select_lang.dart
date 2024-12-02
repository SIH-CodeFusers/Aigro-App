import 'package:aigro/local_db/db.dart';
import 'package:aigro/widgets/next_buttons.dart';
import 'package:aigro/widgets/voice_icon.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:hive/hive.dart';
import 'package:velocity_x/velocity_x.dart';

class SelectLang extends StatefulWidget {
  const SelectLang({super.key});

  @override
  State<SelectLang> createState() => _SelectLangState();
}

class _SelectLangState extends State<SelectLang> {
  //other language commneted for now
  final Map<String, String> languages = {
    "English": "en",
    "Hindi": "hi",
    "Bengali": "bn",
    "Telugu": "te",
  };

String? selectedLanguage;
  bool _isError = false;


  FlutterTts flutterTts = FlutterTts();

  _speak(String text) async {
    await flutterTts.awaitSpeakCompletion(true);

    await flutterTts.setLanguage("en-US");
    await flutterTts.setPitch(0.7);
    await flutterTts.speak(text);

    await flutterTts.setLanguage("hi-IN");
    await flutterTts.setPitch(0.7);
    await flutterTts.speak("अपनी भाषा का चयन करें");

    await flutterTts.setLanguage("bn-BD");
    await flutterTts.setPitch(0.7);
    await flutterTts.speak("আপনার ভাষা নির্বাচন করুন");
  }
  final languageBox = Hive.box("Language_db");
  LanguageDB ldb = LanguageDB();

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

  saveLang() {
    setState(() {
      ldb.language = selectedLanguage!;  
    });
    ldb.updateLang();
    Navigator.pushNamed(context, '/getStarted'); 
   }

// void checkSupportedLanguages() async {
//   List<dynamic> languages = await flutterTts.getLanguages;
//   for (var language in languages) {
//     print(language); // This will print the supported language codes
//   }
// }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.theme.canvasColor,
      body: LanguageSelect(context),
    );
  }

  Widget LanguageSelect(BuildContext context) {
    return Column(
      children: [
        const Spacer(),
        Center(
          child: Container(
            padding: const EdgeInsets.all(16),
            margin: const EdgeInsets.symmetric(horizontal: 20),
            decoration: BoxDecoration(
              color: context.theme.highlightColor,
              borderRadius: BorderRadius.circular(5),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 0),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            "Select your Language",
                            style: TextStyle(color: context.theme.primaryColorDark, fontSize: 22),
                          ),
                        ),
                      ),
                    ),
                     GestureDetector(
                      onTap: (){
                        _speak("Select your Language");
                      },
                      child: voiceIcon(context),
                    )
                  ],
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: context.theme.primaryColorDark,
                      width: 2.0,
                    ),
                  ),
                  child: DropdownButton<String>(
                    value: selectedLanguage,
                    hint: Text(
                      'Select a Language',
                      style: TextStyle(color: context.theme.primaryColorDark),
                    ),
                    isExpanded: true,
                   items: languages.entries.map((entry) {
                      return DropdownMenuItem<String>(
                        value: entry.value,
                        child: Text(entry.key, style: TextStyle(color: context.theme.primaryColorDark)),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        print(newValue);
                        selectedLanguage = newValue;
                      });
                    },
                    style: TextStyle(color: context.theme.primaryColorDark, fontSize: 18),
                    underline: Container(),
                    iconEnabledColor: context.theme.primaryColorDark,
                  ),
                ),
                const SizedBox(height: 20),
                if (_isError==true)
                const Padding(
                  padding: EdgeInsets.only(top: 8.0),
                  child: Text(
                    "Please select a language.",
                    style: TextStyle(color: Colors.red, fontSize: 14),
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded( 
                      child: GestureDetector(
                        onTap: () {
                            if (selectedLanguage!=null) {
                              setState(() {
                                _isError = false; 
                                saveLang();
                              });
                            } else {
                              setState(() {
                                _isError = true;  
                              });
                            }
                          },
                        child: NextButton(
                          text: "Proceed",
                          lang: ldb.language,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const Spacer(),
      ],
    );
  }
}