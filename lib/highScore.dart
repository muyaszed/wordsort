import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:word_sort/shared/fullScreenOverlay.dart';

class HighScore extends StatelessWidget {
  const HighScore({
    Key? key,
    required this.handleCloseButton,
    required this.smallScreen,
    required this.showTimeScore,
    required this.handleToggleScore,
    required this.animationController,
    required this.highScoreSteps,
    required this.highScoreTime,
  }) : super(key: key);
  final void Function() handleCloseButton;
  final void Function() handleToggleScore;
  final bool smallScreen;
  final bool showTimeScore;
  final AnimationController animationController;
  final CollectionReference highScoreSteps;
  final CollectionReference highScoreTime;

  @override
  Widget build(BuildContext context) {
    return FullScreenOverlay(
      backgroundColor: const Color.fromARGB(220, 11, 19, 43),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(40),
                    color: const Color(0xff1c2541),
                  ),
                  child: const Center(
                      child: Text(
                    'X',
                    style: TextStyle(color: Color(0xffffffff), fontSize: 44),
                  )),
                ),
              ),
            ],
          ),
          if (smallScreen)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 150,
                  height: 60,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        primary: const Color.fromARGB(255, 73, 102, 190)),
                    onPressed: handleToggleScore,
                    child: Text(showTimeScore ? 'STEPS' : 'TIME'),
                  ),
                ),
              ],
            ),
          if (smallScreen)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                    alignment: Alignment.center,
                    height: 60,
                    child: Text(showTimeScore ? 'TIME SCORE' : 'STEPS SCORE',
                        style: const TextStyle(
                            fontSize: 30, color: Color(0xffffffff)))),
              ],
            ),
          if (!smallScreen)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Container(
                    alignment: Alignment.center,
                    height: 60,
                    child: Text(showTimeScore ? 'TIME SCORE' : 'STEPS SCORE',
                        style: const TextStyle(
                            fontSize: 30, color: Color(0xffffffff)))),
                SizedBox(
                  width: 150,
                  height: 60,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        primary: const Color.fromARGB(255, 73, 102, 190)),
                    onPressed: handleToggleScore,
                    child: Text(showTimeScore ? 'STEPS' : 'TIME'),
                  ),
                ),
              ],
            ),
          const SizedBox(
            height: 50,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (!showTimeScore)
                FutureBuilder<QuerySnapshot>(
                  future: highScoreSteps.get(),
                  builder: (BuildContext context,
                      AsyncSnapshot<QuerySnapshot> snapshot) {
                    if (snapshot.hasError) {
                      return const Text("Something went wrong");
                    }

                    if (snapshot.connectionState == ConnectionState.done) {
                      var query = snapshot.data?.docs ?? [];
                      var data = List.generate(
                          query.length,
                          (index) => HighScoreSteps(query[index].get('name'),
                              query[index].get('steps')));
                      data.sort((a, b) => a.steps.compareTo(b.steps));

                      return Column(
                        children: List.generate(
                          snapshot.data?.docs.length ?? 0,
                          (index) => Container(
                            width: smallScreen ? 250 : 500,
                            color: const Color.fromARGB(255, 241, 204, 38),
                            alignment: Alignment.center,
                            child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  Container(
                                      alignment: Alignment.center,
                                      width: smallScreen ? 50 : 250,
                                      height: 60,
                                      child: Text(
                                        data[index].name,
                                        textAlign: TextAlign.center,
                                        style: const TextStyle(
                                          fontSize: 25,
                                        ),
                                      )),
                                  Container(
                                      alignment: Alignment.center,
                                      width: smallScreen ? 50 : 250,
                                      height: 60,
                                      child: Text(
                                        data[index].steps,
                                        textAlign: TextAlign.center,
                                        style: const TextStyle(
                                          fontSize: 25,
                                        ),
                                      )),
                                ]),
                          ),
                        ),
                      );
                    }

                    return CircularProgressIndicator(
                      value: animationController.value,
                      semanticsLabel: 'Linear progress indicator',
                    );
                  },
                ),
              if (showTimeScore)
                FutureBuilder<QuerySnapshot>(
                  future: highScoreTime.get(),
                  builder: (BuildContext context,
                      AsyncSnapshot<QuerySnapshot> snapshot) {
                    if (snapshot.hasError) {
                      return const Text("Something went wrong");
                    }

                    if (snapshot.connectionState == ConnectionState.done) {
                      var query = snapshot.data?.docs ?? [];
                      var data = List.generate(
                          query.length,
                          (index) => HighScoreTime(query[index].get('name'),
                              query[index].get('time')));
                      data.sort((a, b) => a.time.compareTo(b.time));
                      return Column(
                        children: List.generate(
                          snapshot.data?.docs.length ?? 0,
                          (index) => Container(
                            width: smallScreen ? 250 : 500,
                            color: const Color.fromARGB(255, 241, 204, 38),
                            alignment: Alignment.center,
                            child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  Container(
                                      alignment: Alignment.center,
                                      width: smallScreen ? 50 : 250,
                                      height: 60,
                                      child: Text(
                                        data[index].name,
                                        textAlign: TextAlign.center,
                                        style: const TextStyle(
                                          fontSize: 25,
                                        ),
                                      )),
                                  Container(
                                      alignment: Alignment.center,
                                      width: smallScreen ? 50 : 250,
                                      height: 60,
                                      child: Text(
                                        data[index].time,
                                        textAlign: TextAlign.center,
                                        style: const TextStyle(
                                          fontSize: 25,
                                        ),
                                      )),
                                ]),
                          ),
                        ),
                      );
                    }

                    return const Text("loading");
                  },
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class HighScoreTime {
  late String name;
  late String time;

  HighScoreTime(this.name, this.time);
}

class HighScoreSteps {
  late String name;
  late String steps;

  HighScoreSteps(this.name, this.steps);
}
