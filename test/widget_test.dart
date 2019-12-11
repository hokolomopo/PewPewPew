
import 'dart:convert';
import 'dart:ui';

import 'package:info2051_2018/game/weaponry.dart';


void main() {

  JsonEncoder encoder = new JsonEncoder.withIndent('  ');

  List l = List();
  WeaponStats stats = WeaponStats();
  stats.weaponName = "Colt";
  stats.damage = 30;
  stats.useProjectile = true;
  stats.isExplosive = true;
  stats.detonationDelay = 5000;
  stats.range = 60;
  stats.ammunition = 6;
  stats.hasKnockback = true;
  stats.knockbackStrength = 5000;
  stats.projectileWeight = 10.0;
  stats.projectileMaxSpeed = 3000;
  stats.projectileFrictionFactor = 0.02;
  stats.weaponAsset = "assets/graphics/arsenal/weapons/colt_45.png";
  stats.explosionSound = "explosion.mp3";
  stats.explosionSize = Size(60, 60);

  l.add(stats);
  l.add(stats);

  String json = encoder.convert(l);
  print(json);

  JsonDecoder decoder = JsonDecoder();
  List l2 = List();
  List decoded = decoder.convert(json);

  for(var v in decoded)
    l2.add(WeaponStats.fromJson(v));

  int x = 2;
}
