import 'dart:convert';
import 'dart:math';
import 'dart:ui';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:info2051_2018/draw/drawer_abstracts.dart';
import 'package:info2051_2018/draw/level_painter.dart';
import 'package:info2051_2018/draw/projectile_drawer.dart';
import 'package:info2051_2018/draw/assets_manager.dart';
import 'package:info2051_2018/draw/text_drawer.dart';
import 'package:info2051_2018/game/entity.dart';
import 'package:info2051_2018/game/game_main.dart';
import 'package:info2051_2018/game/ui_manager.dart';
import 'package:info2051_2018/game/util/team.dart';
import 'package:info2051_2018/game/util/utils.dart';
import 'package:info2051_2018/game/weaponry_concrete_tmpname.dart';
import 'package:info2051_2018/game/world.dart';
import 'package:info2051_2018/sound_player.dart';

import 'character.dart';

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

      Weapon weapon = Weapon.fromWeaponStats(owner, stats);

      arsenal.add(weapon);
    }
  }


  showWeaponSelection(MutableRectangle charHitBox) {
    // The formula does not work with a single element, as we can't put
    // any distance between an element and itself.
    double angleBetweenElem = min(pi, 2 * pi / arsenal.length);
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
    w.range = weaponStats.damage;
    w.useProjectile = weaponStats.useProjectile;
    w.isExplosive = weaponStats.isExplosive;
    w.detonationDelay = weaponStats.detonationDelay;
    w.ammunition = weaponStats.ammunition;
    w.hasKnockback = weaponStats.hasKnockback;
    w.knockbackStrength = weaponStats.knockbackStrength;

    return w;
  }

  AssetId projectileAssetId;
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

  void prepareFiring(Offset position){
    WeaponStats stats = GameMain.availableWeapons[this.name];
    MutableRectangle hitbox = MutableRectangle(position.dx, position.dy,
        stats.projectileHitboxSize.width, stats.projectileHitboxSize.height);

    this.projectile = Projectile.fromWeaponStats(Offset(position.dx, position.dy),
        hitbox, projectileAssetId, GameMain.availableWeapons[this.name]);
  }

  Projectile fireProjectile(Offset direction) {
    // TODO horizontal checks
    direction = this.projectile.getLaunchSpeed(direction);

    this.projectile.velocity += direction;

    return projectile;
  }

  //TODO decide if methods better in Weapon or corresponding Projectile
  // Should be an overridable function to get different behaviour for other weapon

  /// Function to proceed all the end logic of a projectile (explosion sprite,
  /// damage, painters, ...)
  /// TODO put end logic in weapon instead of gameState
  void proceedToEnd(Projectile projectile, List<Team> characters,
      Function statUpdater, UiManager uiManager, World world, LevelPainter levelPainter);

  ///Function which apply Damage and knockback to characters according to
  /// its actual position and range.
  void applyImpact(Projectile projectile, List<Team> characters,
      Function statUpdater, UiManager uiManager) {
    Character curChar;
    for (int i = 0; i < characters.length; i++) {
      for (int j = 0; j < characters[i].length; j++) {
        curChar = characters[i].getCharacter(j);
        // apply a circular HitBox

        double dist =
            (projectile.getPosition() - curChar.getPosition()).distance;

        if (dist <= range) {
          // Apply damage reduce according to dist [33% - 100%]
          double effectiveDamage =
              damage.toDouble() * (1.0 + 2.0 * (range - dist) / range) / 3.0;

          // Update stats
          double damageDealt = min(effectiveDamage, curChar.hp);

          uiManager.addText(
              "-" + damageDealt.ceil().toString(), TextPositions.custom, 25,
              customPosition: curChar.getPosition() + Character.dmgTextOffset,
              duration: 3,
              fadeDuration: 2,
              color: Colors.red);

          statUpdater(TeamStat.damage_dealt, damageDealt, teamTakingAttack: i);

          if (curChar.hp == 0)
            statUpdater(TeamStat.killed, 1, teamTakingAttack: i);

          curChar.removeHp(damageDealt);

          // Apply a vector field for knockback
          Offset projection = curChar.getPosition() - projectile.getPosition();

          // Normalize offset
          projection /= projection.dx + projection.dy;

          // The closer to the center of detonation the stronger the knockback
          // Factor from 0% to 100%
          projection *= (range - dist) / range;
          // Applied factor for knockback strengh
          projection *= knockbackStrength.toDouble();
          curChar.addVelocity(projection);
        }
      }
    }
  }

}
abstract class Projectile extends MovingEntity {
  AssetId explosionAssetId;
  AssetId assetId;

  double weight;
  int maxSpeed;
  double frictionFactor; // Percentage of the velocity to remove at each frame [0, 1]

  String explosionSound;
  Size explosionSize;

  // For projectile which need orientation [Like arrows]
  // expressed in radian in a clockwise way
  double actualOrientation = -1; // < 0 means not rotation

  factory Projectile.fromWeaponStats(Offset position, MutableRectangle<num> hitbox, AssetId projectileAsset, WeaponStats weaponStats){
    Projectile p;
    if(weaponStats.isExplosive)
      p = ExplosiveProjectile(position, hitbox);
    else
      p = CollidableProjectile(position, hitbox);

    p.assetId = projectileAsset;
    p.weight = weaponStats.projectileWeight;
    p.maxSpeed = weaponStats.projectileMaxSpeed;
    p.frictionFactor = weaponStats.projectileFrictionFactor;
    p.explosionSound = weaponStats.explosionSound;
    p.explosionSize = weaponStats.explosionSize;
    p.drawer = ProjectileDrawer(projectileAsset, p, size:weaponStats.projectileHitboxSize);

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
    if (frictionFactor == 1) drawer.freezeAnimation();
  }

  // Have to be override by children
  MyAnimation returnAnimationInstance() {
    return null;
  }

  ///Function to play a sound effect at the start of the launch
  void playStartSound(){}

  /// Function to proceed all the end logic of a projectile (explosion sprite,
  /// damage, painters, ...)
  void proceedToEnd(Projectile projectile, List<Team> characters,
      Function statUpdater, UiManager uiManager, World world, LevelPainter levelPainter){}

}

/// Class to implement projectile which react a command (onTap for instance),
/// While being launch
/// (Arrow changing direction once on onTap, C4, leGrandMathy (une arme qui oneshot le char onTapped), ... )
abstract class Controllable extends Projectile{

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
  // TODO change following constructor copied from previous test projectile
  ExplosiveProjectile(position, Rectangle hitbox): super(position, hitbox);

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
// TODO method in World check projectile collision, if not Collidable just return false,
// else apply method
class CollidableProjectile extends Projectile {
  CollidableProjectile(position, Rectangle hitbox): super(position, hitbox);
}

/// Mixin class for projectile which are not influence by gravity, Linear
/// (Bullets, Rays, Magic orbs, ...)
abstract class Linear{}

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
  // TODO put if (audioplayer not null)
  void startLoopSoundEffect(){}
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
  Size projectileHitboxSize;

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
    this.price = json['price'] as int;
    this.projectileHitboxSize = Size(json['projectileHitboxSizeX'] as double, json['projectileHitboxSizeY'] as double);
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