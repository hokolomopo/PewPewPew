import 'dart:math';
import 'dart:ui';

import 'package:info2051_2018/draw/Projectile.dart';
import 'package:info2051_2018/game/entity.dart';
import 'package:info2051_2018/game/util/utils.dart';

import 'character.dart';

class Arsenal{
  List<Weapon> arsenal;
  Weapon actualSelection;

  Arsenal(List<Weapon> arsenal){ this.arsenal = arsenal;}

  void selectWeapon(Weapon selectedWeapon){
    this.actualSelection = selectedWeapon;
  }

}

abstract class Weapon{
  //TODO sprite
  bool useProjectile;
  bool hasKnockback;

  int range;
  int damage;
  int detonationTime; // Detonation Time in ms ( < 0 means no detonation) Need collusion trigger
  Rectangle projectileHitbox;

  int ammunition = -1;
  int knockbackStrength = 0;

  Projectile projectile;

  void fireProjectile(Offset direction){
    // TODO horizontal checks
    direction = this.projectile.getLaunchSpeed(direction);



    this.projectile.velocity += direction;
  }

  //TODO decide if methods better in Weapon or corresponding Projectile

  ///Function which apply Damage and knockback to charactere according to
  /// its actual position and range.
  void applyImpact(Projectile p, List<List<Character>> characters){
    for (var i = 0; i < characters.length; i++) {
      for (var j = 0; j < characters[i].length; j++) {
        // apply a circular HitBox

        var dist = (p.position - characters[i][j].position).distance;

        if (dist < range) {
          characters[i][j].removeHp(damage);

          // Apply a vector field for knockback
          Offset projection = characters[i][j].position - p.position;

          // The closest to the center of detonation the stronger the knockback
          projection *= range - dist;
          // Applied factor for knockback strengh
          projection *= knockbackStrength / 100;
          characters[i][j].addVelocity(projection);
        }
      }
    }

  }

}

class Projectile extends MovingEntity{
  double weight;
  int damage;
  int maxSpeed;
  double frictionFactor; // Percentage of the velocity to remove at each frame

  Projectile(Offset position, Rectangle hitbox, Offset velocity, this.weight, this.damage, this.maxSpeed)
      : super.withSpeed(position, hitbox, velocity, new Offset(0, 0));

  ///Function that limit the speed of a launch based on maxSpeed
  Offset getLaunchSpeed(Offset direction){
    double speed = GameUtils.getNormOfOffset(direction);
    if(speed > maxSpeed){
      direction /= (speed / maxSpeed);
    }
    return direction;
  }

  ///Function which apply a friction force when landing on a platform.
  ///By reducing the actual velocity until it is a zero Offset
  void applyFriction(){
    this.addVelocity(Offset(0,0) - this.velocity * frictionFactor);
  }

}

// TODO precise value in constructor body instead of arg (useful for tests)
// Class Test for projectile
class Boulet extends Projectile {
  static final String assets = 'assets/graphics/arsenal/projectiles/bullet1.png';

  Boulet(Offset position, Rectangle hitbox, Offset velocity, double weight,
      int damage, int maxSpeed)
      : super(position, hitbox, velocity, weight, damage, maxSpeed){
    this.drawer = ProjectileDrawer(assets, this);
    this.frictionFactor = 0.02;
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
    this.range = 10;
    this.damage = 30;
    this.knockbackStrength = 5;
    this.projectileHitbox ;
    this.projectile;

    this.detonationTime = 5000;

  }

}