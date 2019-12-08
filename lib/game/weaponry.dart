import 'dart:math';
import 'dart:ui';

import 'package:info2051_2018/draw/Projectile.dart';
import 'package:info2051_2018/game/entity.dart';
import 'package:info2051_2018/game/util/utils.dart';
import 'package:info2051_2018/sound_player.dart';

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
  // Should be an overdrivable function to get different behaviour for other weapon

  ///Function which apply Damage and knockback to charactere according to
  /// its actual position and range.
  void applyImpact(Projectile p, List<List<Character>> characters, SoundPlayer soundPlayer){
    for (var i = 0; i < characters.length; i++) {
      for (var j = 0; j < characters[i].length; j++) {
        // apply a circular HitBox

        var dist = (p.position - characters[i][j].position).distance;

        if (dist < range) {
          characters[i][j].removeHp(damage, soundPlayer);

          // Apply a vector field for knockback
          Offset projection = characters[i][j].position - p.position;

          // normilize offset
          projection /= projection.distance;

          // The closest to the center of detonation the stronger the knockback
          // Factor from 0% to 100%
          projection *= (range - dist)/ range;
          // Applied factor for knockback strengh
          projection *= knockbackStrength.toDouble();
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
  double frictionFactor; // Percentage of the velocity to remove at each frame [0, 1]

  // To be used by the canvas and modified in applyFriction()
  bool animationStopped = false;

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

    // To indicate canvas to stay on same frame
    if( !this.animationStopped || frictionFactor == 1)
      this.animationStopped = true;
  }

}

// TODO precise value in constructor body instead of arg (useful for tests)
// Class Test for projectile
class Boulet extends Projectile {
  static final String assets = 'assets/graphics/arsenal/projectiles/red_arc.gif';

  Boulet(Offset position, Rectangle hitbox, Offset velocity, double weight,
      int damage, int maxSpeed)
      : super(position, hitbox, velocity, weight, damage, maxSpeed){
    this.drawer = ProjectileDrawer(assets, this);
    this.frictionFactor = 0.02;
  }
}

class ProjDHS extends Projectile {
  static final String assets = 'assets/graphics/arsenal/projectiles/hand-spinner.gif';

  ProjDHS(Offset position, Rectangle hitbox, Offset velocity, double weight,
      int damage, int maxSpeed)
      : super(position, hitbox, velocity, weight, damage, maxSpeed){
    this.drawer = ProjectileDrawer(assets, this);
    this.frictionFactor = 1.toDouble(); // Will be stuck in the ground at impact
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

  //TODO best way to get static info for shop and else? cannot be in abstract class as static
  // What info should it be
  static List<num> infos = [];

  Colt(){
    this.useProjectile = true;
    this.hasKnockback = true;

    this.ammunition = 6;
    this.range = 60; // 60 seems good value
    this.damage = 30;
    this.knockbackStrength = 50;
    this.projectileHitbox ;
    this.projectile;

    this.detonationTime = 5000;

  }

}