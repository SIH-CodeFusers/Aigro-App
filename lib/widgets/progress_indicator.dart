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
    // int progressPercentage = ((questionInd + 1) / totalQuestions * 100).round();
    final double segmentWidth =
        MediaQuery.of(context).size.width / totalQuestions;
    // double progressValue = (questionInd + 1) / totalQuestions;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(height: 15),
        Center(
          child: Row(
            children: [
              SizedBox(width: 20),
              Expanded(
                child: Row(
                  children: [
                    Text(
                      "AI",
                      style: TextStyle(
                        color: context.theme.splashColor,
                        fontSize: 24,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      "gro",
                      style: TextStyle(
                        fontSize: 24,
                        foreground: Paint()
                          ..shader = LinearGradient(
                            colors: <Color>[context.theme.cardColor, context.theme.primaryColorDark,],
                          ).createShader(Rect.fromLTWH(0, 0, 200, 70)),
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
                      horizontal: 2), // Spacing between segments
                  decoration: BoxDecoration(
                    color: isActive ? context.theme.cardColor : Colors.grey[300],
                    borderRadius: BorderRadius.circular(
                        10), 
                  ),
                  height: 4,
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
