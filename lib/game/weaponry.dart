import 'dart:math';
import 'dart:ui';

import 'package:info2051_2018/draw/drawer_abstracts.dart';
import 'package:info2051_2018/draw/projectile_drawer.dart';
import 'package:info2051_2018/draw/assets_manager.dart';
import 'package:info2051_2018/draw/weapon_drawer.dart';
import 'package:info2051_2018/game/entity.dart';
import 'package:info2051_2018/game/util/team.dart';
import 'package:info2051_2018/game/util/utils.dart';
import 'package:info2051_2018/sound_player.dart';

import 'character.dart';

// TODO Use this structure to centralise info
final List<List<String>> _WeaponryData = [
  ["proj", "hello"]
];

class Arsenal {
  static final double selectionElementRadius = sqrt(
          pow(Character.spriteSize.width, 2) +
              pow(Character.spriteSize.height, 2)) /
      2;
  static final double selectionElementLength = sqrt(2) * selectionElementRadius;
  static final Size selectionElementSize =
      Size(selectionElementLength, selectionElementLength);

  // TODO probably better to compute list radius based on the number of elements
  static final double selectionListRadius = 2.2 * selectionElementRadius;

  List<Weapon> arsenal;
  Weapon currentSelection;

  Arsenal(this.arsenal);

  showWeaponSelection(MutableRectangle charHitBox) {
    Offset charCenterPos = Offset(charHitBox.left + charHitBox.width / 2,
        charHitBox.top + charHitBox.height / 2);

    double curAngle = 0;
    Offset curWeaponCenterPos;
    Offset curWeaponTopLeftPos;
    for (Weapon weapon in arsenal) {
      curWeaponCenterPos = Offset(
          charCenterPos.dx - cos(curAngle) * selectionListRadius,
          charCenterPos.dy - sin(curAngle) * selectionListRadius);
      curWeaponTopLeftPos = Offset(
          curWeaponCenterPos.dx - sqrt(2) / 2 * selectionElementRadius,
          curWeaponCenterPos.dy - sqrt(2) / 2 * selectionElementRadius);

      weapon.showSelection(curWeaponCenterPos, curWeaponTopLeftPos);

      curAngle += 2 * pi / arsenal.length;
    }
  void selectWeapon(Weapon selectedWeapon) {
    this.actualSelection = selectedWeapon;
  }

  Weapon getWeaponAt(Offset position) {
    for (Weapon weapon in arsenal) {
      if (GameUtils.circleContains(
          weapon.centerPos, selectionElementRadius, position)) {
        return weapon;
      }
    }
    return null;
  }

  selectWeapon(Weapon selectedWeapon, Character charGettingWeapon) {
    this.currentSelection = selectedWeapon;
    selectedWeapon.selected(charGettingWeapon);
  }
}

abstract class Weapon {
  // TODO maybe having different sizes for inSelection / on the character
  static final Size relativeSize = Size(5, 3);

  static Offset getOffsetRightOfChar(Size relativeSize) {
    return Offset(Character.spriteSize.width,
        Character.spriteSize.height - relativeSize.height / 2);
  }

  static Offset getOffsetLeftOfChar(Size relativeSize) {
    return Offset(-relativeSize.width,
        Character.spriteSize.height - relativeSize.height / 2);
  }

  static final Map<int, Offset Function(Size)> directionFacedToOffset = Map()
    ..putIfAbsent(Character.LEFT, () => getOffsetLeftOfChar)
    ..putIfAbsent(Character.RIGHT, () => getOffsetRightOfChar);

  // This variable should be initialised properly in the children, however
  // we initialise it here because we can't define abstract variables.
  final Map<int, AssetId> directionFacedToAsset = Map();
  final AssetId selectionAsset = AssetId.background;

  //TODO sprite
  ImagedDrawer drawer;
  Offset centerPos;
  Offset topLeftPos;
  bool inSelection;

  int team;

  bool useProjectile;
  bool hasKnockback;

  int range;
  int damage;
  int detonationTime; // Detonation Time in ms ( < 0 means no detonation) Need collusion trigger

  int ammunition = -1;
  int knockbackStrength = 0;

  Projectile projectile;

  Weapon(this.team);

  showSelection(Offset centerPos, Offset topLeftPos) {
    this.centerPos = centerPos;
    this.topLeftPos = topLeftPos;
    inSelection = true;
    drawer.relativeSize = Arsenal.selectionElementSize;
    drawer.gif = selectionAsset;
  }

  selected(Character charGettingWeapon) {
    int dirFaced = charGettingWeapon.directionFaced;
    topLeftPos += directionFacedToOffset[dirFaced](relativeSize);
    inSelection = false;
    drawer.relativeSize = relativeSize;
    drawer.gif = directionFacedToAsset[dirFaced];
  }

  fireProjectile(Offset direction) {
    // TODO horizontal checks
    direction = this.projectile.getLaunchSpeed(direction);

    this.projectile.velocity += direction;
  }

  //TODO decide if methods better in Weapon or corresponding Projectile
  // Should be an overdrivable function to get different behaviour for other weapon

  ///Function which apply Damage and knockback to characters according to
  /// its actual position and range.
  void applyImpact(Projectile p, List<Team> characters,
      Function statUpdater) {
    for (var i = 0; i < characters.length; i++) {
      for (var j = 0; j < characters[i].length; j++) {
        // apply a circular HitBox

        var dist = (p.getPosition() -
                characters[i].getCharacter(j).getPosition())
            .distance;

        if (dist < range) {
          // Apply damage reduce according to dist [33% - 100%]
          double effectiveDamage = damage.toDouble() * (0.32 + (range - dist) / (3 * range));

          // Update stats
          double damageDealt =
              min(effectiveDamage, characters[i].getCharacter(j).hp);
          statUpdater(TeamStat.damage_dealt, damageDealt, teamTakingAttack: i);
          if (characters[i].getCharacter(j).hp == 0)
            statUpdater(TeamStat.killed, 1, teamTakingAttack: i);

          characters[i].getCharacter(j).removeHp(effectiveDamage);

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
  double
      frictionFactor; // Percentage of the velocity to remove at each frame [0, 1]

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
  Explosion returnExplosionInstance() {
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
  Explosion returnExplosionInstance() {
    Size s = explosionSize;
    if (s == null) s = Size(60, 60);

    drawer.changeRelativeSize(s);

    Offset pos = this.getPosition();
    pos += Offset(-s.width / 2, -s.height / 2);
    this.setPosition(pos);

    return Explosion(
        pos, explosionAssetID, s, hitbox, explosionSound);
  }
}

class Fist extends Weapon {
  static final relativeSize = Weapon.relativeSize;

  final Map<int, AssetId> directionFacedToAsset = Map()
    ..putIfAbsent(Character.RIGHT, () => AssetId.weapon_fist_right)
    ..putIfAbsent(Character.LEFT, () => AssetId.weapon_fist_left);
  final AssetId selectionAsset = AssetId.weapon_fist_right;

  Fist(int team) : super(team) {
    print("colt color " + Character.teamColors[team].toString());
    this.drawer = WeaponDrawer(
        AssetId.weapon_fist_right, this, Weapon.relativeSize, Character.teamColors[team]);
class Fist extends Weapon {
    this.useProjectile = false;
    this.hasKnockback = true;

    this.ammunition = -1;
    this.range = 10;
    this.damage = 10;
    this.knockbackStrength = 10;
  }
}

class Colt extends Weapon {
  static final relativeSize = Weapon.relativeSize;

  final Map<int, AssetId> directionFacedToAsset = Map()
    ..putIfAbsent(Character.RIGHT, () => AssetId.weapon_colt_right)
    ..putIfAbsent(Character.LEFT, () => AssetId.weapon_colt_left);
  final AssetId selectionAsset = AssetId.weapon_colt_right;

  //TODO best way to get static info for shop and else? cannot be in abstract class as static
  // What info should it be
  static List<num> infos = [];

  Colt(int team) : super(team) {
    print("colt color " + Character.teamColors[team].toString());
    this.drawer = WeaponDrawer(
        AssetId.weapon_colt_right, this, Weapon.relativeSize, Character.teamColors[team]);
    this.useProjectile = true;
    this.hasKnockback = true;

    this.ammunition = 6;
    this.range = 60; // 60 seems good value
    this.damage = 30;
    this.knockbackStrength = 50;
<<<<<<<
    this.projectileHitbox;
    this.projectile;
=======

>>>>>>>

    this.detonationTime = 5000;
  }
}

class Explosion extends Entity {
  bool animationEnded = false;
  String explosionSound;

  Explosion(Offset position, AssetId assetId, Size size,
      MutableRectangle hitbox, this.explosionSound)
      : super(position, hitbox) {
    this.drawer = ExplosionDrawer(assetId, this, size: size);
  }
}

  void playSound() {
    SoundPlayer soundPlayer = MySoundPlayer.getInstance();
    if (soundPlayer != null && explosionSound != null)
      soundPlayer.playSoundEffect(explosionSound);
  }

  bool hasEnded() {
    return animationEnded;
  }
}
