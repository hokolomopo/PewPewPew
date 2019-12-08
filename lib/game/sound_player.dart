import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/services.dart';

class SoundPlayer {
  AudioPlayer audioPlayer;

  SoundPlayer([bool lowLatencyMode = false]) {
    if (lowLatencyMode)
      this.audioPlayer = AudioPlayer(mode: PlayerMode.LOW_LATENCY);
    else
      this.audioPlayer = AudioPlayer(mode: PlayerMode.MEDIA_PLAYER);
  }

  void playLocalAudio(String assetPath, String id, bool isSoundEffect) async {
    final file = new File('${(await getTemporaryDirectory()).path}/' + id);
    await file
        .writeAsBytes((await rootBundle.load(assetPath)).buffer.asUint8List());

    if(isSoundEffect){
      await this.audioPlayer.setReleaseMode(ReleaseMode.RELEASE);
      await this.audioPlayer.play(file.path, isLocal: true);
    }
    else{
      await this.audioPlayer.setReleaseMode(ReleaseMode.LOOP);
      await this.audioPlayer.play(file.path, isLocal: true, stayAwake: true);
    }
  }

  void pause() async {
    await this.audioPlayer.pause();
  }

  void resume() async {
    await this.audioPlayer.resume();
  }

  void stop() async {
    await this.audioPlayer.stop();
  }

  void release() async {
    await this.audioPlayer.release();
  }
}
