import 'dart:math';
import 'dart:ui';

import 'package:info2051_2018/draw/drawer_abstracts.dart';
import 'package:info2051_2018/draw/projectile_drawer.dart';
import 'package:info2051_2018/draw/assets_manager.dart';
import 'package:info2051_2018/game/entity.dart';
import 'package:info2051_2018/game/team.dart';
import 'package:info2051_2018/game/util/utils.dart';
import 'package:info2051_2018/sound_player.dart';

import 'character.dart';

// TODO Use this structure to centralise info
final List<List<String>> _WeaponryData = [
  ["proj", "hello"]
];

class Arsenal {
  List<Weapon> arsenal;
  Weapon actualSelection;

  Arsenal(List<Weapon> arsenal) {
    this.arsenal = arsenal;
  }

  void selectWeapon(Weapon selectedWeapon) {
    this.actualSelection = selectedWeapon;
  }
}

abstract class Weapon {
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

  void fireProjectile(Offset direction) {
    // TODO horizontal checks
    direction = this.projectile.getLaunchSpeed(direction);

    this.projectile.velocity += direction;
  }

  //TODO decide if methods better in Weapon or corresponding Projectile
  // Should be an overdrivable function to get different behaviour for other weapon

  ///Function which apply Damage and knockback to characters according to
  /// its actual position and range.
  void applyImpact(Projectile p, List<Team> characters, SoundPlayer soundPlayer,
      Function statUpdater) {
    for (var i = 0; i < characters.length; i++) {
      for (var j = 0; j < characters[i].length; j++) {
        // apply a circular HitBox

        var dist = (p.getPosition() -
                characters[i].getCharacter(j).getPosition())
            .distance;

        if (dist < range) {
          // Apply damage reduce according to dist [50% - 100%]
          double effectiveDamage = damage.toDouble() * (1 - (range - dist) / 2);

          // Update stats
          double damageDealt =
              min(effectiveDamage, characters[i].getCharacter(j).hp);
          statUpdater(TeamStat.damage_dealt, damageDealt, teamTakingAttack: i);
          if (characters[i].getCharacter(j).hp == 0)
            statUpdater(TeamStat.killed, 1, teamTakingAttack: i);

          characters[i].getCharacter(j).removeHp(effectiveDamage, soundPlayer);

          // Apply a vector field for knockback
          Offset projection =
              characters[i].getCharacter(j).getPosition() -
                  p.getPosition();

          // Normalize offset
          projection /= projection.distance;

          // The closest to the center of detonation the stronger the knockback
          // Factor from 0% to 100%
          projection *= (range - dist) / range;
          // Applied factor for knockback strengh
          projection *= knockbackStrength.toDouble();
          characters[i].getCharacter(j).addVelocity(projection);
        }
      }
    }
  }
}

class Projectile extends MovingEntity {
  double weight;
  int maxSpeed;
  // Percentage of the velocity to remove at each frame [0, 1]
  double frictionFactor;

  String explosionSound;
  Size explosionSize;

  // For projectile which need orientation [Like arrows]
  // expressed in radian in a clockwise way
  double actualOrientation = -1; // < 0 means not rotation

  Projectile(Offset position, Rectangle hitbox, Offset velocity, this.weight,
      this.maxSpeed)
      : super.withSpeed(position, hitbox, velocity, new Offset(0, 0));

  ///Function that limit the speed of a launch based on maxSpeed
  Offset getLaunchSpeed(Offset direction) {
    double speed = GameUtils.getNormOfOffset(direction);
    if (speed > maxSpeed) {
      direction /= (speed / maxSpeed);
    }
    return direction;
  }

  ///Function which apply a friction force when landing on a platform.
  ///By reducing the actual velocity until it is a zero Offset
  void applyFriction() {
    this.addVelocity(Offset(0, 0) - this.velocity * frictionFactor);

    // To indicate canvas to stay on same frame
    if (frictionFactor == 1) drawer.freezeAnimation();
  }

  // Have to be override by children
  Explosion returnExplosionInstance(SoundPlayer soundPlayer) {
    return null;
  }
}

// TODO precise value in constructor body instead of arg (useful for tests)
// Class Test for projectile
class Boulet extends Projectile {
  Boulet(Offset position, Rectangle hitbox,
  {Offset velocity = const Offset(0, 0),
  double weight = 10.0,
  int maxSpeed = 3000})
      : super(position, hitbox, velocity, weight, maxSpeed) {
    this.drawer = ProjectileDrawer(AssetId.projectile_boulet, this);
    this.frictionFactor = 0.02;
  }
}

class ProjDHS extends Projectile {
  final AssetId explosionAssetID = AssetId.explosion_dhs;

  // TODO put arg as optional
  ProjDHS(Offset position, Rectangle hitbox,
      {Offset velocity = const Offset(0, 0),
      double weight = 5.0,
      int maxSpeed = 3000})
      : super(position, hitbox, velocity, weight, maxSpeed) {
    this.drawer = ProjectileDrawer(AssetId.projectile_dhs, this);
    this.frictionFactor = 1.toDouble(); // Will be stuck in the ground at impact
    this.explosionSound = "explosion.mp3";
    this.explosionSize = Size(60, 60);
    this.actualOrientation = 0.0;
  }

  @override
  Explosion returnExplosionInstance(SoundPlayer soundPlayer) {
    Size s = explosionSize;
    if (s == null) s = Size(60, 60);

    drawer.changeRelativeSize(s);

    Offset pos = this.getPosition();
    pos += Offset(-s.width / 2, -s.height / 2);
    this.setPosition(pos);

    return Explosion(
        pos, explosionAssetID, s, hitbox, explosionSound, soundPlayer);
  }
}

class Fist extends Weapon {
  Fist() {
    this.useProjectile = false;
    this.hasKnockback = true;

    this.ammunition = -1;
    this.range = 10;
    this.damage = 10;
    this.knockbackStrength = 10;
  }
}

class Colt extends Weapon {
  //TODO best way to get static info for shop and else? cannot be in abstract class as static
  // What info should it be
  static List<num> infos = [];

  Colt() {
    this.useProjectile = true;
    this.hasKnockback = true;

    this.ammunition = 6;
    this.range = 60; // 60 seems good value
    this.damage = 30;
    this.knockbackStrength = 50;
    this.projectileHitbox;
    this.projectile;

    this.detonationTime = 5000;
  }
}

class Explosion extends Entity {
  bool animationEnded = false;
  String explosionSound;
  SoundPlayer soundPlayer;

  Explosion(Offset position, AssetId assetId, Size size,
      MutableRectangle hitbox, this.explosionSound, this.soundPlayer)
      : super(position, hitbox) {
    this.drawer = ExplosionDrawer(assetId, this, size: size);
  }

  void playSound() {
    if (soundPlayer != null && explosionSound != null)
      soundPlayer.playLocalAudio(explosionSound);
  }

  bool hasEnded() {
    return animationEnded;
  }
}
