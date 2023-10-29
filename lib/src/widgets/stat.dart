import 'package:animate_gradient/animate_gradient.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class Stat extends StatelessWidget {
  final double size;
  final double count;
  final String title;
  final Color titleColor;
  final bool isLeft;

  const Stat(
      {super.key,
      required this.size,
      required this.count,
      required this.title,
      required this.isLeft,
      this.titleColor = Colors.white});

  String format(double n) {
    NumberFormat format = NumberFormat("##0.##", 'de_DE');
    String formatted = format.format(n);
    if (formatted.length > 5) {
      formatted = format.format(n).substring(0, 5);
    }
    return formatted;
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        clipBehavior: Clip.hardEdge,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5.0),
          gradient: LinearGradient(
            colors: isLeft
                ? const [
                    Color.fromARGB(255, 9, 199, 72),
                    Color.fromARGB(255, 14, 91, 136)
                  ]
                : const [
                    Color.fromARGB(255, 14, 91, 136),
                    Color.fromARGB(255, 9, 199, 72)
                  ],
          ),
        ),
        child: AnimateGradient(
          primaryColors: isLeft
              ? const [
                  Color.fromARGB(255, 9, 199, 72),
                  Color.fromARGB(255, 14, 91, 136)
                ]
              : const [
                  Color.fromARGB(255, 14, 91, 136),
                  Color.fromARGB(255, 9, 199, 72)
                ],
          secondaryColors: isLeft
              ? const [
                  Color.fromARGB(255, 9, 199, 72),
                  Color.fromARGB(255, 14, 91, 136)
                ]
              : const [
                  Color.fromARGB(255, 14, 91, 136),
                  Color.fromARGB(255, 9, 199, 72)
                ],
          primaryBegin: Alignment.centerLeft,
          primaryEnd: Alignment.centerRight,
          secondaryBegin: Alignment.centerRight,
          secondaryEnd: Alignment.centerLeft,
          duration: const Duration(seconds: 7),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Text(
                format(count),
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 0.15 * MediaQuery.of(context).size.width,
                  fontWeight: FontWeight.w800,
                ),
              ),
              Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: titleColor,
                  fontSize: 0.06 * MediaQuery.of(context).size.width,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
