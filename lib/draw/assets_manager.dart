
import 'dart:typed_data';
import 'dart:ui';
import 'dart:ui' as ui;

import 'package:flutter/services.dart';
import 'package:info2051_2018/game/character.dart';
import 'package:info2051_2018/game/util/utils.dart';

enum AssetId{char_running, char_idle, background, projectile_boulet, projectile_dhs,
}

/// An image asset. The size is in relative game size
class Asset{
  AssetId id;
  String path;
  Size size;

  Asset(this.id, this.path, {this.size});
}

/// Class to manage the image assets of the game
class AssetsManager{

  /// Default assets of the game
  final Map<AssetId, Asset> assets = {
    AssetId.char_running:Asset(AssetId.char_running, "assets/graphics/characters/char1_run.gif", size:Character.characterSpriteSize),
    AssetId.char_idle:Asset(AssetId.char_idle, "assets/graphics/characters/char1_idle.gif", size:Character.characterSpriteSize),
    AssetId.background:Asset(AssetId.background, "assets/graphics/backgrounds/default_background.png"),
    AssetId.projectile_boulet:Asset(AssetId.projectile_boulet, "assets/graphics/arsenal/projectiles/red_arc.gif"),
    AssetId.projectile_dhs:Asset(AssetId.projectile_dhs, "assets/graphics/arsenal/projectiles/hand-spinner.gif"),
  };

  Map<AssetId, Map<Size, List<MyFrameInfo>>> _loadedAssets = Map();

  Size _screenSize;

  AssetsManager(Size levelSize){
    assets[AssetId.background].size = levelSize;
  }

  /// Initialize the asset manager with the size of the screen. Thi must be called
  /// before anything else
  void init(Size screenSize){
    this._screenSize = screenSize;
  }

  /// Load the default assets of the game
  void preLoadAssets() async{
    for (Asset asset in assets.values) {
        await _loadGif(asset);
    }
  }

  /// Load a gif file (or a png, which we consider as a one frame gif)
  _loadGif(Asset asset) async {
    // Cannot load without a size
    if(asset.size == null)
      return;

    // Check if asset is not already loaded
    if (this._loadedAssets.containsKey(asset.id) &&
        this._loadedAssets[asset.id].containsKey(asset.size))
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
    Map<Size, List<MyFrameInfo>> curSizes = this._loadedAssets.putIfAbsent(asset.id, () => Map());
    curSizes.putIfAbsent(asset.size, () => curGif);
    return;
  }

  // Load an asset
  void loadAsset(AssetId assetId, Size size){
    if(isAssetLoaded(assetId, size))
      return;

    this._loadGif(Asset(assetId, assets[assetId].path, size:size));
  }

  bool isAssetLoaded(AssetId assetId, Size size){
    return _loadedAssets.containsKey(assetId) &&
        _loadedAssets[assetId].containsKey(size);
  }

  GifInfo getGifInfo(AssetId assetId, Size size){
    if(!isAssetLoaded(assetId, size))
      return null;

    return GifInfo(_loadedAssets[assetId][size]);
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

  // For projectile which get stuck
  bool _lockAnimation = false;

  GifInfo(this.gif);

  /// Get the next frame of the gif
  Image fetchNextFrame() {
    if (gif.length < 1) return null;

    if (_lockAnimation)
      return gif[curFrameIndex].image;

    // Check if we must change the frame of the gif
    DateTime curTime = DateTime.now();
    Duration curDuration = gif[curFrameIndex].duration;
    if (lastFetch == null || curTime.difference(lastFetch) > curDuration) {
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
