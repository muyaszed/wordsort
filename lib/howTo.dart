import 'package:flutter/material.dart';
import 'package:word_sort/shared/button.dart';
import 'package:word_sort/shared/customCloseButton.dart';
import 'package:word_sort/shared/fullScreenOverlay.dart';

class HowTo extends StatelessWidget {
  const HowTo({
    Key? key,
    required this.handleCloseButton,
  }) : super(key: key);
  final void Function() handleCloseButton;

  @override
  Widget build(BuildContext context) {
    return FullScreenOverlay(
        backgroundColor: const Color.fromARGB(220, 11, 19, 43),
        child: Center(
            child: SizedBox(
          width: 768,
          child: Column(
            children: [
              Row(
                children: [
                  CustomCloseButton(
                    handleCloseButton: handleCloseButton,
                    size: 80,
                    color: const Color(0xff1c2541),
                    textColor: Colors.white,
                    textSize: 44,
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Text('HOW TO PLAY',
                      style: TextStyle(color: Colors.white, fontSize: 24)),
                ],
              ),
              const SizedBox(
                height: 30,
              ),
              SizedBox(
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Text('WordSort Instructions',
                          style: TextStyle(color: Colors.white, fontSize: 20)),
                      SizedBox(height: 30),
                      Text(
                        'Rearrange the letters according to the set of chosen words. The approach you take to solve the puzzle is up to you.',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                        ),
                        textAlign: TextAlign.justify,
                      ),
                      SizedBox(height: 10),
                      Text(
                        'The grid will contain 4 five letter words and 1 four letter word. The timer will start as soon as you perform your first move and there will also be a step counter.',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                        ),
                        textAlign: TextAlign.justify,
                      ),
                      SizedBox(height: 10),
                      Text(
                        'Once completed, you have the option to submit your score to the leaderboards to see how well you did.',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                        ),
                        textAlign: TextAlign.justify,
                      ),
                    ]),
              )
            ],
          ),
        )));
  }
}
