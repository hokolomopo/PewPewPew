import 'dart:math';

import 'package:info2051_2018/draw/terrain.dart';
import 'package:info2051_2018/game/util/json_utils.dart';

class TerrainBlock {
  Rectangle hitBox;
  // Note that even if [withStroke] is [false], the top stroke will still
  // be painted.
  bool withStroke = true;
  TerrainBlockDrawer drawer;

  TerrainBlock(double x, double y, double w, double h, {this.withStroke = true}){
    hitBox = new Rectangle(x, y, w, h);
    drawer = TerrainBlockDrawer(this);
  }

  TerrainBlock.fromJson(Map<String, dynamic> json)
      : hitBox = SerializableRectangle.fromJson(json['hitBox']).toRectangle()
  {
    drawer = TerrainBlockDrawer(this);
  }

  Map<String, dynamic> toJson() =>
      {
        'hitBox': SerializableRectangle(hitBox),
      };

}