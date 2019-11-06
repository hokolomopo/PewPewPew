import 'package:flutter/material.dart';
import 'dart:math';

import 'package:info2051_2018/game/terrain.dart';

/// Computes the euclidean distance between a point and a rectangle.
///
/// The distance is simply computed as the distance between the given [point]
/// and the nearest point that is in [rect].
double distanceTerrainBlockToPoint(TerrainBlock rect, Offset point) {
  double horizontalDist = point.dx - rect.hitBox.left;
  if (horizontalDist > 0) {
    horizontalDist = max(horizontalDist - rect.hitBox.width, 0);
  } else {
    horizontalDist *= -1;
  }

  double verticalDist = point.dy - rect.hitBox.top;
  if (verticalDist > 0) {
    verticalDist = max(verticalDist - rect.hitBox.height, 0);
  } else {
    verticalDist *= -1;
  }

  return sqrt(pow(horizontalDist, 2) + pow(verticalDist, 2));
}