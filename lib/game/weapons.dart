import 'dart:math';
import 'dart:ui';

import 'package:info2051_2018/game/draw/assets_manager.dart';
import 'package:info2051_2018/game/draw/projectile_drawer.dart';
import 'package:info2051_2018/game/draw/weapon_drawer.dart';
import 'package:info2051_2018/game/game_main.dart';
import 'package:info2051_2018/game/weaponry.dart';

import 'character.dart';


class Fist extends Weapon {
  static const String weaponName = "Fist";

  final Size relativeSize = Size(6, 6);
  final Offset weaponCenterOffset = Offset(1, -2);

  Fist(Character owner) : super(owner) {
    this.drawer =
        WeaponDrawer(AssetId.weapon_fist, this, Arsenal.selectionElementSize);
    this.name = weaponName;
  }

}

class Colt extends Weapon {
  static const String weaponName = "Colt";

  final Size relativeSize = Size(6, 6);
  final Offset weaponCenterOffset = Offset(1, -1);

  Colt(Character owner) : super(owner) {
    this.drawer =
        WeaponDrawer(AssetId.weapon_colt, this, Arsenal.selectionElementSize);
    this.name = weaponName;
  }

}

class Railgun extends Weapon {
  static const String weaponName = "Railgun";

  final Size relativeSize = Size(15, 7);
  final Offset weaponCenterOffset = Offset(8, -3);

  Railgun(Character owner) : super(owner) {
    this.drawer =
        WeaponDrawer(AssetId.weapon_railgun, this, Arsenal.selectionElementSize);
    this.name = weaponName;
  }


}

class Grenade extends Weapon {
  static const String weaponName = "Grenade";

  final Size relativeSize = Size(8, 8);
  final Offset weaponCenterOffset = Offset(1, -1);

  Grenade(Character owner) : super(owner) {
    this.drawer =
        WeaponDrawer(AssetId.weapon_grenade, this, Arsenal.selectionElementSize);
    this.name = weaponName;
  }
}

class Shotgun extends Weapon {
  static const String weaponName = "Shotgun";

  final Size relativeSize = Size(10, 5);
  final Offset weaponCenterOffset = Offset(4.5, -3);

  Shotgun(Character owner) : super(owner) {
    this.drawer =
        WeaponDrawer(AssetId.weapon_shotgun, this, Arsenal.selectionElementSize);
    this.name = weaponName;
    this.projectileAssetId = AssetId.projectile_big_bullet;
  }
}

class Sniper extends Weapon {
  static const String weaponName = "Sniper";

  final Size relativeSize = Size(12, 12);
  final Offset weaponCenterOffset = Offset(5, -2);

  Sniper(Character owner) : super(owner) {
    this.drawer =
        WeaponDrawer(AssetId.weapon_sniper, this, Arsenal.selectionElementSize);
    this.name = weaponName;
    this.projectileAssetId = AssetId.projectile_bullet;
  }
}

class Bow extends Weapon {
  static const String weaponName = "Draconic Bow";

  final Size relativeSize = Size(10, 8);
  final Offset weaponCenterOffset = Offset(4, -2);

  Bow(Character owner) : super(owner) {
    this.drawer =
        WeaponDrawer(AssetId.weapon_bow, this, Arsenal.selectionElementSize);
    this.name = weaponName;
    this.projectileAssetId = AssetId.projectile_arrow;
  }
}

class BloodMagic extends Weapon {
  static const String weaponName = "Blood Magic";

  final Size relativeSize = Size(10, 8);
  final Offset weaponCenterOffset = Offset(4, -2);

  BloodMagic(Character owner) : super(owner) {
    this.drawer =
        WeaponDrawer(AssetId.weapon_blood_magic, this, Arsenal.selectionElementSize);
    this.name = weaponName;
    this.projectileAssetId = AssetId.projectile_blood_magic;
  }

  // Override to add 3 projectiles
  @override
  void prepareFiring(Character char){
    if(char == null)
      return;
    this.projectiles = List();
    WeaponStats stats = GameMain.availableWeapons[this.name];
    double projectileX = char.hitbox.left;
    double projectileY = char.hitbox.top;
    for (int i = 0; i < 3; i++)
      this.projectiles.add(
          Projectile.fromWeaponStats(Offset(projectileX, projectileY),
              MutableRectangle(projectileX, projectileY,
                  stats.projectileHitboxSize.width,
                  stats.projectileHitboxSize.height), projectileAssetId,
              GameMain.availableWeapons[this.name]));
  }

  @override
  List<Projectile> fireProjectile(Offset direction, Character char){
    List<Projectile> projs = super.fireProjectile(direction, char);

    double radianAngle = 0.0;
    double radianIncrementation = pi/12; // 15°


    // Leave first offset unchanged
    for (int i = 1; i < projs.length; i++){
      radianAngle = projs[i].velocity.direction;
      if(i.isOdd){
        radianAngle += radianIncrementation * (i+1)/2;
      }
      else{
        radianAngle -= radianIncrementation * (i+1)/2;
      }
      projs[i].velocity = Offset.fromDirection(radianAngle,projs[i].velocity.distance);
      projs[i].addDetonationDelay(i*1000); // Add 200 ms detonation delay
    }

//    // Invert knockback direction effect
//    for(Projectile p in projs){
//      p.knockBackStrength *= -1;
//    }

    return projs;

  }
}


class L_Arrow extends Controllable{
  static const String projectileName = "L_Arrow";

  L_Arrow(Offset position, Rectangle hitbox): super(position, hitbox){
    onTapListener = true;
    weight = 0;
  }

  @override
  void onTap(Offset tapPosition) {
    Offset direction = tapPosition - getPosition();
    direction /= direction.distance;

    velocity = direction * velocity.distance;

    onTapListener = false;
  }

}

class FlappyBird extends Controllable{
  static const String projectileName = "FlappyBird";

  FlappyBird(Offset position, Rectangle hitbox): super(position, hitbox){
    onTapListener = true;
  }

  @override
  void onTap(Offset tapPosition) {
    Offset direction = tapPosition - getPosition();
    direction /= direction.distance;
    direction *= 10.0;
    stop();
    setXSpeed(direction.dx);
    setYSpeed(direction.dy);

  }

}