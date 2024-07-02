import 'package:flutter/material.dart';
import 'package:percent_indicator/percent_indicator.dart';

class ProgressWheel extends StatelessWidget {
  final double percentage;

  ProgressWheel({required this.percentage});

  @override
  Widget build(BuildContext context) {
    return CircularPercentIndicator(
      radius: 100.0,
      lineWidth: 10.0,
      percent: percentage,
      center: new Text("${(percentage * 100).toInt()}%"),
      progressColor: Color(0xFF003B73),
    );
  }
}
