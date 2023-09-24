import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class Stat extends StatelessWidget {
  final double size;
  final double count;
  final String title;
  final Color titleColor;
  const Stat(
      {super.key,
      required this.size,
      required this.count,
      required this.title,
      this.titleColor = Colors.white});

  static final format = NumberFormat.decimalPattern('de_DE');
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5.0),
          color: Colors.grey[800],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Text(
              format.format(count),
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
    );
  }
}
