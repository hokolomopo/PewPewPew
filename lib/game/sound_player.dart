
import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/services.dart';

class SoundPlayer {
  AudioPlayer audioPlayer;

  SoundPlayer() {
    this.audioPlayer = AudioPlayer(mode: PlayerMode.MEDIA_PLAYER);

  }

  void playLocalMusic(String assetPath, String id) async {
    final file = new File('${(await getTemporaryDirectory()).path}/' + id);
    await file.writeAsBytes((await rootBundle.load(assetPath)).buffer.asUint8List());
    await this.audioPlayer.setReleaseMode(ReleaseMode.LOOP);
    await this.audioPlayer.play( file.path, isLocal: true, stayAwake: true);
  }

  void playLocalSoundEffect(String assetPath, String id) async{
    final file = new File('${(await getTemporaryDirectory()).path}/' + id);
    await file.writeAsBytes((await rootBundle.load(assetPath)).buffer.asUint8List());
    await this.audioPlayer.setReleaseMode(ReleaseMode.RELEASE);
    await this.audioPlayer.play( file.path, isLocal: true);
  }

  void pause() async{
    await this.audioPlayer.pause();
  }

  void resume() async{
    await this.audioPlayer.resume();
  }

  void stop() async {
    await this.audioPlayer.stop();
  }

  void release() async {
    await this.audioPlayer.release();
  }

}