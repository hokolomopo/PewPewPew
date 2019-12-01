import 'dart:math';
import 'dart:ui';

import 'package:info2051_2018/draw/Projectile.dart';
import 'package:info2051_2018/game/entity.dart';
import 'package:info2051_2018/game/util/utils.dart';

class Arsenal{
  List<Weapon> arsenal;
  Weapon actualSelection;

  Arsenal(List<Weapon> arsenal){ this.arsenal = arsenal;}

  void selectWeapon(Weapon selectedWeapon){
    this.actualSelection = actualSelection;
  }

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

  Projectile projectile;

  void fireProjectile(Offset direction){
    // TODO horizontal checks
    direction = this.projectile.getLaunchSpeed(direction);
    this.projectile.velocity += direction;
  }
}

class Projectile extends MovingEntity{
  double weight;
  int damage;
  int maxSpeed;

  Projectile(Offset position, Rectangle hitbox, Offset velocity, this.weight, this.damage)
      : super.withSpeed(position, hitbox, velocity, new Offset(0, 0));

  ///Function that limit the speed of a launch based on maxSpeed
  Offset getLaunchSpeed(Offset direction){
    double speed = GameUtils.getNormOfOffset(direction);
    if(speed > maxSpeed){
      direction /= (speed / maxSpeed);
    }
    return direction;
  }
}

// Class Test
class Boulet extends Projectile {
  static final String assets = 'assets/graphics/arsenal/projectiles/bullet1.png';

  Boulet(Offset position, Rectangle hitbox, Offset velocity, double weight,
      int damage)
      : super(position, hitbox, velocity, weight, damage){
    this.drawer = ProjectileDrawer(assets, this);
  }
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


}

class Colt extends Weapon{

  Colt(){
    this.useProjectile = true;
    this.hasKnockback = true;

    this.ammunition = 6;
    this.range = 100;
    this.damage = 30;
    this.knockbackStrength = 5;
    this.projectileHitbox ;
    this.projectile;

  }

}