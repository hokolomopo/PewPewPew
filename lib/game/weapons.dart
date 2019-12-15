import 'dart:ui';

import 'package:info2051_2018/game/draw/assets_manager.dart';
import 'package:info2051_2018/game/draw/weapon_drawer.dart';
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
