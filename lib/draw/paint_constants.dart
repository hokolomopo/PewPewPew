import 'package:flutter/material.dart';

final Paint terrainStrokePaint = Paint()
  ..color = Colors.white
  ..strokeWidth = 5
  ..style = PaintingStyle.stroke;


final Paint lifeBarStrokePaint = Paint()
  ..color = Colors.black
  ..strokeWidth = 3
  ..style = PaintingStyle.stroke;

const distanceLifeBarCharacter = 0.05;

final Paint debugShowHitBoxesPaint = Paint()
  ..color = Colors.red
  ..style = PaintingStyle.fill;

final Paint actionBarFillPaint = Paint()
  ..color = Colors.yellow
  ..style = PaintingStyle.fill;

final Paint actionBarStrokePaint = Paint()
  ..color = Colors.white
  ..strokeWidth = 5
  ..style = PaintingStyle.stroke;


final Paint jumpLinePaint = Paint()
  ..color = Colors.white.withAlpha(100)
  ..strokeWidth = 5;

