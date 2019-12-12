import 'dart:ui';

import 'package:info2051_2018/draw/drawer_abstracts.dart';
import 'package:info2051_2018/draw/paint_constants.dart';
import 'package:info2051_2018/game/level.dart';

class _Line {
  Offset start;
  Offset end;

  _Line(this.start, this.end);
}

class TerrainStrokeDrawer extends CustomDrawer {
  Set<TerrainBlock> blocks = Set();
  Set<_Line> _strokes = Set();
  bool _strokesComputed = false;

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
    Set<_Line> horizontal;
    Set<_Line> vertical;
    for (TerrainBlock block in blocks) {
      
    }
    _strokesComputed = true;
  }

  @override
  paint(Canvas canvas, Size size, bool showHitBoxes, Offset cameraPosition) {
    if (!_strokesComputed) {
      computeStrokes();
    }

    for(_Line stroke in _strokes) {
      canvas.drawLine(stroke.start, stroke.end, terrainStrokePaint);
    }
  }
}