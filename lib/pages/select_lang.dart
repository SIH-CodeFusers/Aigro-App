import 'package:aigro/widgets/next_buttons.dart';
import 'package:aigro/widgets/voice_icon.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:velocity_x/velocity_x.dart';

class SelectLang extends StatefulWidget {
  const SelectLang({super.key});

  @override
  State<SelectLang> createState() => _SelectLangState();
}

class _SelectLangState extends State<SelectLang> {
    final List<String> languages = [
    "English",
    "Hindi",
    "Bengali",
    "Telegu",
  ];

  FlutterTts flutterTts = FlutterTts();

  _speak(String text) async {
    await flutterTts.setLanguage("en-US"); 
    await flutterTts.setPitch(0.7); 
    await flutterTts.speak(text); 
  }

  String? selectedLanguage; 
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
                    items: languages.map((String language) {
                      return DropdownMenuItem<String>(
                        value: language,
                        child: Text(language, style: TextStyle(color: context.theme.primaryColorDark)),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        selectedLanguage = newValue;
                      });
                    },
                    style: TextStyle(color: context.theme.primaryColorDark, fontSize: 18),
                    underline: Container(),
                    iconEnabledColor: context.theme.primaryColorDark,
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          Navigator.pushNamed(context, '/getStarted');
                        },
                        child: NextButton(
                          text: "Proceed",
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