import 'package:flutter/material.dart';
import './models/box.dart';
import './services/box.dart';
import './services/game.dart';
import './constants//box.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'WordSort Demo',
      theme: ThemeData(
          // primarySwatch: const Color(0xff89ABE3),
          ),
      home: const MyHomePage(title: 'Word Sort'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<Box> _boxProps = [];
  bool debugMode = false;
  bool solved = false;

  @override
  void initState() {
    super.initState();
    _boxProps = generateBoxProperties();
  }

  void _handleClick(Box selectedBox) {
    if (selectedBox.empty || solved) {
      return;
    }

    var newBoxProps = updateBoxesProp(_boxProps, selectedBox);
    setState(() {
      _boxProps = newBoxProps;
      solved = checkSolution(newBoxProps);
    });
  }

  Widget generateBox(Box box) {
    return Positioned(
        top: box.startPosX,
        left: box.startPosY,
        child: GestureDetector(
          onTapDown: (detail) => _handleClick(box),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: tileWidth,
                height: tileHeight,
                decoration: BoxDecoration(
                  color: box.color,
                ),
              ),
              Text(
                box.letter.toUpperCase(),
                style:
                    const TextStyle(
                      color: Color.fromARGB(255, 252, 252, 252),
                      fontSize: 22,
                ),
              ),
              if (debugMode)
                Positioned(
                    left: 0,
                    top: 0,
                    child: Text(
                      'x: ' + box.tile.x.toString(),
                      style: TextStyle(
                          color: box.empty
                              ? const Color.fromARGB(255, 7, 0, 0)
                              : const Color.fromARGB(255, 252, 252, 252)),
                    )),
              if (debugMode)
                Positioned(
                    left: 0,
                    top: 20,
                    child: Text(
                      'y: ' + box.tile.y.toString(),
                      style: TextStyle(
                          color: box.empty
                              ? const Color.fromARGB(255, 7, 0, 0)
                              : const Color.fromARGB(255, 252, 252, 252)),
                    )),
              if (debugMode)
                Positioned(
                    left: 0,
                    top: 70,
                    child: Text(
                      'empty: ' + box.empty.toString(),
                      style: TextStyle(
                          color: box.empty
                              ? const Color.fromARGB(255, 7, 0, 0)
                              : const Color.fromARGB(255, 255, 255, 255)),
                    )),
              if (debugMode)
                Positioned(
                    left: 0,
                    top: 80,
                    child: Text(
                      'Selected: ' + box.selected.toString(),
                      style: TextStyle(
                          color: box.empty
                              ? const Color.fromARGB(255, 7, 0, 0)
                              : const Color.fromARGB(255, 255, 255, 255)),
                    ))
            ],
          ),
        ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: const Color(0xff0b132b),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              const Text("WORDSORT", style: TextStyle(color: Color(0xffffffff), fontSize: 24, )),
              Container(
                color: const Color(0xff0b132b),
                  width: 5*tileWidth + 6*tileGap,
                  height: 5*tileHeight + 6*tileGap,
                  child: Stack(
                    children: _boxProps.map((box) => generateBox(box)).toList(),
                  )),
            ],
          ),
        ));
  }
}
