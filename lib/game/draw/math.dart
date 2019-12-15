import 'package:flutter/material.dart';
import 'package:info2051_2018/game/level.dart';
import 'dart:math';


/// Computes the euclidean distance between a point and a rectangle.
///
/// The distance is simply computed as the distance between the given [point]
/// and the nearest point that is in [rect].
double distanceTerrainBlockToPoint(TerrainBlock rect, Offset point) {
  double horizontalDist = point.dx - rect.hitbox.left;
  if (horizontalDist > 0) {
    horizontalDist = max(horizontalDist - rect.hitbox.width, 0);
  } else {
    horizontalDist *= -1;
  }

  double verticalDist = point.dy - rect.hitbox.top;
  if (verticalDist > 0) {
    verticalDist = max(verticalDist - rect.hitbox.height, 0);
  } else {
    verticalDist *= -1;
  }

  return sqrt(pow(horizontalDist, 2) + pow(verticalDist, 2));
}