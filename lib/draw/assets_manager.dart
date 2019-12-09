
import 'dart:typed_data';
import 'dart:ui';
import 'dart:ui' as ui;

import 'package:flutter/services.dart';
import 'package:info2051_2018/game/util/utils.dart';

enum AssetId{char_running, char_idle, background, projectile_boulet, projectile_dhs,
}

class Asset{
  AssetId id;
  String path;
  Size size;

  Asset(this.id, this.path, {this.size});

}

class AssetsManager{

  final Map<AssetId, Asset> assets = {
    AssetId.char_running:Asset(AssetId.char_running, "assets/graphics/characters/char1_run.gif", size:Size(10,10)),
    AssetId.char_idle:Asset(AssetId.char_idle, "assets/graphics/characters/char1_idle.gif", size:Size(10,10)),
    AssetId.background:Asset(AssetId.background, "assets/graphics/user_interface/animated-worm-image-0090.gif"),
    AssetId.projectile_boulet:Asset(AssetId.projectile_boulet, "assets/graphics/arsenal/projectiles/red_arc.gif"),
    AssetId.projectile_dhs:Asset(AssetId.projectile_dhs, "assets/graphics/arsenal/projectiles/hand-spinner.gif"),
  };

  Map<AssetId, Map<Size, List<MyFrameInfo>>> loadedAssets = Map();

  Size screenSize;

  AssetsManager(Size levelSize){
    assets[AssetId.background].size = levelSize;
  }

  void init(Size screenSize){
    this.screenSize = screenSize;
  }

  void preLoadAssets() async{
    for (Asset asset in assets.values) {
        await addGif(asset);
    }
  }

  addGif(Asset asset) async {
    if(asset.size == null)
      return;
    if (this.loadedAssets.containsKey(asset.id) &&
        this.loadedAssets[asset.id].containsKey(asset.size))
      return;

    List<MyFrameInfo> curGif = List();
    int targetWidth =
    GameUtils.relativeToAbsoluteDist(asset.size.width, screenSize.height)
        .toInt();
    int targetHeight =
    GameUtils.relativeToAbsoluteDist(asset.size.height, screenSize.height)
        .toInt();

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

    Map<Size, List<MyFrameInfo>> curSizes =
    this.loadedAssets.putIfAbsent(asset.id, () => Map());
    curSizes.putIfAbsent(asset.size, () => curGif);
    return;
  }

//  MyFrameInfo getFrameInfo(AssetId id, Size size){
//    if (this.loadedAssets.containsKey(asset.id) &&
//        this.loadedAssets[asset.id].containsKey(asset.size))
//      return this.loadedAssets[asset.id][size];
//
//    return null;
//  }

  void loadAsset(AssetId assetId, Size size){
    Asset defaultAsset = assets[assetId];
    if(defaultAsset.size == size)
      return;
    this.addGif(Asset(assetId, defaultAsset.path, size:size));
  }


}

/// ui.FrameInfo is an interface
class MyFrameInfo {
  Duration duration;
  Image image;
  DateTime addedTimestamp;

  MyFrameInfo(this.duration, this.image, [this.addedTimestamp]);
}

class GifInfo {
  List<MyFrameInfo> gif;
  DateTime lastFetch;
  int curFrameIndex = 0;

  // For projectile which get stuck
  bool lockAnimation = false;

  GifInfo(this.gif);

  Image fetchNextFrame() {
    if (gif.length < 1) return null;

    if (lockAnimation)
      return gif[curFrameIndex].image;

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
}
