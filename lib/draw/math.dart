import 'package:flutter/material.dart';
import 'dart:math';

double distanceRectToPoint(Rect rect, Offset point) {
  double horizontalDist = point.dx - rect.left;
  if (horizontalDist > 0) {
    horizontalDist = max(horizontalDist - rect.width, 0);
  } else {
    horizontalDist *= -1;
  }

  double verticalDist = point.dy - rect.top;
  if (verticalDist > 0) {
    verticalDist = max(verticalDist - rect.height, 0);
  } else {
    verticalDist *= -1;
  }

  return sqrt(pow(horizontalDist, 2) + pow(verticalDist, 2));
}