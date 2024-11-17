import 'package:flutter/material.dart';
import 'package:velocity_x/velocity_x.dart';

class ProgressIndicatorWidget extends StatelessWidget {
  final int questionInd;
  final int totalQuestions;
  final VoidCallback onBackButtonPressed;

  const ProgressIndicatorWidget({
    Key? key,
    required this.questionInd,
    required this.totalQuestions,
    required this.onBackButtonPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    int progressPercentage = ((questionInd + 1) / totalQuestions * 100).round();
    final double segmentWidth =
        MediaQuery.of(context).size.width / totalQuestions;
    double progressValue = (questionInd + 1) / totalQuestions;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(height: 15),
        Center(
          child: Row(
            children: [
              SizedBox(width: 20),
              Image.asset(
                //top image
                "assets/images/tbailogo.png",

                fit: BoxFit.contain,
                height: 23,
                width: 23,
              ),
              SizedBox(width: 10),
              Expanded(
                child: Row(
                  children: [
                    Text(
                      "Techno",
                      style: TextStyle(
                        color: context.theme.splashColor,
                        fontSize: 21,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      "Billion",
                      style: TextStyle(
                        // color: context.theme.splashColor,
                        fontStyle: FontStyle.italic,
                        fontSize: 21,
                        foreground: Paint()
                          ..shader = LinearGradient(
                            colors: <Color>[Colors.yellow, Colors.red],
                          ).createShader(Rect.fromLTWH(0, 0, 200, 70)),
                      ),
                    ),
                    Text(
                      " AI",
                      style: TextStyle(
                        color: context.theme.splashColor,
                        fontSize: 21,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 15),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 15),
          child: Row(
            children: List.generate(totalQuestions, (index) {
              bool isActive = index <= questionInd;
              return Expanded(
                child: Container(
                  margin: EdgeInsets.symmetric(
                      horizontal: 4), // Spacing between segments
                  decoration: BoxDecoration(
                    color: isActive ? Colors.white : Colors.grey[800],
                    borderRadius: BorderRadius.circular(
                        10), // Adjust the radius for rounded corners
                  ),
                  height: 4, // Adjust height as needed
                  width: segmentWidth,
                ),
              );
            }),
          ),
        )
      ],
    );
  }
}
