import 'dart:math';

import 'dart:ui';

import 'package:info2051_2018/game/entity.dart';
import 'package:info2051_2018/game/weaponry.dart';

class Character extends MovingEntity {
  static const int base_hp = 100;
  static final Offset hitboxSize = new Offset(10,10);

  int hp;
  Arsenal currentArsenal;

  Character(Offset position) : super(position, new MutableRectangle(position.dx, position.dy, hitboxSize.dx, hitboxSize.dy));

}