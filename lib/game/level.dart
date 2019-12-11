import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:info2051_2018/draw/terrain_drawer.dart';
import 'package:info2051_2018/game/entity.dart';
import 'package:info2051_2018/game/util/json_utils.dart';
import 'package:info2051_2018/game/weaponry.dart';


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

  bool isInsideBounds(Entity entity){

    Rectangle other = entity.hitbox;

    return _bounds.intersects(other) || _bounds.containsRectangle(other) || isAboveLevel(entity);
  }

  // Useful to not remove projectile early if they go up
  bool isAboveLevel(Entity entity) {
    Rectangle other = entity.hitbox;
    bool ret = other.top < _bounds.top &&
        _bounds.left < other.left + other.width &&
        other.left < _bounds.left + _bounds.width;

    // Special case for Linear projectile
    // Have to be remove if above stage
    if (ret && entity is Linear)
      return false;

    return ret;
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