import 'package:flutter/material.dart';
import 'package:word_sort/constants/box.dart';
import 'package:word_sort/shared/tile.dart';

import 'models/box.dart';

class Board extends StatelessWidget {
  const Board({
    Key? key,
    required this.smallScreen,
    required this.screenWidth,
    required this.boxProperties,
    required this.debugMode,
    required this.handleBoxClick,
  }) : super(key: key);
  final bool smallScreen;
  final double screenWidth;
  final List<Box> boxProperties;
  final bool debugMode;
  final void Function(Box box) handleBoxClick;

  Widget generateBox(Box box) {
    return Tile(
        debugMode: debugMode,
        boxProp: box,
        handleBoxClick: handleBoxClick,
        smallScreen: smallScreen,
        screenWidth: screenWidth);
  }

  @override
  Widget build(BuildContext context) {
    return Wrap(
      children: [
        Container(
            alignment: Alignment.center,
            color: const Color(0xff0b132b),
            width: smallScreen
                ? (5 * tileWidthSmall) +
                    (4 * tileGap) +
                    (5 * (screenWidth - 320) / 12.5)
                : (5 * tileWidth) + (4 * tileGap),
            height: smallScreen
                ? (5 * tileHeightSamll) +
                    (4 * tileGap) +
                    (5 * (screenWidth - 320) / 12.5)
                : (5 * tileHeight) + (4 * tileGap),
            child: Stack(
              alignment: Alignment.center,
              children: boxProperties.map((box) => generateBox(box)).toList(),
            )),
      ],
    );
  }
}
