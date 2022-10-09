import 'package:flutter/services.dart';
import 'package:flutter_nimplayer/src/flutter_nimplayer.dart';

class FlutterNimplayerFactory {
  static MethodChannel methodChannel = const MethodChannel("flutter_nimplayer");

  static Map<String, FlutterNimplayer> instanceMap = {};

  static FlutterNimplayer createPlayer({playerId}) {
    FlutterNimplayer player = FlutterNimplayer.init(playerId);
    player.create();
    return player;
  }
}
