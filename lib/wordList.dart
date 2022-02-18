import 'package:flutter/material.dart';

class WordList extends StatelessWidget {
  const WordList(
      {Key? key,
      required this.solutionCheck,
      required this.showList,
      required this.wordList,
      this.containerWidth})
      : super(key: key);
  final List<String> solutionCheck;
  final bool showList;
  final List<String> wordList;
  final double? containerWidth;

  @override
  Widget build(BuildContext context) {
    return showList
        ? Wrap(
            spacing: 20,
            direction: Axis.vertical,
            children: wordList.map((e) {
              TextStyle style;

              if (solutionCheck.contains(e)) {
                style = const TextStyle(color: Color(0xffffffff));
              } else {
                style =
                    const TextStyle(color: Color.fromARGB(255, 146, 212, 120));
              }

              return Container(
                alignment: Alignment.center,
                width: containerWidth ?? 150,
                child: Text(
                  e.toUpperCase(),
                  style: style,
                ),
              );
            }).toList(),
          )
        : const SizedBox();
  }
}
