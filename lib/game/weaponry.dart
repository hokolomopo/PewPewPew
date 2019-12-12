import 'dart:convert';
import 'dart:math';
import 'dart:ui';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:info2051_2018/draw/drawer_abstracts.dart';
import 'package:info2051_2018/draw/projectile_drawer.dart';
import 'package:info2051_2018/draw/assets_manager.dart';
import 'package:info2051_2018/game/entity.dart';
import 'package:info2051_2018/game/game_main.dart';
import 'package:info2051_2018/game/util/team.dart';
import 'package:info2051_2018/game/util/utils.dart';
import 'package:info2051_2018/game/weapons.dart';
import 'package:info2051_2018/sound_player.dart';

import 'character.dart';

class Arsenal {
  static final double selectionElementRadius = sqrt(
          pow(Character.hitboxSize.width * 2, 2) +
              pow(Character.hitboxSize.height, 2)) /
      2;
  static final double selectionElementLength = sqrt(2) * selectionElementRadius;
  static final Size selectionElementSize =
      Size(selectionElementLength, selectionElementLength);
  static final double minDistanceBetweenElem = 1.1 * selectionElementRadius;

  List<Weapon> arsenal = List();
  Weapon currentSelection;

  double totalRadius;


  Arsenal(Character owner){
    for(var entry in GameMain.availableWeapons.entries){
      WeaponStats stats = entry.value;

      Weapon weapon = Weapon.fromWeaponStats(owner, stats);

      arsenal.add(weapon);
    }
  }


  showWeaponSelection(MutableRectangle charHitBox) {
    // The formula does not work with a single element, as we can't put
    // any distance between an element and itself.
    double angleBetweenElem = min(pi, 2 * pi / arsenal.length);
    double selectionListRadius = max(2*minDistanceBetweenElem,
        minDistanceBetweenElem / sin(angleBetweenElem / 2));
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

    totalRadius = selectionListRadius;
  }

  Weapon getWeaponAt(Offset position) {
    for (Weapon weapon in arsenal) {
      if (GameUtils.circleContains(
          weapon.centerPos, selectionElementRadius, position) && weapon.ammunition > 0) {
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
  AssetId projectileAssetId;
  ImagedDrawer drawer;
  Character owner;
  Offset centerPos;
  Offset topLeftPos;
  bool inSelection;


  String name;

  int damage;
  int range;

  double detonationDelay;
  double ammunition;
  bool isExplosive;

  int knockbackStrength = 0;

  List<Projectile> projectiles = List();

  Offset get weaponCenterOffset;

  Size get relativeSize;

  Offset getOffsetRightOfChar(Size relativeSize) {
    return Offset(Character.hitboxSize.width,
        (Character.hitboxSize.height - relativeSize.height) / 2) - Offset(weaponCenterOffset.dx, weaponCenterOffset.dy);
  }

  Offset getOffsetLeftOfChar(Size relativeSize) {
    return Offset(-relativeSize.width,
        (Character.hitboxSize.height - relativeSize.height) / 2) - Offset(-weaponCenterOffset.dx, weaponCenterOffset.dy);
  }

  Map<int, Offset Function(Size)> directionFacedToOffset;

  // This variable should be initialised properly in the children, however
  // we initialise it here because we can't define abstract variables.
  final AssetId selectionAsset = AssetId.background;

  Weapon(this.owner) {
    directionFacedToOffset = Map()
      ..putIfAbsent(Character.LEFT, () => getOffsetLeftOfChar)
      ..putIfAbsent(Character.RIGHT, () => getOffsetRightOfChar);
  }

  factory Weapon.fromWeaponStats(Character owner, WeaponStats weaponStats){
    Weapon w;
    switch(weaponStats.weaponName){
      case Fist.weaponName:
        w = Fist(owner);
        break;
      case Colt.weaponName:
        w = Colt(owner);
        break;
      case Grenade.weaponName:
        w = Grenade(owner);
        break;
      case Sniper.weaponName:
        w = Sniper(owner);
        break;
      case Railgun.weaponName:
        w = Railgun(owner);
        break;
      case Shotgun.weaponName:
        w = Shotgun(owner);
        break;
    }
    w.damage = weaponStats.damage;
    w.range = weaponStats.range;
    w.detonationDelay = weaponStats.detonationDelay;
    w.ammunition = weaponStats.ammunition;
    w.knockbackStrength = weaponStats.knockbackStrength;
    w.projectileAssetId = AssetIdMapper.map[weaponStats.projectileAsset];
    w.isExplosive = weaponStats.isExplosive && w.range > 0;

    return w;
  }



  showSelection(Offset centerPos, Offset topLeftPos) {
    this.centerPos = centerPos;
    this.topLeftPos = topLeftPos;
    inSelection = true;

    // Center the weapon if it's not a square sprite
    double heightRatio = relativeSize.height / relativeSize.width;
    drawer.relativeSize = Size(Arsenal.selectionElementSize.width,
        Arsenal.selectionElementSize.height * heightRatio);
    this.topLeftPos += Offset(0, Arsenal.selectionElementSize.height * ((1 - heightRatio) / 2));
  }

  selected() {
    inSelection = false;
  }

  // Example ShortGun => 3 projectile same initial pos with offset in direction
  void prepareFiring(Character char){
    if(char == null)
      return;

    this.projectiles = List();
    WeaponStats stats = GameMain.availableWeapons[this.name];


    double projectileX = char.hitbox.left;
    double projectileY = char.hitbox.top;
    MutableRectangle hitbox = MutableRectangle(projectileX, projectileY,
        stats.projectileHitboxSize.width, stats.projectileHitboxSize.height);

    this.projectiles.add( Projectile.fromWeaponStats(Offset(projectileX, projectileY),
        hitbox, projectileAssetId, GameMain.availableWeapons[this.name]) );
  }

  List<Projectile> fireProjectile(Offset direction, Character char) {

    if(projectiles.length == 0 || char == null){
      return null;
    }
    WeaponStats stats = GameMain.availableWeapons[this.name];

    direction = projectiles.first.getLaunchSpeed(direction);

    for (Projectile p in projectiles) {

      if(char.directionFaced == Character.LEFT){
        p.move(Offset(-(stats.projectileHitboxSize.width + 1), 0));
      }
      else{
        p.move(Offset((char.hitbox.width + 1), 0));
      }

      p.velocity += direction;
    }

    return projectiles;
  }

}

abstract class Projectile extends MovingEntity {
  AssetId assetId;

  double weight;
  int maxSpeed;
  double frictionFactor; // Percentage of the velocity to remove at each frame [0, 1]
  int damage;
  int knockBackStrength;

  // For projectile which need orientation [Like arrows]
  // expressed in radian in a clockwise way
  double actualOrientation = -1; // < 0 means no rotation

  factory Projectile.fromWeaponStats(Offset position, MutableRectangle<num> hitbox, AssetId projectileAsset, WeaponStats weaponStats){
    Projectile p;
    if(weaponStats.isExplosive)
      p = ExplosiveProjectile(position, hitbox,
            explosionSound: weaponStats.explosionSound,
            explosionAssetId: AssetIdMapper.map[weaponStats.explosionAsset],
            explosionSize: weaponStats.explosionSize,
            explodeOnImpact: weaponStats.explodeOnImpact,
            detonationDelay: weaponStats.detonationDelay,
            explosionRange: weaponStats.range,
      );
    else
      p = LinearProjectile(position, hitbox);

    p.assetId = projectileAsset;
    p.weight = weaponStats.projectileWeight;
    p.maxSpeed = weaponStats.projectileMaxSpeed;
    p.frictionFactor = weaponStats.projectileFrictionFactor;
    p.drawer = ProjectileDrawer(projectileAsset, p, size:weaponStats.projectileHitboxSize);
    p.actualOrientation = weaponStats.projectileEnableOrientation.toDouble();
    p.damage = weaponStats.damage;
    p.knockBackStrength = weaponStats.knockbackStrength;

    return p;
  }

  Projectile(Offset position, Rectangle hitbox) : super(position, hitbox);

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
    if (frictionFactor == 1)
      (drawer as ImagedDrawer).freezeAnimation();
  }

  // Have to be override by children
  MyAnimation returnAnimationInstance() {
    return null;
  }

  ///Function to play a sound effect at the start of the launch
  void playStartSound(){}
}

/// Class to implement projectile which react a command (onTap for instance),
/// While being launch
/// (Arrow changing direction once on onTap, C4, ...)
abstract class Controllable extends Projectile{

  static const String projectileName = "Controllable";

  // Constructor not useful
  Controllable(Offset position, Rectangle hitbox): super(position, hitbox,);

//  Controllable.fromWeaponStat(Offset position, MutableRectangle<num> hitbox, WeaponStats weaponStats) : super.fromWeaponStats(position, hitbox, weaponStats);


  // Put to true corresponding listener in constructor or json of the projectile
  // and override the corresponding methods
  bool onTapListener = false;
  bool onPressListener = false;
  bool onPanListener = false;

  void onTap(){}
  void onPress(){}
  void onPan(){}
}

/// Class to implement projectile which are explosives and have a detonation timer.
/// (Bombs, ...)
class ExplosiveProjectile extends Projectile{
  AssetId explosionAssetId;

  bool explodeOnImpact = false;
  double detonationDelay = 1;

  String explosionSound;
  Size explosionSize;

  int explosionRange;

  Stopwatch timer = Stopwatch();

  ExplosiveProjectile(position, Rectangle hitbox, {this.explodeOnImpact, this.detonationDelay,
    this.explosionSound:"explosion.mp3", this.explosionSize, this.explosionAssetId:AssetId.explosion_dhs,
    this.explosionRange}):
        super(position, hitbox);

  /// Function to check if projectile has ended, or not
  /// If it does, create explosion animation
  bool checkTTL(){
    return timer.elapsedMilliseconds > detonationDelay;
  }

  void resetStopWatch() {
    timer.stop();
    timer.reset();
  }

  void startTimer(){
    timer.start();
  }

  @override
  MyAnimation returnAnimationInstance(){
    Size s = explosionSize;
    if (s == null) s = Size(60, 60);

    drawer.changeRelativeSize(s);

    Offset pos = this.getPosition();
    pos += Offset(-s.width / 2, -s.height / 2);
    this.setPosition(pos);

    return MyAnimation(pos, explosionAssetId, s, hitbox, explosionSound);
  }

}

/// Mixin class for projectile which applyImpact when intersecting another
/// hitbox or going out of bound
/// (Arrow, Bombardement, ...)
// else apply method
class LinearProjectile extends Projectile {
  LinearProjectile(position, Rectangle hitbox): super(position, hitbox);
}

/// Animation (Gif) limited in Time (counted in total frames)
/// It can also play a sound effect
class MyAnimation extends Entity {
  bool animationEnded = false;
  String soundEffect;

  MyAnimation(Offset position, AssetId assetId, Size size,
      MutableRectangle hitbox, this.soundEffect)
      : super(position, hitbox) {
    this.drawer = AnimationDrawer(assetId, this, size: size);
  }

  void playSound() {
    SoundPlayer soundPlayer = SoundPlayer.getInstance();
    if (soundPlayer != null && soundEffect != null && soundEffect != "")
      soundPlayer.playSoundEffect(soundEffect);
  }

  bool hasEnded() {
    return animationEnded;
  }
}

/// Specification of MyAnimation for loop Animation along side simple sound effect
/// or loop sound effect
/// A trigger has to be implemented to stop the loop animation and sound.

class LoopAnimation extends MyAnimation {
  // Ref to AudioPlayer assigned to AudioCache
  AudioPlayer loopAudioPlayer;
  String loopSoundEffect;

  LoopAnimation(Offset position, AssetId assetId, Size size,
      MutableRectangle hitbox, String soundEffect, this.loopSoundEffect)
      : super(position, assetId, size, hitbox, soundEffect)
  { this.drawer = AnimationDrawer(assetId, this, size: size); }

  // to be sure to close the audioPlayer in background
  void stopLoopSoundEffect() async{
    // ...
    this.loopAudioPlayer = null;
  }
  void startLoopSoundEffect(){}
}

/// Class to load parameters of the weapons from a json
class WeaponStats{
  String weaponName;

  int damage;
  int range;

  bool useProjectile;

  bool isExplosive;
  bool explodeOnImpact;
  double detonationDelay;

  double ammunition;

  bool hasKnockback;
  int knockbackStrength = 0;

  double projectileWeight;
  int projectileMaxSpeed;
  double projectileFrictionFactor; // Percentage of the velocity to remove at each frame [0, 1]

  String weaponAsset;
  String projectileAsset;
  String explosionAsset;
  String explosionSound;
  Size explosionSize;
  Size projectileHitboxSize;

  int projectileEnableOrientation;

  int price;

  WeaponStats();

  WeaponStats.fromJson(Map<String, dynamic> json) {
    this.weaponName = json['weaponName'] as String;
    this.damage = json['damage'] as int;
    this.useProjectile = json['useProjectile'] as bool;
    this.isExplosive = json['isExplosive'] as bool;
    this.detonationDelay = json['detonationDelay'] as double;
    this.range = json['range'] as int;
    int ammoTmp = json['ammunition'] as int;
    this.ammunition = ammoTmp == null ? double.infinity : ammoTmp.toDouble();
    this.hasKnockback = json['hasKnockback'] as bool;
    this.knockbackStrength = json['knockbackStrength'] as int;
    this.projectileWeight = json['projectileWeight'] as double;
    this.projectileMaxSpeed = json['projectileMaxSpeed'] as int;
    this.projectileFrictionFactor = json['projectileFrictionFactor'] as double;
    this.weaponAsset = json['weaponAsset'] as String;
    this.explosionAsset = json['explosionAsset'] as String;
    this.projectileAsset = json['projectileAsset'] as String;
    this.explosionSound = json['explosionSound'] as String;
    this.explosionSize = Size(json['explosionSizeX'] as double, json['explosionSizeY'] as double);
    this.price = json['price'] as int;
    this.projectileHitboxSize = Size(json['projectileHitboxSizeX'] as double, json['projectileHitboxSizeY'] as double);
    this.projectileEnableOrientation = json['projectileOrientationEnable'] as int;
    this.explodeOnImpact = json['explodeOnImpact'] as bool;
  }

  Map<String, dynamic> toJson() {
    return {
      'weaponName': weaponName,
      'damage': damage,
      'useProjectile': useProjectile,
      'isExplosive': isExplosive,
      'detonationDelay': detonationDelay,
      'range': range,
      'ammunition': ammunition == double.infinity ? null : ammunition.toInt(),
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
      'projectileHitboxSizeX': projectileHitboxSize.width,
      'projectileHitboxSizeY': projectileHitboxSize.height,
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

