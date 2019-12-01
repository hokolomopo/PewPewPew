import 'dart:convert';
import 'dart:ui';

import 'package:info2051_2018/game/terrain.dart';
import 'package:info2051_2018/game/util/json_utils.dart';


class Level {
  Size size;
  String backgroundImage;

  List<TerrainBlock> terrain = List();
  List<Offset> spawnPoints = List();

  //TODO Delete dis
  Level();

  ///Load a level from a level file
  static Level loadLevel(String levelName) {
    //TODO

    return null;
  }

  void addTerrain(TerrainBlock terrainBlock) {
    terrain.add(terrainBlock);
  }

  void addSpawnPoint(Offset point) {
    spawnPoints.add(point);
  }

  Level.fromJson(Map<String, dynamic> json){
    size = Size(json['sizeX'], json['sizeY']);
    for (var block in json['terrain'])
      terrain.add(TerrainBlock.fromJson(block));
    for (var block in json['spawnPoints'])
      spawnPoints.add(SerializableOffset.fromJson(block).toOffset());
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
}