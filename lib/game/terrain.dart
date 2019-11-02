import 'dart:math';

class Terrain{
  Rectangle hitbox;

  Terrain(double x, double y, double w, double h){
    hitbox = new Rectangle(x, y, w, h);
  }
}