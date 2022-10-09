import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'flutter_nimplayer_method_channel.dart';

abstract class FlutterNimplayerPlatform extends PlatformInterface {
  /// Constructs a FlutterNimplayerPlatform.
  FlutterNimplayerPlatform() : super(token: _token);

  static final Object _token = Object();

  static FlutterNimplayerPlatform _instance = MethodChannelFlutterNimplayer();

  /// The default instance of [FlutterNimplayerPlatform] to use.
  ///
  /// Defaults to [MethodChannelFlutterNimplayer].
  static FlutterNimplayerPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [FlutterNimplayerPlatform] when
  /// they register themselves.
  static set instance(FlutterNimplayerPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }
}
