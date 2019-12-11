import 'dart:convert';
import 'dart:math';
import 'dart:ui';

import 'package:info2051_2018/draw/drawer_abstracts.dart';
import 'package:info2051_2018/draw/projectile_drawer.dart';
import 'package:info2051_2018/draw/assets_manager.dart';
import 'package:info2051_2018/draw/weapon_drawer.dart';
import 'package:info2051_2018/game/entity.dart';
import 'package:info2051_2018/game/game_main.dart';
import 'package:info2051_2018/game/util/team.dart';
import 'package:info2051_2018/game/util/utils.dart';
import 'package:info2051_2018/sound_player.dart';

import 'character.dart';

// TODO Use this structure to centralise info
final List<List<String>> _weaponryData = [
  ["proj", "hello"]
];

class Arsenal {
  static final double selectionElementRadius = sqrt(
          pow(Character.hitboxSize.width, 2) +
              pow(Character.hitboxSize.height, 2)) /
      2;
  static final double selectionElementLength = sqrt(2) * selectionElementRadius;
  static final Size selectionElementSize =
      Size(selectionElementLength, selectionElementLength);

  List<Weapon> arsenal = List();
  Weapon currentSelection;

  Arsenal(Character owner){
    for(var entry in GameMain.availableWeapons.entries){
      WeaponStats stats = entry.value;

      Weapon weapon;
      switch(stats.weaponName){
        case Fist.weaponName:
          weapon = Fist(owner);
          break;
        case Colt.weaponName:
          weapon = Colt(owner);
          break;
      }

      weapon.initWeapon(stats);

      arsenal.add(weapon);
    }
  }


  showWeaponSelection(MutableRectangle charHitBox) {
    double angleBetweenElem = 2 * pi / arsenal.length;
    double selectionListRadius = max(2.2 * selectionElementRadius,
        1.1 * selectionElementRadius / sin(angleBetweenElem / 2));
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

      curAngle += angleBetweenElem;
    }
  }

//    void selectWeapon(Weapon selectedWeapon) {
//    this.actualSelection = selectedWeapon;
//    }

  Weapon getWeaponAt(Offset position) {
    for (Weapon weapon in arsenal) {
      if (GameUtils.circleContains(
          weapon.centerPos, selectionElementRadius, position)) {
        return weapon;
      }
    }
    return null;
  }

  selectWeapon(Weapon selectedWeapon) {
    this.currentSelection = selectedWeapon;
    selectedWeapon.selected();
  }
}


abstract class Weapon {
  static final Size relativeSize = Size(5, 3);

  static Offset getOffsetRightOfChar(Size relativeSize) {
    return Offset(Character.hitboxSize.width,
        (Character.hitboxSize.height - relativeSize.height) / 2);
  }

  static Offset getOffsetLeftOfChar(Size relativeSize) {
    return Offset(-relativeSize.width,
        (Character.hitboxSize.height - relativeSize.height) / 2);
  }

  static final Map<int, Offset Function(Size)> directionFacedToOffset = Map()
    ..putIfAbsent(Character.LEFT, () => getOffsetLeftOfChar)
    ..putIfAbsent(Character.RIGHT, () => getOffsetRightOfChar);

  // This variable should be initialised properly in the children, however
  // we initialise it here because we can't define abstract variables.
  final AssetId selectionAsset = AssetId.background;

  void initWeapon(WeaponStats weaponStats){
    this.damage = weaponStats.damage;
    this.range = weaponStats.damage;
    this.useProjectile = weaponStats.useProjectile;
    this.isExplosive = weaponStats.isExplosive;
    this.detonationDelay = weaponStats.detonationDelay;
    this.ammunition = weaponStats.ammunition;
    this.hasKnockback = weaponStats.hasKnockback;
    this.knockbackStrength = weaponStats.knockbackStrength;
  }

  //TODO sprite
  ImagedDrawer drawer;
  Character owner;
  Offset centerPos;
  Offset topLeftPos;
  bool inSelection;

  String name;

  int damage;
  int range;

  bool useProjectile;

  bool isExplosive;
  double detonationDelay;

  int ammunition = -1;

  bool hasKnockback;
  int knockbackStrength = 0;

  //TODO remove this
  Projectile projectile;

  Weapon(this.owner);

  showSelection(Offset centerPos, Offset topLeftPos) {
    this.centerPos = centerPos;
    this.topLeftPos = topLeftPos;
    inSelection = true;
    drawer.relativeSize = Arsenal.selectionElementSize;
    drawer.gif = selectionAsset;
  }

  selected() {
    inSelection = false;
    drawer.relativeSize = relativeSize;
  }

  Projectile fireProjectile(Offset direction) {
    //TODO use this as return value when firing, and ass the returned projectile to the World()
    //TODO GIVE an hitbox and position argument, or use the one of the gun idk
    Projectile projectile = Projectile.fromWeaponStats(null, null, GameMain.availableWeapons[this.name]);

    // TODO horizontal checks
    direction = this.projectile.getLaunchSpeed(direction);

    this.projectile.velocity += direction;

    return projectile;
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

class Fist extends Weapon {
  static const String weaponName = "Fist";

  static final relativeSize = Weapon.relativeSize;

  final AssetId selectionAsset = AssetId.weapon_fist_sel;

  Fist(Character owner) : super(owner) {
    this.drawer =
        WeaponDrawer(AssetId.weapon_fist_sel, this, Weapon.relativeSize);
//    this.useProjectile = false;
//    this.hasKnockback = true;
//    this.isExplosive = false;
//
//    this.ammunition = -1;
//    this.range = 10;
//    this.damage = 10;
//    this.knockbackStrength = 10;
//    this.detonationDelay = 1000;
  }
}

class Colt extends Weapon {
  static const String weaponName = "Colt";

  static final relativeSize = Weapon.relativeSize;

  final AssetId selectionAsset = AssetId.weapon_colt_sel;

  //TODO best way to get static info for shop and else? cannot be in abstract class as static
  // What info should it be
  static List<num> infos = [];

  Colt(Character owner) : super(owner) {
    this.drawer =
        WeaponDrawer(AssetId.weapon_colt_sel, this, Weapon.relativeSize);
//    this.useProjectile = true;
//    this.hasKnockback = true;
//
//    this.ammunition = 6;
//    this.range = 60;
//    this.damage = 30;
//    this.knockbackStrength = 50;
//
//    this.detonationDelay = 5000;
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


  Projectile.fromWeaponStats(Offset position, MutableRectangle<num> hitbox, WeaponStats weaponStats) : super(position, hitbox){
    this.weight = weaponStats.projectileWeight;
    this.maxSpeed = weaponStats.projectileMaxSpeed;
    this.frictionFactor = weaponStats.projectileFrictionFactor;
    this.explosionSound = weaponStats.explosionSound;
    this.explosionSize = weaponStats.explosionSize;
  }

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

class Explosion extends Entity {
  bool animationEnded = false;
  String explosionSound;

  Explosion(Offset position, AssetId assetId, Size size,
      MutableRectangle hitbox, this.explosionSound)
      : super(position, hitbox) {
    this.drawer = ExplosionDrawer(assetId, this, size: size);
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

class WeaponStats{
  String weaponName;

  int damage;
  int range;

  bool useProjectile;

  bool isExplosive;
  double detonationDelay;

  int ammunition = -1;

  bool hasKnockback;
  int knockbackStrength = 0;

  double projectileWeight;
  int projectileMaxSpeed;
  double projectileFrictionFactor; // Percentage of the velocity to remove at each frame [0, 1]

  String weaponAsset;
  String explosionSound;
  Size explosionSize;

  int price;

  WeaponStats();

  WeaponStats.fromJson(Map<String, dynamic> json) {
    this.weaponName = json['weaponName'] as String;
    this.damage = json['damage'] as int;
    this.useProjectile = json['useProjectile'] as bool;
    this.isExplosive = json['isExplosive'] as bool;
    this.detonationDelay = json['detonationDelay'] as double;
    this.range = json['range'] as int;
    this.ammunition = json['ammunition'] as int;
    this.hasKnockback = json['hasKnockback'] as bool;
    this.knockbackStrength = json['knockbackStrength'] as int;
    this.projectileWeight = json['projectileWeight'] as double;
    this.projectileMaxSpeed = json['projectileMaxSpeed'] as int;
    this.projectileFrictionFactor = json['projectileFrictionFactor'] as double;
    this.weaponAsset = json['weaponAsset'] as String;
    this.explosionSound = json['explosionSound'] as String;
    this.explosionSize = Size(json['explosionSizeX'] as double, json['explosionSizeY'] as double);
    this.price = json['weaponAsset'] as int;
  }

  Map<String, dynamic> toJson() {
    return {
      'weaponName': weaponName,
      'damage': damage,
      'useProjectile': useProjectile,
      'isExplosive': isExplosive,
      'detonationDelay': detonationDelay,
      'range': range,
      'ammunition': ammunition,
      'hasKnockback': hasKnockback,
      'knockbackStrength': knockbackStrength,
      'projectileWeight': projectileWeight,
      'projectileMaxSpeed': projectileMaxSpeed,
      'projectileFrictionFactor': projectileFrictionFactor,
      'weaponAsset': weaponAsset,
      'explosionSound': explosionSound,
      'explosionSizeX': explosionSize.width,
      'explosionSizeY': explosionSize.height,
      'price': price,
    };
  }

  static List<WeaponStats> parseList(String json){
    List<WeaponStats> l = List();

    JsonDecoder decoder = JsonDecoder();
    List decoded = decoder.convert(json);

    for(var v in decoded)
      l.add(WeaponStats.fromJson(v));

    return l;
  }

}