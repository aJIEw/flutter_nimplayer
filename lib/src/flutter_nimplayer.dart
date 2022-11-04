import 'package:flutter/services.dart';
import 'package:flutter_nimplayer/flutter_nimplayer.dart';

import 'flutter_nimplayer_factory.dart';

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

  /// 和播放器视图建立连接
  Future<void> setPlayerView(int viewId) async {
    return FlutterNimplayerFactory.methodChannel
        .invokeMethod('setPlayerView', _wrapWithPlayerId(arg: viewId));
  }

  /// 设置播放 url
  Future<void> setUrl(String url) async {
    return FlutterNimplayerFactory.methodChannel
        .invokeMethod('setUrl', _wrapWithPlayerId(arg: url));
  }

  /// 准备播放，只有在调用该方法后才能收到 [onPrepared] 回调
  Future<void> prepare() async {
    return FlutterNimplayerFactory.methodChannel
        .invokeMethod('prepare', _wrapWithPlayerId());
  }

  /// 切换播放 url，只有在开始播放后调用该方法才会生效
  Future<void> switchContentUrl(String url) async {
    return FlutterNimplayerFactory.methodChannel
        .invokeMethod('switchContentUrl', _wrapWithPlayerId(arg: url));
  }

  /// 播放
  Future<void> play() async {
    return FlutterNimplayerFactory.methodChannel
        .invokeMethod('play', _wrapWithPlayerId());
  }

  /// 暂停
  Future<void> pause() async {
    return FlutterNimplayerFactory.methodChannel
        .invokeMethod('pause', _wrapWithPlayerId());
  }

  /// 停止播放
  Future<void> stop() async {
    return FlutterNimplayerFactory.methodChannel
        .invokeMethod('stop', _wrapWithPlayerId());
  }

  /// 销毁播放器资源
  Future<void> destroy() async {
    FlutterNimplayerFactory.instanceMap.remove(playerId);
    return FlutterNimplayerFactory.methodChannel
        .invokeMethod('destroy', _wrapWithPlayerId());
  }

  /// 移动到播放位置，单位 milliseconds
  Future<void> seekTo(int position, bool isAccurate) async {
    var map = {"position": position, "isAccurate": isAccurate};
    return FlutterNimplayerFactory.methodChannel
        .invokeMethod("seekTo", _wrapWithPlayerId(arg: map));
  }

  /// 获取资源长度，通常在 [onPrepared] 中调用
  Future<dynamic> getDuration() async {
    return FlutterNimplayerFactory.methodChannel
        .invokeMethod("getDuration", _wrapWithPlayerId());
  }

  /// 获取当前播放位置，iOS 上只支持查询到秒
  Future<dynamic> getCurrentPosition() async {
    return FlutterNimplayerFactory.methodChannel
        .invokeMethod("getCurrentPosition", _wrapWithPlayerId());
  }

  /// 获取视频大小，返回 map = {'width': x, 'height': x}
  Future<dynamic> getVideoSize() async {
    return FlutterNimplayerFactory.methodChannel
        .invokeMethod("getVideoSize", _wrapWithPlayerId());
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

  /// 设置是否在准备完成后自动播放，默认开启
  Future<void> setAutoPlay(bool isAutoPlay) async {
    return FlutterNimplayerFactory.methodChannel
        .invokeMethod('setAutoPlay', _wrapWithPlayerId(arg: isAutoPlay));
  }

  /// 设置画面拉伸模式，仅支持 iOS，
  /// 0: 不保持比例平铺
  /// 1: 保持比例缩放，缺少的部分使用黑边填充
  /// 2: 保持比例填充，多余的部分会被裁剪
  ///
  /// 安卓上不支持缩放，默认为不保持比例平铺，iOS 上默认为保持比例缩放
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

  /// 资源准备成功回调
  void setOnPrepared(OnPlayerEvent prepared) {
    onPrepared = prepared;
  }

  /// 加载状态回调，播放进度回调只支持安卓
  void setOnLoadingStatusListener(
      {required OnPlayerEvent loadingBegin,
      required OnPlayerProgress loadingProgress,
      required OnPlayerEvent loadingEnd}) {
    onLoadingBegin = loadingBegin;
    onLoadingProgress = loadingProgress;
    onLoadingEnd = loadingEnd;
  }

  /// 位移成功后的回调
  void setOnSeekComplete(OnPlayerEvent seekComplete) {
    onSeekComplete = seekComplete;
  }

  /// 视频播放结束回调
  void setOnCompletion(OnPlaybackCallback onCompletion) {
    this.onCompletion = onCompletion;
  }

  /// 视频播放出错回调，安卓上，回调信息中包含 errorCode 和 errorExtra
  void setOnError(OnPlaybackCallback onError) {
    this.onError = onError;
  }

  /// 视频大小变化回调，仅支持安卓
  void setOnVideoSizeChanged(OnVideoSizeChanged videoSizeChanged) {
    onVideoSizeChanged = videoSizeChanged;
  }

  /// 当前播放位置回调，仅支持安卓
  void setOnCurrentPosition(OnPlayerProgress onCurrentPosition) {
    this.onCurrentPosition = onCurrentPosition;
  }

  /// 视频信息回调，仅支持安卓
  void setOnInfo(OnPlaybackCallback onInfo) {
    this.onInfo = onInfo;
  }

  /// 字幕展示回调，仅支持安卓
  void setOnSubtitleShow(OnSubtitleShow onSubtitleShow) {
    this.onSubtitleShow = onSubtitleShow;
  }

  /// 字幕隐藏回调，仅支持安卓
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
