import 'package:flutter_sound/flutter_sound.dart';
import 'dart:io';
import 'package:flutter/services.dart' show rootBundle;
import 'package:path_provider/path_provider.dart';

class AudioPlayer {
  FlutterSoundPlayer? _audioPlayer;
  final String assetFilePath = 'sounds/alarm.wav';
  late final File file;

  Future init() async {
    final Directory dir = await getTemporaryDirectory();
    file = File('${dir.path}/audio.mp3');

    final byteData = await rootBundle.load(assetFilePath);
    await file.writeAsBytes(byteData.buffer.asInt8List());

    _audioPlayer = FlutterSoundPlayer();
    await _audioPlayer!.openAudioSession();
  }

  void dispose() {
    _audioPlayer!.closeAudioSession();
    _audioPlayer = null;
  }

  Future play() async {
    if (!_audioPlayer!.isPlaying)
      await _audioPlayer!.startPlayer(fromURI: file.path);
  }

  Future stop() async {
    if (_audioPlayer!.isPlaying) await _audioPlayer!.stopPlayer();
  }

  Future toggle() async {
    if (_audioPlayer == null) {
      print("null");
      return;
    }
    if (_audioPlayer!.isPlaying)
      await _audioPlayer!.stopPlayer();
    else
      await _audioPlayer!.startPlayer(fromURI: file.path);
  }
}
