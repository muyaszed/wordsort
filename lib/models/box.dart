import 'package:flutter/material.dart';
import 'tile.dart';
import 'neighbour.dart';

class Box {
  TileCoordinate tile;
  double startPosX;
  double startPosY;
  String letter;
  bool selected = false;
  Neighbour neighbour;
  bool empty = false;
  Color color;

  Box(this.startPosX, this.startPosY, this.tile, this.letter, this.neighbour,
      this.empty, this.color);

  void setNeighbour(newNeghbour) {
    neighbour = newNeghbour;
  }
}
