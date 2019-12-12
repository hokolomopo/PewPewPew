import 'dart:typed_data';
import 'dart:ui';
import 'dart:ui' as ui;

import 'package:flutter/services.dart';
import 'package:info2051_2018/draw/ui_drawer.dart';
import 'package:info2051_2018/game/character.dart';
import 'package:info2051_2018/game/util/utils.dart';
import 'package:info2051_2018/game/weaponry.dart';
import 'package:info2051_2018/game/weapons.dart';

enum AssetId {
  char_running,
  char_idle,
  char_jumping,
  char_death,
  background,
  projectile_boulet,
  projectile_dhs,
  projectile_laser,
  projectile_bullet,
  projectile_big_bullet,
  explosion_dhs,
  ui_arrow,
  weapon_fist,
  weapon_fist_sel,
  weapon_colt,
  weapon_colt_sel,
  weapon_grenade,
  weapon_grenade_sel,
  weapon_railgun,
  weapon_railgun_sel,
  weapon_sniper,
  weapon_sniper_sel,
  weapon_shotgun,
  weapon_shotgun_sel
}

class AssetIdMapper{

  static final Map<String, AssetId> map = {
  "explosion.gif": AssetId.explosion_dhs,
  "bullet_future": AssetId.projectile_laser,
  "bullet1": AssetId.projectile_bullet,
  "bullet3": AssetId.projectile_big_bullet,
  "bullet4": AssetId.projectile_boulet,
  "grenade": AssetId.weapon_grenade,
  "fist": AssetId.weapon_fist,
  };
}

/// An image asset. The size is in relative game size
class Asset {
  AssetId id;
  String path;
  Size size;
  int team;

  Asset(this.id, this.path, {this.size, this.team});

  String getStringId() {
    if (team != null) return id.toString() + team.toString();
    return id.toString();
  }
}

/// Class to manage the image assets of the game
class AssetsManager {
  static final String _charAssetPrefix = "assets/graphics/characters/char";
  static final String _weaponAssetPrefix = "assets/graphics/arsenal/weapons/";
  static final String _explosionAssetPrefix = "assets/graphics/arsenal/explosions/";

  //TODO fix cat death gif

  /// Default assets of the game
  final Map<AssetId, Asset> assets = {
    //TODO put good sizes for weapons
    AssetId.background: Asset(AssetId.background, null),
    AssetId.projectile_boulet: Asset(AssetId.projectile_boulet,
        "assets/graphics/arsenal/projectiles/bullet4.png"),
    AssetId.projectile_laser: Asset(AssetId.projectile_laser,
        "assets/graphics/arsenal/projectiles/bullet_future.png"),
    AssetId.projectile_bullet: Asset(AssetId.projectile_bullet,
        "assets/graphics/arsenal/projectiles/bullet1.png"),
    AssetId.projectile_big_bullet: Asset(AssetId.projectile_big_bullet,
        "assets/graphics/arsenal/projectiles/bullet3.png"),
    AssetId.projectile_dhs: Asset(AssetId.projectile_dhs,
        "assets/graphics/arsenal/projectiles/hand-spinner.gif"),
    AssetId.ui_arrow: Asset(
        AssetId.ui_arrow, "assets/graphics/user_interface/arrow.gif",
        size: MarkerDrawer.markerArrowSize),
    AssetId.weapon_fist: Asset(
        AssetId.weapon_fist, _weaponAssetPrefix + "fist.png",
        size: Fist.relativeSize),
    AssetId.weapon_fist_sel: Asset(
        AssetId.weapon_fist_sel, _weaponAssetPrefix + "fist.png",
        size: Size(Arsenal.selectionElementSize.width, Arsenal.selectionElementSize.height)),
    AssetId.weapon_colt: Asset(
        AssetId.weapon_colt, _weaponAssetPrefix + "colt_45.png",
        size: Colt.relativeSize),
    AssetId.weapon_colt_sel: Asset(
        AssetId.weapon_colt_sel, _weaponAssetPrefix + "colt_45.png",
        size: Size(Arsenal.selectionElementSize.width, Arsenal.selectionElementSize.height)),
    AssetId.weapon_grenade: Asset(
        AssetId.weapon_grenade, _weaponAssetPrefix + "grenade2_nopin.png",
        size: Grenade.relativeSize),
    AssetId.weapon_grenade_sel: Asset(
        AssetId.weapon_grenade_sel, _weaponAssetPrefix + "grenade2_nopin.png",
        size: Size(Arsenal.selectionElementSize.width, Arsenal.selectionElementSize.height)),
    AssetId.weapon_railgun: Asset(
        AssetId.weapon_railgun, _weaponAssetPrefix + "future_gun.png",
        size: Railgun.relativeSize),
    AssetId.weapon_railgun_sel: Asset(
        AssetId.weapon_railgun_sel, _weaponAssetPrefix + "future_gun.png",
        size: Size(Arsenal.selectionElementSize.width, Arsenal.selectionElementSize.height)),
    AssetId.weapon_shotgun: Asset(
        AssetId.weapon_shotgun, _weaponAssetPrefix + "shotgun.png",
        size: Shotgun.relativeSize),
    AssetId.weapon_shotgun_sel: Asset(
        AssetId.weapon_shotgun_sel, _weaponAssetPrefix + "shotgun.png",
        size: Size(Arsenal.selectionElementSize.width, Arsenal.selectionElementSize.height)),
    AssetId.weapon_sniper: Asset(
        AssetId.weapon_sniper, _weaponAssetPrefix + "sniper.png",
        size: Sniper.relativeSize),
    AssetId.weapon_sniper_sel: Asset(
        AssetId.weapon_sniper_sel, _weaponAssetPrefix + "sniper.png",
        size: Size(Arsenal.selectionElementSize.width, 4)),

    AssetId.explosion_dhs:
        Asset(AssetId.explosion_dhs, _explosionAssetPrefix + "explosion.gif"),
  };

  Map<String, Size> _currentlyLoading = Map();
  Map<String, Map<Size, List<MyFrameInfo>>> _loadedAssets = Map();

  Size _screenSize;
  int _numberOfPlayers;

  AssetsManager(Size levelSize, String backgroundPath, this._numberOfPlayers) {
    assets[AssetId.background].size = levelSize;
    assets[AssetId.background].path = backgroundPath;
  }

  /// Initialize the asset manager with the size of the screen. This must be called
  /// before anything else
  void init(Size screenSize) {
    this._screenSize = screenSize;
  }

  /// Load the default assets of the game
  void preLoadAssets() async {
    for (Asset asset in assets.values) {
      await _loadGif(asset);
    }
    await _loadCharactersAssets();
  }

  _loadCharactersAssets() async {
    for (int i = 0; i < _numberOfPlayers; i++) {
      await _loadGif(Asset(
          AssetId.char_idle, _charAssetPrefix + i.toString() + "_idle.gif",
          size: Character.spriteSize, team: i));
      await _loadGif(Asset(
          AssetId.char_running, _charAssetPrefix + i.toString() + "_run.gif",
          size: Character.spriteSize, team: i));
      await _loadGif(Asset(
          AssetId.char_jumping, _charAssetPrefix + i.toString() + "_jump.gif",
          size: Character.spriteSize, team: i));
      await _loadGif(Asset(
          AssetId.char_death, _charAssetPrefix + i.toString() + "_death.gif",
          size: Character.spriteSize, team: i));
    }
  }

  /// Load a gif file (or a png, which we consider as a one frame gif)
  _loadGif(Asset asset) async {
    print("Loading " + asset.path + " of size " + asset.size.toString());

    // Cannot load without a size
    if (asset.size == null) return;

    // Check if asset is not already loaded
    if (this._loadedAssets.containsKey(asset.getStringId()) &&
        this._loadedAssets[asset.getStringId()].containsKey(asset.size)) return;

    // Check if asset is not already loading
    if (this._currentlyLoading.containsKey(asset.getStringId()) &&
        _currentlyLoading[asset.getStringId()] == asset.size) {
      print("Asset already loading");
      return;
    }

    _currentlyLoading.putIfAbsent(asset.getStringId(), () => asset.size);

    // Get absolute size
    List<MyFrameInfo> curGif = List();
    int targetWidth =
        GameUtils.relativeToAbsoluteDist(asset.size.width, _screenSize.height)
            .toInt();
    int targetHeight =
        GameUtils.relativeToAbsoluteDist(asset.size.height, _screenSize.height)
            .toInt();

    // Load gif
    Uint8List gifBytes =
        (await rootBundle.load(asset.path)).buffer.asUint8List();
    ui.Codec codec = await ui.instantiateImageCodec(gifBytes);

    ui.FrameInfo info;
    ui.Image img;
    Uint8List byteData;
    for (int i = 0; i < codec.frameCount; i++) {
      info = await codec.getNextFrame();
      img = info.image;
      byteData = (await img.toByteData()).buffer.asUint8List();

      // resize frame
      ui.decodeImageFromPixels(
          byteData, img.width, img.height, ui.PixelFormat.rgba8888,
          (ui.Image result) {
        curGif.add(MyFrameInfo(info.duration, result));
      }, targetWidth: targetWidth, targetHeight: targetHeight);
    }

    // Add asset to loaded assets
    Map<Size, List<MyFrameInfo>> curSizes =
        this._loadedAssets.putIfAbsent(asset.getStringId(), () => Map());
    curSizes.putIfAbsent(asset.size, () => curGif);

    _currentlyLoading.remove(asset.getStringId());
    return;
  }

  // Load an asset
  void loadAsset(AssetId assetId, Size size, {int team}) async {
    if (isAssetLoaded(assetId, size)) return;

    // This happens if we try do display a character before the asset is ready
    if (assets[assetId] == null) return;

    await this
        ._loadGif(Asset(assetId, assets[assetId].path, size: size, team: team));
  }

  bool isAssetLoaded(AssetId assetId, Size size, {int team}) {
    Asset searched = Asset(assetId, null, size: size, team: team);
    return _loadedAssets.containsKey(searched.getStringId()) &&
        _loadedAssets[searched.getStringId()].containsKey(size);
  }

  GifInfo getGifInfo(AssetId assetId, Size size, {int team}) {
    if (!isAssetLoaded(assetId, size, team: team)) return null;

    Asset searched = Asset(assetId, null, size: size, team: team);
    return GifInfo(_loadedAssets[searched.getStringId()][size]);
  }

  static double getHeightRatio(Size s) => s.height / s.width;
}

/// Information about a frame
class MyFrameInfo {
  Duration duration;
  Image image;
  DateTime addedTimestamp;

  MyFrameInfo(this.duration, this.image, [this.addedTimestamp]);
}

/// Information about a gif
class GifInfo {
  List<MyFrameInfo> gif;
  DateTime lastFetch;
  int curFrameIndex = 0;
  double speed = 1;

  // For projectile which get stuck
  bool _lockAnimation = false;

  GifInfo(this.gif);

  /// Get the next frame of the gif
  Image fetchNextFrame() {
    if (gif.length < 1) return null;

    if (_lockAnimation) return gif[curFrameIndex].image;

    // Check if we must change the frame of the gif
    DateTime curTime = DateTime.now();
    double curDuration =
        gif[curFrameIndex].duration.inMilliseconds.toDouble() / speed;
    if (lastFetch == null ||
        curTime.difference(lastFetch).inMilliseconds > curDuration) {
      lastFetch = curTime;
      if (curFrameIndex == gif.length - 1)
        curFrameIndex = 0;
      else
        curFrameIndex += 1;
    }

    return gif[curFrameIndex].image;
  }

  void freezeGif({int frameNumber}) {
    if (frameNumber != null) {
      if (frameNumber > gif.length - 1)
        curFrameIndex = 0;
      else
        curFrameIndex = frameNumber;
    }

    _lockAnimation = true;
  }

  void unfreezeGif() {
    _lockAnimation = false;
  }
}
