import 'dart:math';
import 'dart:ui';

import 'package:info2051_2018/draw/assets_manager.dart';
import 'package:info2051_2018/draw/level_painter.dart';
import 'package:info2051_2018/draw/weapon_drawer.dart';
import 'package:info2051_2018/game/ui_manager.dart';
import 'package:info2051_2018/game/util/team.dart';
import 'package:info2051_2018/game/weaponry.dart';
import 'package:info2051_2018/game/world.dart';

import 'character.dart';


class Fist extends Weapon {
  static const String weaponName = "Fist";

  static final relativeSize = Weapon.relativeSize;

  final AssetId selectionAsset = AssetId.weapon_fist_sel;

  Fist(Character owner) : super(owner) {
    this.drawer =
        WeaponDrawer(AssetId.weapon_fist, this, Weapon.relativeSize);
    this.name = weaponName;
    this.projectileAssetId = AssetId.projectile_dhs;
  }

  // TODO put end logic in weapon instead of gameState
  void proceedToEnd(Projectile projectile, List<Team> characters,
      Function statUpdater, UiManager uiManager, World world, LevelPainter levelPainter){}

}

class Colt extends Weapon {
  static const String weaponName = "Colt";

  static final relativeSize = Weapon.relativeSize;
  final AssetId selectionAsset = AssetId.weapon_colt_sel;

  Colt(Character owner) : super(owner) {
    this.drawer =
        WeaponDrawer(AssetId.weapon_colt_sel, this, Weapon.relativeSize);
    this.name = weaponName;
    this.projectileAssetId = AssetId.projectile_dhs;
  }

  void proceedToEnd(Projectile projectile, List<Team> characters,
      Function statUpdater, UiManager uiManager, World world, LevelPainter levelPainter){}
}

class Railgun extends Weapon {
  static const String weaponName = "Railgun";

  static final relativeSize = Weapon.relativeSize;

  final AssetId selectionAsset = AssetId.weapon_railgun_sel;

  Railgun(Character owner) : super(owner) {
    this.drawer =
        WeaponDrawer(AssetId.weapon_railgun, this, Weapon.relativeSize);
    this.name = weaponName;
    this.projectileAssetId = AssetId.projectile_dhs;
  }

  // TODO put end logic in weapon instead of gameState
  void proceedToEnd(Projectile projectile, List<Team> characters,
      Function statUpdater, UiManager uiManager, World world, LevelPainter levelPainter){}

}

class Grenade extends Weapon {
  static const String weaponName = "Grenade";

  static final relativeSize = Weapon.relativeSize;

  final AssetId selectionAsset = AssetId.weapon_grenade_sel;

  Grenade(Character owner) : super(owner) {
    this.drawer =
        WeaponDrawer(AssetId.weapon_grenade, this, Weapon.relativeSize);
    this.name = weaponName;
    this.projectileAssetId = AssetId.projectile_dhs;
  }

  // TODO put end logic in weapon instead of gameState
  void proceedToEnd(Projectile projectile, List<Team> characters,
      Function statUpdater, UiManager uiManager, World world, LevelPainter levelPainter){}

}

class Shotgun extends Weapon {
  static const String weaponName = "Shotgun";

  static final relativeSize = Weapon.relativeSize;

  final AssetId selectionAsset = AssetId.weapon_shotgun_sel;

  Shotgun(Character owner) : super(owner) {
    this.drawer =
        WeaponDrawer(AssetId.weapon_shotgun, this, Weapon.relativeSize);
    this.name = weaponName;
    this.projectileAssetId = AssetId.projectile_dhs;
  }

  // TODO put end logic in weapon instead of gameState
  void proceedToEnd(Projectile projectile, List<Team> characters,
      Function statUpdater, UiManager uiManager, World world, LevelPainter levelPainter){}

}

class Sniper extends Weapon {
  static const String weaponName = "Sniper";

  static final relativeSize = Weapon.relativeSize;

  final AssetId selectionAsset = AssetId.weapon_sniper_sel;

  Sniper(Character owner) : super(owner) {
    this.drawer =
        WeaponDrawer(AssetId.weapon_sniper, this, Weapon.relativeSize);
    this.name = weaponName;
    this.projectileAssetId = AssetId.projectile_dhs;
  }

  // TODO put end logic in weapon instead of gameState
  void proceedToEnd(Projectile projectile, List<Team> characters,
      Function statUpdater, UiManager uiManager, World world, LevelPainter levelPainter){}

}
