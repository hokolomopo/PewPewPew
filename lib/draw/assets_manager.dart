
import 'dart:typed_data';
import 'dart:ui';
import 'dart:ui' as ui;

import 'package:flutter/services.dart';
import 'package:info2051_2018/draw/ui_drawer.dart';
import 'package:info2051_2018/game/character.dart';
import 'package:info2051_2018/game/util/utils.dart';

enum AssetId{
  char_running, char_idle, char_jumping, char_death, background,
  projectile_boulet, projectile_dhs, ui_arrow
}

/// An image asset. The size is in relative game size
class Asset{
  AssetId id;
  String path;
  Size size;
  int team;

  Asset(this.id, this.path, {this.size, this.team});

  String getStringId(){
    if(team != null)
      return id.toString() + team.toString();
    return id.toString();
  }
}

/// Class to manage the image assets of the game
class AssetsManager{
  static final String _charAssetPrefix = "assets/graphics/characters/char";
  //TODO fix cat death gif

  /// Default assets of the game
  final Map<AssetId, Asset> assets = {//TODO put size for projectiles
    AssetId.background:Asset(AssetId.background, "assets/graphics/backgrounds/default_background.png"),
    AssetId.projectile_boulet:Asset(AssetId.projectile_boulet, "assets/graphics/arsenal/projectiles/red_arc.gif"),
    AssetId.projectile_dhs:Asset(AssetId.projectile_dhs, "assets/graphics/arsenal/projectiles/hand-spinner.gif"),
    AssetId.ui_arrow:Asset(AssetId.ui_arrow, "assets/graphics/user_interface/arrow.gif", size: MarkerDrawer.markerArrowSize),
  };

  Map<String, Map<Size, List<MyFrameInfo>>> _loadedAssets = Map();

  Size _screenSize;
  int _numberOfPlayers;

  AssetsManager(Size levelSize, this._numberOfPlayers){
    assets[AssetId.background].size = levelSize;
  }

  /// Initialize the asset manager with the size of the screen. This must be called
  /// before anything else
  void init(Size screenSize){
    this._screenSize = screenSize;
  }

  /// Load the default assets of the game
  void preLoadAssets() async{
    for (Asset asset in assets.values) {
        await _loadGif(asset);
    }
    await _loadCharactersAssets();
  }

  _loadCharactersAssets() async{
    for(int i =0;i < _numberOfPlayers;i++){
      await _loadGif(Asset(AssetId.char_idle, _charAssetPrefix + i.toString()  + "_idle.gif", size:Character.characterSpriteSize, team: i));
      await _loadGif(Asset(AssetId.char_running, _charAssetPrefix + i.toString()  + "_run.gif", size:Character.characterSpriteSize, team: i));
      await _loadGif(Asset(AssetId.char_jumping, _charAssetPrefix + i.toString()  + "_jump.gif", size:Character.characterSpriteSize, team: i));
      await _loadGif(Asset(AssetId.char_death, _charAssetPrefix + i.toString()  + "_death.gif", size:Character.characterSpriteSize, team: i));
    }
  }

  /// Load a gif file (or a png, which we consider as a one frame gif)
  _loadGif(Asset asset) async {
    // Cannot load without a size
    if(asset.size == null)
      return;

    // Check if asset is not already loaded
    if (this._loadedAssets.containsKey(asset.getStringId()) &&
        this._loadedAssets[asset.getStringId()].containsKey(asset.size))
      return;

    // Get absolute size
    List<MyFrameInfo> curGif = List();
    int targetWidth = GameUtils.relativeToAbsoluteDist(asset.size.width, _screenSize.height).toInt();
    int targetHeight = GameUtils.relativeToAbsoluteDist(asset.size.height, _screenSize.height).toInt();

    // Load image
    Uint8List gifBytes = (await rootBundle.load(asset.path)).buffer.asUint8List();
    ui.Codec codec = await ui.instantiateImageCodec(gifBytes);

    ui.FrameInfo info;
    ui.Image img;
    Uint8List byteData;
    for (int i = 0; i < codec.frameCount; i++) {
      info = await codec.getNextFrame();
      img = info.image;
      byteData = (await img.toByteData()).buffer.asUint8List();

      ui.decodeImageFromPixels(
          byteData, img.width, img.height, ui.PixelFormat.rgba8888,
              (ui.Image result) {
            curGif.add(MyFrameInfo(info.duration, result));
          }, targetWidth: targetWidth, targetHeight: targetHeight);
    }

    // Add asset to loaded assets
    Map<Size, List<MyFrameInfo>> curSizes = this._loadedAssets.putIfAbsent(asset.getStringId(), () => Map());
    curSizes.putIfAbsent(asset.size, () => curGif);
    return;
  }

  // Load an asset
  void loadAsset(AssetId assetId, Size size, {int team}) async{
    if(isAssetLoaded(assetId, size))
      return;

    // This happens if we try do display a character before the asset is ready
    if(assets[assetId] == null)
      return;

    await this._loadGif(Asset(assetId, assets[assetId].path, size:size, team: team));
  }

  bool isAssetLoaded(AssetId assetId, Size size, {int team}){
    Asset searched = Asset(assetId, null, size: size, team: team);
    return _loadedAssets.containsKey(searched.getStringId()) &&
        _loadedAssets[searched.getStringId()].containsKey(size);
  }

  GifInfo getGifInfo(AssetId assetId, Size size, {int team}){
    if(!isAssetLoaded(assetId, size, team: team))
      return null;

    Asset searched = Asset(assetId, null, size: size, team: team);
    return GifInfo(_loadedAssets[searched.getStringId()][size]);
  }

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
    if (gif.length < 1)
      return null;

    if (_lockAnimation)
      return gif[curFrameIndex].image;

    // Check if we must change the frame of the gif
    DateTime curTime = DateTime.now();
    double curDuration = gif[curFrameIndex].duration.inMilliseconds.toDouble() / speed;
    if (lastFetch == null || curTime.difference(lastFetch).inMilliseconds > curDuration) {
      lastFetch = curTime;
      if (curFrameIndex == gif.length - 1)
        curFrameIndex = 0;
      else
        curFrameIndex += 1;
    }

    return gif[curFrameIndex].image;
  }

  void freezeGif({int frameNumber}){
    if(frameNumber != null)
      curFrameIndex = frameNumber;
    _lockAnimation = true;
  }
}