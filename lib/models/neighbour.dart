import 'tile.dart';

class Neighbour {
  TileCoordinate? top;
  TileCoordinate? bottom;
  TileCoordinate? right;
  TileCoordinate? left;

  Neighbour(this.top, this.bottom, this.right, this.left);
}
