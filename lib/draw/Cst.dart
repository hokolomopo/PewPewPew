import 'package:flutter/material.dart';

Paint terrainFillPaint = Paint()
  ..color = Colors.green
  ..style = PaintingStyle.fill;
Paint terrainStrokePaint = Paint()
  ..color = Colors.white
  ..strokeWidth = 5
  ..style = PaintingStyle.stroke;

const defaultBackgroundPath =
    "assets/graphics/backgrounds/default_background.png";

Paint lifeBarStrokePaint = Paint()
  ..color = Colors.black
  ..strokeWidth = 3
  ..style = PaintingStyle.stroke;
const distanceLifeBarCharacter = 0.05;

Paint debugShowHitBoxesPaint = Paint()
  ..color = Colors.white
  ..style = PaintingStyle.fill;
