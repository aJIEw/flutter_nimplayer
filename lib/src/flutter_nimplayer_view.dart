import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

typedef ViewCreatedCallback = void Function(int viewId);

class NimplayerView extends StatefulWidget {
  const NimplayerView({
    super.key,
    required this.onCreated,
    required this.x,
    required this.y,
    required this.width,
    required this.height,
  });

  final ViewCreatedCallback? onCreated;
  final double x;
  final double y;
  final double width;
  final double height;

  @override
  State<StatefulWidget> createState() => _VideoPlayerState();
}

class _VideoPlayerState extends State<NimplayerView> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return nativeView();
  }

  nativeView() {
    if (Platform.isAndroid) {
      return AndroidView(
        viewType: 'flutter_nimplayer_render_view',
        onPlatformViewCreated: _onPlatformViewCreated,
        creationParams: <String, dynamic>{
          "x": widget.x,
          "y": widget.y,
          "width": widget.width,
          "height": widget.height,
        },
        creationParamsCodec: const StandardMessageCodec(),
      );
    } else {
      return UiKitView(
        viewType: 'flutter_nimplayer_render_view',
        onPlatformViewCreated: _onPlatformViewCreated,
        creationParams: <String, dynamic>{
          "x": widget.x,
          "y": widget.y,
          "width": widget.width,
          "height": widget.height,
        },
        creationParamsCodec: const StandardMessageCodec(),
      );
    }
  }

  Future<void> _onPlatformViewCreated(id) async {
    if (widget.onCreated != null) {
      widget.onCreated!(id);
    }
  }
}
