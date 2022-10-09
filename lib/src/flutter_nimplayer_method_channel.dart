import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'flutter_nimplayer_platform_interface.dart';

/// An implementation of [FlutterNimplayerPlatform] that uses method channels.
class MethodChannelFlutterNimplayer extends FlutterNimplayerPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('flutter_nimplayer');

  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }
}
