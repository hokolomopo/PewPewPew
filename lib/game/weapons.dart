import 'dart:ui';

import 'package:info2051_2018/draw/assets_manager.dart';
import 'package:info2051_2018/draw/weapon_drawer.dart';
import 'package:info2051_2018/game/weaponry.dart';

import 'character.dart';


class Fist extends Weapon {
  static const String weaponName = "Fist";

  static final relativeSize = Size(6, 6);

  final AssetId selectionAsset = AssetId.weapon_fist_sel;

  Fist(Character owner) : super(owner) {
    this.weaponCenterOffset = Offset(1, -2);

    this.weaponSize = relativeSize;
    this.drawer =
        WeaponDrawer(AssetId.weapon_fist, this, relativeSize);
    this.name = weaponName;
  }

}

class Colt extends Weapon {
  static const String weaponName = "Colt";

  static final relativeSize = Size(6, 6);
  final AssetId selectionAsset = AssetId.weapon_colt_sel;

  Colt(Character owner) : super(owner) {
    this.weaponSize = relativeSize;
    this.weaponCenterOffset = Offset(1,-1);

    this.drawer =
        WeaponDrawer(AssetId.weapon_colt, this, Weapon.relativeSize);
    this.name = weaponName;
  }

}

class Railgun extends Weapon {
  static const String weaponName = "Railgun";

  static final relativeSize = Size(15, 7);

  final AssetId selectionAsset = AssetId.weapon_railgun_sel;

  Railgun(Character owner) : super(owner) {
    this.weaponSize = relativeSize;
    this.weaponCenterOffset = Offset(8,-4);;

    this.drawer =
        WeaponDrawer(AssetId.weapon_railgun, this, Weapon.relativeSize);
    this.name = weaponName;
  }


}

class Grenade extends Weapon {
  static const String weaponName = "Grenade";

  static final relativeSize = Size(8, 8);

  final AssetId selectionAsset = AssetId.weapon_grenade_sel;

  Grenade(Character owner) : super(owner) {
    this.weaponCenterOffset = Offset(1, -1);

    this.weaponSize = relativeSize;

    this.drawer =
        WeaponDrawer(AssetId.weapon_grenade, this, Weapon.relativeSize);
    this.name = weaponName;
  }


}

class Shotgun extends Weapon {
  static const String weaponName = "Shotgun";

  static final relativeSize = Size(10, 5);

  final AssetId selectionAsset = AssetId.weapon_shotgun_sel;

  Shotgun(Character owner) : super(owner) {
    this.weaponCenterOffset = Offset(4.5, -3);

    this.weaponSize = relativeSize;

    this.drawer =
        WeaponDrawer(AssetId.weapon_shotgun, this, Weapon.relativeSize);
    this.name = weaponName;
    this.projectileAssetId = AssetId.projectile_big_bullet;
  }
}

class Sniper extends Weapon {
  static const String weaponName = "Sniper";

  static final relativeSize = Size(12, 12);

  final AssetId selectionAsset = AssetId.weapon_sniper_sel;

  Sniper(Character owner) : super(owner) {
    this.weaponCenterOffset = Offset(5, -2);

    this.weaponSize = relativeSize;

    this.drawer =
        WeaponDrawer(AssetId.weapon_sniper, this, Weapon.relativeSize);
    this.name = weaponName;
    this.projectileAssetId = AssetId.projectile_bullet;
  }


}
