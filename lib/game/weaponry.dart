import 'dart:math';
import 'dart:ui';

import 'package:info2051_2018/game/entity.dart';

class Arsenal{
  List<Weapon> arsenal;
}

abstract class Weapon{
  //TODO sprite
  bool useProjectile;
  bool hasKnockback;

  int range;
  int damage;
  Rectangle projectileHitbox;

  int ammunition = -1;
  int knockbackStrength = 0;

  Projectile fireProjectile(Offset position);

}

class Projectile extends MovingEntity{
  double weight;
  int damage;

  Projectile(Offset position, Rectangle hitbox, Offset velocity, this.weight, this.damage)
      : super.withSpeed(position, hitbox, velocity, new Offset(0, 0));
}

class Fist extends Weapon{

  Fist(){
    this.useProjectile = false;
    this.hasKnockback = true;

    this.ammunition = -1;
    this.range = 10;
    this.damage = 10;
    this.knockbackStrength = 10;
  }


  @override
  Projectile fireProjectile(Offset position) {
    return null;
  }


}