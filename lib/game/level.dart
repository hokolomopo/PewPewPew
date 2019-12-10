import 'dart:convert';
import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:info2051_2018/draw/terrain_drawer.dart';
import 'package:info2051_2018/game/util/json_utils.dart';


class Level {
  Size size;
  String backgroundImage;
  Rectangle _bounds;

  List<TerrainBlock> terrain = List();
  List<Offset> spawnPoints = List();

  Level();

  void addTerrain(TerrainBlock terrainBlock) {
    terrain.add(terrainBlock);
  }

  void addSpawnPoint(Offset point) {
    spawnPoints.add(point);
  }

  bool isInsideBounds(Rectangle other){
    return _bounds.intersects(other) || _bounds.containsRectangle(other);
  }

  Level.fromJson(Map<String, dynamic> json){
    size = Size(json['sizeX'], json['sizeY']);
    for (var block in json['terrain'])
      terrain.add(TerrainBlock.fromJson(block));
    for (var block in json['spawnPoints'])
      spawnPoints.add(SerializableOffset.fromJson(block).toOffset());
    _bounds = Rectangle(0, 0, size.width, size.height);
  }

  Map<String, dynamic> toJson() {
    List<SerializableOffset> jsonSpawns;
    jsonSpawns = spawnPoints.map( (item) => SerializableOffset(item)).toList();
    return {
      'terrain': terrain,
      'sizeX': size.width,
      'sizeY': size.height,
      'spawnPoints': jsonSpawns,
    };
  }

  set color(Color color){
    for(TerrainBlock block in terrain)
      block.color = color;
  }
}

class TerrainBlock {
  Rectangle hitBox;
  // Note that even if [withStroke] is [false], the top stroke will still
  // be painted.
  bool withStroke = true;
  TerrainBlockDrawer drawer;
  Color color = Colors.green;

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