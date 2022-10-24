import 'package:flutter/services.dart';
import 'package:flutter_nimplayer/flutter_nimplayer.dart';

import 'flutter_nimplayer_factory.dart';
import 'flutter_nimplayer_platform_interface.dart';

typedef OnPlayerEvent = void Function(String playerId);
typedef OnPlayerProgress = void Function(String playerId, int percent);
typedef OnVideoSizeChanged = void Function(
    String playerId, int width, int height);
typedef OnPlaybackCallback = void Function(
    String playerId, int? code, int? extra);
typedef OnSubtitleShow = void Function(
    String playerId, int subtitleID, String subtitle);
typedef OnSubtitleHide = void Function(String playerId, int subtitleID);

class FlutterNimplayer {
  OnPlayerEvent? onPrepared;
  OnPlayerEvent? onLoadingBegin;
  OnPlayerProgress? onLoadingProgress;
  OnPlayerEvent? onLoadingEnd;
  OnVideoSizeChanged? onVideoSizeChanged;
  OnPlayerEvent? onSeekComplete;
  OnPlayerProgress? onCurrentPosition;
  OnPlaybackCallback? onInfo;
  OnPlaybackCallback? onCompletion;
  OnPlaybackCallback? onError;
  OnSubtitleShow? onSubtitleShow;
  OnSubtitleHide? onSubtitleHide;

  String playerId = 'default';
  EventChannel eventChannel = const EventChannel("flutter_nimplayer_event");

  FlutterNimplayer.init(String? id) {
    if (id != null) {
      playerId = id;
    }
    FlutterNimplayerFactory.instanceMap[playerId] = this;
    register();
  }

  _wrapWithPlayerId({arg = ''}) {
    var map = {"arg": arg, "playerId": playerId.toString()};
    return map;
  }

  /// 接口部分
  Future<void> create() async {
    return FlutterNimplayerFactory.methodChannel.invokeMethod(
        'createPlayer', _wrapWithPlayerId(arg: PlayerType.playerTypeSingle));
  }

  Future<void> setPlayerView(int viewId) async {
    return FlutterNimplayerFactory.methodChannel
        .invokeMethod('setPlayerView', _wrapWithPlayerId(arg: viewId));
  }

  Future<void> setUrl(String url) async {
    return FlutterNimplayerFactory.methodChannel
        .invokeMethod('setUrl', _wrapWithPlayerId(arg: url));
  }

  Future<void> prepare() async {
    return FlutterNimplayerFactory.methodChannel
        .invokeMethod('prepare', _wrapWithPlayerId());
  }

  Future<void> play() async {
    return FlutterNimplayerFactory.methodChannel
        .invokeMethod('play', _wrapWithPlayerId());
  }

  Future<void> pause() async {
    return FlutterNimplayerFactory.methodChannel
        .invokeMethod('pause', _wrapWithPlayerId());
  }

  Future<void> switchContentUrl(String url) async {
    return FlutterNimplayerFactory.methodChannel
        .invokeMethod('switchContentUrl', _wrapWithPlayerId(arg: url));
  }

  Future<void> stop() async {
    return FlutterNimplayerFactory.methodChannel
        .invokeMethod('stop', _wrapWithPlayerId());
  }

  Future<void> destroy() async {
    FlutterNimplayerFactory.instanceMap.remove(playerId);
    return FlutterNimplayerFactory.methodChannel
        .invokeMethod('destroy', _wrapWithPlayerId());
  }

  Future<void> seekTo(int position, bool isAccurate) async {
    var map = {"position": position, "isAccurate": isAccurate};
    return FlutterNimplayerFactory.methodChannel
        .invokeMethod("seekTo", _wrapWithPlayerId(arg: map));
  }

  Future<dynamic> getDuration() async {
    return FlutterNimplayerFactory.methodChannel
        .invokeMethod("getDuration", _wrapWithPlayerId());
  }

  Future<dynamic> getCurrentPosition() async {
    return FlutterNimplayerFactory.methodChannel
        .invokeMethod("getCurrentPosition", _wrapWithPlayerId());
  }

  Future<dynamic> snapshot(String path) async {
    return FlutterNimplayerFactory.methodChannel
        .invokeMethod('snapshot', _wrapWithPlayerId(arg: path));
  }

  Future<dynamic> isLoop() async {
    return FlutterNimplayerFactory.methodChannel
        .invokeMethod('isLoop', _wrapWithPlayerId());
  }

  Future<void> setLoop(bool isLoop) async {
    return FlutterNimplayerFactory.methodChannel
        .invokeMethod('setLoop', _wrapWithPlayerId(arg: isLoop));
  }

  Future<void> setAutoPlay(bool isAutoPlay) async {
    return FlutterNimplayerFactory.methodChannel
        .invokeMethod('setAutoPlay', _wrapWithPlayerId(arg: isAutoPlay));
  }

  Future<void> setScalingMode(int scalingMode) async {
    return FlutterNimplayerFactory.methodChannel
        .invokeMethod('setScalingMode', _wrapWithPlayerId(arg: scalingMode));
  }

  Future<void> setMuted(bool isMuted) async {
    return FlutterNimplayerFactory.methodChannel
        .invokeMethod('setMuted', _wrapWithPlayerId(arg: isMuted));
  }

  Future<dynamic> enableHardwareDecoder(bool enable) async {
    return FlutterNimplayerFactory.methodChannel.invokeMethod(
        'setEnableHardwareDecoder', _wrapWithPlayerId(arg: enable));
  }

  Future<void> setVolume(double volume) async {
    return FlutterNimplayerFactory.methodChannel
        .invokeMethod('setVolume', _wrapWithPlayerId(arg: volume));
  }

  void register() {
    eventChannel.receiveBroadcastStream().listen(_onEvent, onError: _onError);
  }

  /// 设置回调
  void setOnPrepared(OnPlayerEvent prepared) {
    onPrepared = prepared;
  }

  void setOnLoadingStatusListener(
      {required OnPlayerEvent loadingBegin,
      required OnPlayerProgress loadingProgress,
      required OnPlayerEvent loadingEnd}) {
    onLoadingBegin = loadingBegin;
    onLoadingProgress = loadingProgress;
    onLoadingEnd = loadingEnd;
  }

  void setOnVideoSizeChanged(OnVideoSizeChanged videoSizeChanged) {
    onVideoSizeChanged = videoSizeChanged;
  }

  void setOnSeekComplete(OnPlayerEvent seekComplete) {
    onSeekComplete = seekComplete;
  }

  void setOnCurrentPosition(OnPlayerProgress onCurrentPosition) {
    this.onCurrentPosition = onCurrentPosition;
  }

  void setOnInfo(OnPlaybackCallback onInfo) {
    this.onInfo = onInfo;
  }

  void setOnCompletion(OnPlaybackCallback onCompletion) {
    this.onCompletion = onCompletion;
  }

  void setOnError(OnPlaybackCallback onError) {
    this.onError = onError;
  }

  void setOnSubtitleShow(OnSubtitleShow onSubtitleShow) {
    this.onSubtitleShow = onSubtitleShow;
  }

  void setOnSubtitleHide(OnSubtitleHide onSubtitleHide) {
    this.onSubtitleHide = onSubtitleHide;
  }

  /// 回调分发
  void _onEvent(dynamic event) {
    String method = event[EventChannelConstant.keyMethod];
    String playerId = event['playerId'] ?? '';
    FlutterNimplayer player =
        FlutterNimplayerFactory.instanceMap[playerId] ?? this;

    switch (method) {
      case "onPrepared":
        if (player.onPrepared != null) {
          player.onPrepared!(playerId);
        }
        break;
      case "onLoadingBegin":
        if (player.onLoadingBegin != null) {
          player.onLoadingBegin!(playerId);
        }
        break;
      case "onLoadingProgress":
        int percent = event['percent'];
        if (player.onLoadingProgress != null) {
          player.onLoadingProgress!(playerId, percent);
        }
        break;
      case "onLoadingEnd":
        if (player.onLoadingEnd != null) {
          player.onLoadingEnd!(playerId);
        }
        break;
      case "onVideoSizeChanged":
        if (player.onVideoSizeChanged != null) {
          int width = event['width'];
          int height = event['height'];
          player.onVideoSizeChanged!(playerId, width, height);
        }
        break;
      case "onSeekComplete":
        if (player.onSeekComplete != null) {
          player.onSeekComplete!(playerId);
        }
        break;
      case "onCurrentPosition":
        int pos = event['pos'];
        if (player.onCurrentPosition != null) {
          player.onCurrentPosition!(playerId, pos);
        }
        break;
      case "onInfo":
        if (player.onInfo != null) {
          int? infoCode = event['infoCode'];
          int? infoExtra = event['infoExtra'];
          player.onInfo!(playerId, infoCode, infoExtra);
        }
        break;
      case "onError":
        if (player.onError != null) {
          int? errorCode = event['errorCode'];
          int? errorExtra = event['errorExtra'];
          player.onError!(playerId, errorCode, errorExtra);
        }
        break;
      case "onCompletion":
        if (player.onCompletion != null) {
          player.onCompletion!(playerId, null, null);
        }
        break;
      case "onSubtitleShow":
        if (player.onSubtitleShow != null) {
          int subtitleID = event['subtitleID'];
          String subtitle = event['subtitle'];
          player.onSubtitleShow!(playerId, subtitleID, subtitle);
        }
        break;
      case "onSubtitleHide":
        if (player.onSubtitleHide != null) {
          int subtitleID = event['subtitleID'];
          player.onSubtitleHide!(playerId, subtitleID);
        }
        break;
    }
  }

  void _onError(dynamic error) {}
}

class PlayerType {
  static const int playerTypeSingle = 0;
  static const int playerTypeList = 1;
}

class EventChannelConstant {
  static const String keyMethod = "method";
}
