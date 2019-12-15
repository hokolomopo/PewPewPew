import 'dart:math';
import 'dart:ui';

import 'package:info2051_2018/game/draw/drawer_abstracts.dart';
import 'package:info2051_2018/game/draw/paint_constants.dart';
import 'package:info2051_2018/game/level.dart';
import 'package:info2051_2018/game/util/utils.dart';

class _Line {
  double start;
  double end;

  _Line(this.start, this.end);
}

class _LineToDraw {
  Offset start;
  Offset end;

  _LineToDraw(this.start, this.end);
}

class TerrainStrokeDrawer extends CustomDrawer {
  List<TerrainBlock> blocks = List();
  List<_LineToDraw> _strokes = List();
  bool _strokesComputed = false;
  static final double increaseInSize = 1;

  TerrainStrokeDrawer() : super(null);

  addTerrainBlock(TerrainBlock block) {
    _strokesComputed = false;
    blocks.add(block);
  }

  removeTerrainBlock(TerrainBlock block) {
    _strokesComputed = false;
    blocks.remove(block);
  }

  computeStrokes() {
    _strokes.clear();
    Map<double, List<_Line>> horizontal = Map();
    Map<double, List<_Line>> vertical = Map();

    MutableRectangle<num> hitbox;
    for (TerrainBlock block in blocks) {
      hitbox = block.hitbox;
      _addLine(horizontal, hitbox.left, hitbox.top, hitbox.width);
      _addLine(
          horizontal, hitbox.left, hitbox.top + hitbox.height, hitbox.width);
      _addLine(vertical, hitbox.top, hitbox.left, hitbox.height);
      _addLine(vertical, hitbox.top, hitbox.left + hitbox.width, hitbox.height);
    }

    _computeStrokesOfMap(horizontal, true);
    _computeStrokesOfMap(vertical, false);

    _strokesComputed = true;
  }

  _computeStrokesOfMap(Map<double, List<_Line>> map, bool isHorizontal) {
    _Line prevLine;
    _Line curLine;
    List<_Line> curList;
    for (MapEntry<double, List<_Line>> entry in map.entries) {
      curList = entry.value;
      curList.sort((_Line a, _Line b) =>
          a.start < b.start ? -1 : a.start == b.start ? 0 : 1);

      prevLine = curList[0];
      for (int i = 1; i < curList.length; i++) {
        curLine = curList[i];
        if (curList[i].start >= prevLine.end) {
          _addLineToDraw(prevLine.start, prevLine.end, entry.key, isHorizontal);
          prevLine = curLine;
        } else {
          _addLineToDraw(
              prevLine.start, curLine.start, entry.key, isHorizontal);
          prevLine = _Line(
              min(prevLine.end, curLine.end), max(prevLine.end, curLine.end));
        }
      }
      _addLineToDraw(prevLine.start, prevLine.end, entry.key, isHorizontal);
    }
  }

  _addLineToDraw(double mainCoordinateStart, double mainCoordinateEnd,
      double secondaryCoordinate, bool isHorizontal) {
    if (mainCoordinateStart == mainCoordinateEnd) return;

    mainCoordinateStart -= increaseInSize/2;
    mainCoordinateEnd += increaseInSize/2;

    if (isHorizontal) {
      _strokes.add(_LineToDraw(Offset(mainCoordinateStart, secondaryCoordinate),
          Offset(mainCoordinateEnd, secondaryCoordinate)));
    } else {
      _strokes.add(_LineToDraw(Offset(secondaryCoordinate, mainCoordinateStart),
          Offset(secondaryCoordinate, mainCoordinateEnd)));
    }
  }

  static _addLine(Map<double, List<_Line>> map, double mainCoordinate,
      double secondaryCoordinate, double length) {
    _Line toAdd = _Line(mainCoordinate, mainCoordinate + length);

    map.update(secondaryCoordinate, (curSet) => curSet..add(toAdd),
        ifAbsent: () => List<_Line>()..add(toAdd));
  }

  @override
  paint(Canvas canvas, Size size, bool showHitBoxes, Offset cameraPosition) {
    if (!_strokesComputed) {
      computeStrokes();
    }
    
    for (_LineToDraw stroke in _strokes) {
      canvas.drawLine(
          GameUtils.relativeToAbsoluteOffset(stroke.start, size.height),
          GameUtils.relativeToAbsoluteOffset(stroke.end, size.height),
          terrainStrokePaint);
    }
  }
}
