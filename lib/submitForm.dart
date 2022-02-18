import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:word_sort/shared/button.dart';
import 'package:word_sort/shared/customCloseButton.dart';
import 'package:word_sort/shared/fullScreenOverlay.dart';

class SubmitForm extends StatelessWidget {
  const SubmitForm({
    Key? key,
    required this.showEmptyError,
    required this.handleCloseButton,
    required this.nameTextController,
    required this.handleSendButton,
    required this.handleCloseError,
    // required this.context,
    // required this.highScoreSteps,
    // required this.highScoreTime,
  }) : super(key: key);
  final bool showEmptyError;
  final void Function() handleCloseButton;
  final void Function() handleCloseError;
  final TextEditingController nameTextController;
  final void Function() handleSendButton;
  // final BuildContext context;

  // final CollectionReference highScoreSteps;
  // final CollectionReference highScoreTime;

  @override
  Widget build(BuildContext context) {
    return FullScreenOverlay(
        backgroundColor: const Color.fromARGB(220, 11, 19, 43),
        child: Center(
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
                )
              ],
            ),
            if (showEmptyError)
              SizedBox(
                width: 300,
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      const Text(
                        "Name cannot be empty",
                        style: TextStyle(
                            fontSize: 20,
                            color: Color.fromARGB(255, 230, 74, 74)),
                      ),
                      CustomCloseButton(
                        handleCloseButton: handleCloseError,
                        size: 40,
                        color: Colors.white,
                        textColor: Colors.black,
                        textSize: 15,
                      )
                    ]),
              ),
            SimpleDialog(
              children: [
                Container(
                  alignment: Alignment.center,
                  padding: const EdgeInsets.only(left: 20, right: 20),
                  height: 60,
                  child: TextField(
                    style: const TextStyle(fontSize: 20),
                    controller: nameTextController,
                    decoration: const InputDecoration.collapsed(
                      hintText: 'Your Name',
                    ),
                  ),
                )
              ],
            ),
            Button(
                child: const Text(
                  "SEND",
                  style: TextStyle(color: Colors.white, fontSize: 24),
                ),
                handleButtonPressed: handleSendButton,
                width: 280,
                height: 80,
                color: const Color.fromARGB(255, 73, 102, 190)),
          ],
        )));
  }
}
