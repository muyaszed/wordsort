import "dart:math";
import 'package:flutter/material.dart';
import '../models/neighbour.dart';
import '../models/tile.dart';
import '../models/box.dart';
import '../constants/words.dart';
import '../constants/box.dart';

generateWordList() {
  List<String> wordList = [];
  while (wordList.length < 5) {
    final _random = Random();
    var fiveWord = fiveLetters[_random.nextInt(fiveLetters.length)];
    var fourWord = fourLetters[_random.nextInt(fourLetters.length)];

    if (!wordList.contains(fiveWord)) {
      wordList.add(fiveWord);
    }

    if (wordList.length == 4) {
      wordList.add(fourWord);
    }
  }

  return wordList;
}

List<Box> generateBoxProperties() {
  var wordList = generateWordList();
  print([wordList[0], wordList[1], wordList[2], wordList[3], wordList[4]]);

  var splitWord1 = wordList[0].split('');
  var splitWord2 = wordList[1].split('');
  var splitWord3 = wordList[2].split('');
  var splitWord4 = wordList[3].split('');
  var splitWord5 = wordList[4].split('');

  splitWord1.shuffle();
  splitWord2.shuffle();
  splitWord3.shuffle();
  splitWord4.shuffle();
  splitWord5.shuffle();

  List<String> allLetters = [
    ...splitWord5,
    ...splitWord2,
    ...splitWord1,
    ...splitWord3,
    ...splitWord4,
  ];

  allLetters.shuffle();
  allLetters.add('');

  createNeighbour(index, x, y) {
    Neighbour neighbour = Neighbour(null, null, null, null);

    if (index == 0) {
      neighbour = Neighbour(
        null,
        TileCoordinate(x, y + 1),
        TileCoordinate(x + 1, y),
        null,
      );
    }

    if (index == 4) {
      neighbour = Neighbour(
        TileCoordinate(x, y - 1),
        null,
        TileCoordinate(x + 1, y),
        null,
      );
    }

    if (index > 0 && index < 4) {
      neighbour = Neighbour(
        TileCoordinate(x, y - 1),
        TileCoordinate(x, y + 1),
        TileCoordinate(x + 1, y),
        null,
      );
    }

    if (index == 20) {
      neighbour = Neighbour(
        null,
        TileCoordinate(x, y + 1),
        null,
        TileCoordinate(x - 1, y),
      );
    }

    if (index == 5 || index == 10 || index == 15) {
      neighbour = Neighbour(
        null,
        TileCoordinate(x, y + 1),
        TileCoordinate(x + 1, y),
        TileCoordinate(x - 1, y),
      );
    }

    if (index == 24) {
      neighbour = Neighbour(
        TileCoordinate(x, y - 1),
        null,
        null,
        TileCoordinate(x - 1, y),
      );
    }

    if (index == 21 || index == 22 || index == 23) {
      neighbour = Neighbour(
        TileCoordinate(x, y - 1),
        TileCoordinate(x, y + 1),
        null,
        TileCoordinate(x - 1, y),
      );
    }

    if (index == 9 || index == 14 || index == 19) {
      neighbour = Neighbour(
        TileCoordinate(x, y - 1),
        null,
        TileCoordinate(x + 1, y),
        TileCoordinate(x - 1, y),
      );
    }

    if (index > 5 && index < 9 ||
        index > 10 && index < 14 ||
        index > 15 && index < 19) {
      neighbour = Neighbour(
        TileCoordinate(x, y - 1),
        TileCoordinate(x, y + 1),
        TileCoordinate(x + 1, y),
        TileCoordinate(x - 1, y),
      );
    }

    return neighbour;
  }

  createBox(int index, String letter) {
    double posX = (tileWidth + tileGap) * (index % 5);
    double posY = (tileHeight + tileGap) * ((index / 5).floor());
    num x = 1 + (index / 5).floor();
    num y = 1 + (index % 5);
    TileCoordinate tile = TileCoordinate(x, y);
    bool isEmpty = allLetters.length - 1 == index;
    Color color = isEmpty ? const Color(0xff0b132b) : const Color(0xff1c2541);

    return Box(
        posX, posY, tile, letter, createNeighbour(index, x, y), isEmpty, color);
  }

  return List.generate(
      allLetters.length, (index) => createBox(index, allLetters[index]));
}
