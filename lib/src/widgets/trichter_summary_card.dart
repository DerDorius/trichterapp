import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:animate_gradient/animate_gradient.dart';

class TrichterSummaryCard extends StatelessWidget {
  final String titleText;
  final String trichterName;
  final String dauerText;
  final String maxDurchflussText;
  final String avgDurchflussText;
  final String mengeText;
  final String uuid;

  const TrichterSummaryCard({
    Key? key,
    required this.uuid,
    required this.titleText,
    required this.trichterName,
    required this.dauerText,
    required this.maxDurchflussText,
    required this.avgDurchflussText,
    required this.mengeText,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {},
      child: Container(
        clipBehavior: Clip.hardEdge,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16.0),
          /*   gradient: const LinearGradient(
            colors: [Color(0xFF4A148C), Color(0xFF880E4F)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ), */
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.5),
              spreadRadius: 3,
              blurRadius: 7,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: AnimateGradient(
          primaryBegin: Alignment.topLeft,
          primaryEnd: Alignment.bottomLeft,
          secondaryBegin: Alignment.bottomLeft,
          secondaryEnd: Alignment.topRight,
          duration: const Duration(seconds: 7),
          primaryColors: const [
            Color.fromARGB(255, 78, 2, 255),
            Color.fromARGB(255, 147, 0, 245),
            Color.fromARGB(248, 255, 0, 200),
          ],
          secondaryColors: const [
            Color.fromARGB(255, 4, 0, 240),
            Colors.blueAccent,
            Colors.blue,
          ],
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              splashFactory: InkRipple
                  .splashFactory, // Use the default InkRipple splash factory
              onTap: () {
                // Your onTap action here
                Navigator.restorablePushNamed(context, '/trichter_details',
                    arguments: uuid);
              },
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        RichText(
                          text: TextSpan(
                            style: const TextStyle(
                              fontSize: 15.0,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                            children: [
                              TextSpan(
                                text: titleText,
                              ),
                            ],
                          ),
                        ),
                        Hero(
                          tag: "${uuid}trichterName",
                          child: RichText(
                            text: TextSpan(
                              style: const TextStyle(
                                fontSize: 15.0,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                              children: [
                                TextSpan(
                                  text: trichterName,
                                  style: const TextStyle(
                                    fontSize: 22,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12.0),
                    GridView.count(
                      crossAxisCount: 2,
                      shrinkWrap: true,
                      childAspectRatio: 3.8,
                      physics: const BouncingScrollPhysics(),
                      children: [
                        _buildStatBox('Dauer:', dauerText),
                        _buildStatBox('Max Durchflussrate:', maxDurchflussText),
                        _buildStatBox('Avg Durchflussrate:', avgDurchflussText),
                        _buildStatBox('Menge getrichtert:', mengeText),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatBox(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12.0,
            color: Colors.white,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18.0,
            color: Colors.white,
          ),
        ),
      ],
    );
  }
}
