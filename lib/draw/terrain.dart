import 'package:flutter/material.dart';
import 'package:info2051_2018/game/util/utils.dart';

import 'paint_constants.dart';
import 'math.dart';
import 'level_painter.dart';
import 'package:info2051_2018/game/terrain.dart';

class TerrainBlockDrawer extends CustomDrawer {
  TerrainBlock terrainBlock;

  TerrainBlockDrawer(this.terrainBlock)
      : super(
            Size(terrainBlock.hitBox.width, terrainBlock.hitBox.height), null);

  /// Removes a set of blocks from their top-left positions.
  ///
  /// [removeBlocksByPositions] is used for the user to remove blocks that have been
  /// individually created (using for instance [addTerrainBlock]). This method
  /// only checks for equality between top-left positions and does not look
  /// for the nearest block.
  /* removeBlocksByPositions(Set<Offset> positions) {
    // Never modifies a [Set] while iterating through it.
    Set<TerrainBlock> toRemove = Set();

    for (TerrainBlock block in blocks) {
      if (positions.contains(Offset(block.hitBox.left, block.hitBox.top))) {
        toRemove.add(block);
      }
    }
    blocks = blocks.difference(toRemove);
  }*/

  /// Removes a set of blocks in a given circle.
  ///
  /// [removeBlocksInRange] removes the blocks whose [distanceTerrainBlockToPoint] from
  /// [center] is smaller than [range]. It means that, currently, a block that
  /// has at least one pixel inside the circle is completely removed.
  ///
  /// @Deprecated This behaviour will likely change in the future : the sizes
  /// of the blocks will be reduced instead of the blocks completely erased.
  /* @Deprecated("The behaviour of this function will change soon, see doc")
  removeBlocksInRange(Offset center, double range) {
    // Never modifies a [Set] while iterating through it.
    Set<TerrainBlock> toRemove = Set();

    for (TerrainBlock block in blocks) {
      if (distanceTerrainBlockToPoint(block, center) <= range) {
        toRemove.add(block);
      }
    }
    blocks = blocks.difference(toRemove);
  }*/

  @override
  void paint(Canvas canvas, Size size, showHitBoxes, Offset cameraPosition) {
    // Remember the block sizes are taken in percentage of the screen size,
    // for more robustness.
    double left =
        GameUtils.relativeToAbsoluteDist(terrainBlock.hitBox.left, size.height);
    double top =
        GameUtils.relativeToAbsoluteDist(terrainBlock.hitBox.top, size.height);

    Rect toDraw = Rect.fromLTWH(left, top, actualSize.width, actualSize.height);

    canvas.drawRect(toDraw, terrainFillPaint);
    if (terrainBlock.withStroke) {
      canvas.drawRect(toDraw, terrainStrokePaint);
    } else {
      // We never paint no strokes at all : we at least paint the top one.
      canvas.drawLine(
          Offset(left, top), Offset(left + actualSize.width, top), terrainStrokePaint);
    }
  }
}
