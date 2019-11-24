import 'package:flutter/material.dart';
import 'package:info2051_2018/game/util/utils.dart';
import 'dart:math';

import 'paint_constants.dart';
import 'math.dart';
import 'level_painter.dart';
import 'package:info2051_2018/game/terrain.dart';

/// Represents the terrain (the ground) of the game.
///
/// This class provides methods to create and manage the state of the terrain.
/// The basics are adding a block or removing it, however this provides other
/// methods that you can use to perform usual actions on the terrain.
///
/// For performance purposes (avoiding drawing each modification), this class
/// is not a widget and thus *never* set the state, the caller should do that
/// itself when all modifications are done.
///
/// It must be noted that all distances, ranges, and sizes **have to**
/// be expressed in proportion of the screen size, meaning that the valid
/// range is [0;1]. Providing values outside this range to the functions may
/// lead to unexpected behaviour.
class TerrainBlockDrawer extends CustomDrawer {
  TerrainBlock terrainBlock;

  //Set<TerrainBlock> blocks = Set();

  TerrainBlockDrawer(this.terrainBlock);

  /// Creates a new terrain block.
  ///
  /// The [position] follows the axis system of Flutter : (0,0) is top left;
  /// (1,1) is bottom right. If [width] (resp. [height]) is not given, it
  /// will be infinite, meaning that the block will expand to the right
  /// (resp. bottom) of the screen. In that case, the corresponding stroke line
  /// will not be drawn.
  /*addTerrainBlock(Offset position, {width, height}) {
    blocks.add(TerrainBlock(position.dx, position.dy, width ?? double.infinity,
        height ?? double.infinity));
  }*/

  /// Creates a terrain whose shape is given by a function.
  ///
  /// [createTerrainFromFunction] adds [nbBlocks] uniformly from left = 0 to
  /// the screen size, the heights being given by [heightFromLeft],
  /// 0 being the bottom of the screen. [heightFromLeft] should take one
  /// argument, the left position, and return a double : the corresponding
  /// desired height.
  ///
  /// Remember everything should be expressed in percentage of the screen size.
  /*createTerrainFromFunction(Function heightFromLeft, {nbBlocks = 10}) {
    blocks.clear();

    for (double curLeft = 0;
        curLeft < 180*(nbBlocks - 0.5) / nbBlocks;
        curLeft += 180 / nbBlocks) {
      // The width is increased a bit so that we don't see hairlines
      // between the blocks (otherwise at some points there is a one pixel
      // hole between blocks due to double computations inaccuracy).
      blocks.add(TerrainBlock(curLeft, 100 - heightFromLeft(curLeft),
          100 / nbBlocks + 0.5, double.infinity,
          withStroke: false));
    }
  }
*/

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
    double width = GameUtils.relativeToAbsoluteDist(
        terrainBlock.hitBox.width, size.height);
    double height = GameUtils.relativeToAbsoluteDist(
        terrainBlock.hitBox.height, size.height);

    Rect toDraw = Rect.fromLTWH(
        left,
        top,
        // [canvas.drawRect] does not like [double.infinity] while stroking.
        // As we don't know the size before painting, we can only truncate those
        // infinities here.
        min(width, size.width - left),
        min(height, size.height - top));

    canvas.drawRect(toDraw, terrainFillPaint);
    if (terrainBlock.withStroke) {
      canvas.drawRect(toDraw, terrainStrokePaint);
    } else {
      // We never paint no strokes at all : we at least paint the top one.
      canvas.drawLine(
          Offset(left, top), Offset(left + width, top), terrainStrokePaint);
    }
  }
}

// Simple wrapper around the Rect class
// used to maintain information about stroke.
/*class _TerrainBlock extends Rect {
  // Note that even if [withStroke] is [false], the top stroke will still
  // be painted.
  bool withStroke;

  _TerrainBlock(left, top, width, height, {this.withStroke = true})
      : super.fromLTWH(left, top, width, height);
}
*/
