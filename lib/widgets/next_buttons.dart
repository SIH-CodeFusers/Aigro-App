import 'package:aigro/utils/translate.dart';
import 'package:flutter/material.dart';
import 'package:velocity_x/velocity_x.dart';

class NextButton extends StatelessWidget {
  final String text;
  final lang;

  const NextButton({super.key, required this.text,required this.lang});

  @override
  Widget build(BuildContext context) {
    Color borderColor;
    if (text == "Back") {
      borderColor = Colors.white;
    } else {
      borderColor = Colors.transparent;
    }
    return Container(
        height: 45,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: context.theme.primaryColorDark,
          border: Border.all(color: borderColor, width: 0.5),
        ),
        child: Center(
          child: Text(
            text,
            style: const TextStyle(color: Colors.white, fontSize: 17),
          ),
        ),
      );
    
  }

  FutureBuilder<String> translateHelper(String title, TextStyle style, String lang) {
    return FutureBuilder<String>(
      future: translateTextInput(title, lang),
      builder: (context, snapshot) {
        String displayText = snapshot.connectionState == ConnectionState.waiting || snapshot.hasError
            ? title
            : snapshot.data ?? title;

        return Text(displayText, style: style);
      },
    );
  }
}
