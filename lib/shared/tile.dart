import 'package:flutter/material.dart';
import 'package:word_sort/constants/box.dart';
import 'package:word_sort/models/box.dart';
import 'package:delayed_display/delayed_display.dart';

class Tile extends StatelessWidget {
  const Tile({
    Key? key,
    required this.debugMode,
    required this.boxProp,
    required this.handleBoxClick,
    required this.smallScreen,
    required this.screenWidth,
  }) : super(key: key);
  final bool debugMode;
  final Box boxProp;
  final void Function(Box box) handleBoxClick;
  final bool smallScreen;
  final double screenWidth;

  @override
  Widget build(BuildContext context) {
    return Positioned(
        top: boxProp.startPosX,
        left: boxProp.startPosY,
        child: GestureDetector(
          onTapDown: (detail) => handleBoxClick(boxProp),
          child: Stack(
            alignment: Alignment.center,
            children: [
              DelayedDisplay(
                delay: Duration(milliseconds: boxProp.delay),
                child: Container(
                  width: smallScreen
                      ? tileWidthSmall + ((screenWidth - 320) / 12.5)
                      : tileWidth,
                  height: smallScreen
                      ? tileHeightSamll + ((screenWidth - 320) / 12.5)
                      : tileHeight,
                  decoration: BoxDecoration(
                    color: boxProp.color,
                  ),
                ),
              ),
              Text(
                boxProp.letter.toUpperCase(),
                style: const TextStyle(
                  color: Color.fromARGB(255, 252, 252, 252),
                  fontSize: 22,
                ),
              ),
              if (debugMode)
                Positioned(
                    left: 0,
                    top: 0,
                    child: Text(
                      'x: ' + boxProp.tile.x.toString(),
                      style: TextStyle(
                          color: boxProp.empty
                              ? const Color.fromARGB(255, 7, 0, 0)
                              : const Color.fromARGB(255, 252, 252, 252)),
                    )),
              if (debugMode)
                Positioned(
                    left: 0,
                    top: 20,
                    child: Text(
                      'y: ' + boxProp.tile.y.toString(),
                      style: TextStyle(
                          color: boxProp.empty
                              ? const Color.fromARGB(255, 7, 0, 0)
                              : const Color.fromARGB(255, 252, 252, 252)),
                    )),
              if (debugMode)
                Positioned(
                    left: 0,
                    top: 70,
                    child: Text(
                      'empty: ' + boxProp.empty.toString(),
                      style: TextStyle(
                          color: boxProp.empty
                              ? const Color.fromARGB(255, 7, 0, 0)
                              : const Color.fromARGB(255, 255, 255, 255)),
                    )),
              if (debugMode)
                Positioned(
                    left: 0,
                    top: 80,
                    child: Text(
                      'Selected: ' + boxProp.selected.toString(),
                      style: TextStyle(
                          color: boxProp.empty
                              ? const Color.fromARGB(255, 7, 0, 0)
                              : const Color.fromARGB(255, 255, 255, 255)),
                    ))
            ],
          ),
        ));
  }
}
