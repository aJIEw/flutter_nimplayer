import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_nimplayer/flutter_nimplayer.dart';
import 'package:flutter_nimplayer_example/ext/int.dart';
import 'package:flutter_nimplayer_example/widget/translucent_container.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  /// 播放 url
  String url =
      'http://jdvodma74obxu.vod.126.net/jdvodma74obxu/9e4cHOd2_4901711695_hd.m3u8?'
      'wsSecret=50882a05f5e5ad009549e248472b7f08&'
      'wsTime=1667528025';

  /// 是否以全屏方式播放
  bool fullscreenMode = false;

  /// region 播放相关
  FlutterNimplayer? player;
  int _videoViewId = -1;
  bool videoPlaying = false;
  bool videoLoading = false;
  bool videoEnded = false;

  // endregion

  /// region 进度条相关
  Timer? videoControlTimer;
  bool videoControlVisible = false;
  int _videoLength = 0;
  String videoTotalTime = '00.00';
  String videoPlayedTime = '00:00';
  double videoPosition = 0.0;
  bool _slidingInProgress = false;

  // endregion

  @override
  void initState() {
    super.initState();

    player = FlutterNimplayerFactory.createPlayer();
    player?.setOnPrepared((playerId) async {
      videoPlaying = true;
      _showVideoControlBar();

      _videoLength = await player?.getDuration();
      setState(() {
        videoTotalTime = _videoLength.millisecondsToTimeString();
      });

      player!.setOnLoadingStatusListener(loadingBegin: (playerId) {
        setState(() {
          videoLoading = true;
        });
      }, loadingProgress: (playerId, percent) {
        // 播放进度回调仅支持安卓。取决于视频长度，有可能当加载进度大于 30 时就可以播放了
        if (percent > 70) {
          videoLoading = false;
        }
      }, loadingEnd: (playerId) {
        videoLoading = false;
      });

      player!.setOnCompletion((playerId, code, extra) {
        setState(() {
          videoPosition = 1;
          videoEnded = true;
          videoPlaying = false;
          videoControlVisible = false;
        });

        player!.setOnError((playerId, code, extra) {
          print(
              '_MyAppState - initState: playerId = $playerId, code = $code, extra = $extra');
        });
      });
    });

    // 使用定时器获取播放进度，安卓上支持小于一秒内的刷新，iOS 上只支持秒级刷新
    Timer.periodic(const Duration(milliseconds: 200), (timer) async {
      int pos = 0;
      if (!_slidingInProgress && videoPlaying) {
        pos = await player?.getCurrentPosition() ?? 0;
        double newPosition = pos / _videoLength;
        if (newPosition < 0) {
          newPosition = 0;
        } else if (newPosition > 1) {
          newPosition = 1;
        }
        setState(() {
          videoPosition = newPosition;
        });

        String newTime = pos.millisecondsToTimeString();
        if (newTime != videoPlayedTime) {
          setState(() {
            videoPlayedTime = newTime;
          });
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Builder(builder: (context) {
          var width = MediaQuery.of(context).size.width;
          var height = MediaQuery.of(context).size.height;
          if (!fullscreenMode) {
            height = width * 9 / 16;
          }
          // 如果是全屏则旋转屏幕并反向设置宽高
          return SafeArea(
            child: RotatedBox(
              quarterTurns: fullscreenMode ? 1 : 0,
              child: SizedBox(
                width: fullscreenMode ? height : width,
                height: fullscreenMode ? width : height,
                child: Stack(
                  children: [
                    _buildPlayerView(width, height),
                    _buildGestureDetector(),
                    _buildLoadingIndicator(),
                    _buildControlBar(),
                    _buildReplayButton(),
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildPlayerView(double width, double height) {
    return NimplayerView(
      onCreated: (viewId) {
        initAndPlay(viewId);
      },
      x: 0,
      y: 0,
      width: fullscreenMode ? height : width,
      height: fullscreenMode ? width : height,
    );
  }

  Widget _buildGestureDetector() {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        toggleVideoControlBar();
      },
    );
  }

  Widget _buildLoadingIndicator() {
    if (videoLoading) {
      return Center(
        child: TranslucentContainer(
          padding: const EdgeInsets.all(8),
          child: Theme(
              data: ThemeData(
                  cupertinoOverrideTheme:
                      const CupertinoThemeData(brightness: Brightness.dark)),
              child: const CupertinoActivityIndicator()),
        ),
      );
    }
    return Container();
  }

  Widget _buildControlBar() {
    if (videoControlVisible) {
      return Positioned(
        left: fullscreenMode ? 50 : 0,
        right: fullscreenMode ? 50 : 0,
        bottom: 0,
        child: Container(
          color: Colors.black38,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              IconButton(
                  onPressed: () {
                    toggleVideoPlayAndPause();
                  },
                  icon: Icon(videoPlaying ? Icons.pause : Icons.play_arrow,
                      color: Colors.white, size: 24)),
              SizedBox(
                width: 35,
                child: Text(
                  videoPlayedTime,
                  style: const TextStyle(color: Colors.white, fontSize: 11),
                ),
              ),
              SizedBox(
                width: 40,
                child: Text(
                  '/ $videoTotalTime',
                  style: TextStyle(color: Colors.grey[400], fontSize: 11),
                ),
              ),
              Expanded(
                child: SliderTheme(
                    data: const SliderThemeData(
                      trackHeight: 2,
                      thumbColor: Colors.white,
                      thumbShape: RoundSliderThumbShape(
                        enabledThumbRadius: 5,
                        pressedElevation: 2,
                      ),
                    ),
                    child: Slider(
                      value: videoPosition,
                      activeColor: Colors.blue,
                      inactiveColor: const Color(0xFF929BA2),
                      onChanged: (value) {
                        slideTo(value);
                      },
                      onChangeEnd: (double value) {
                        seekTo(value);
                      },
                    )),
              ),
            ],
          ),
        ),
      );
    }
    return Container();
  }

  Widget _buildReplayButton() {
    if (videoEnded) {
      return Center(
        child: GestureDetector(
          onTap: () {
            replayVideo();
          },
          child: TranslucentContainer(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Icon(
                  Icons.replay,
                  color: Colors.white,
                  size: 30,
                ),
                SizedBox(height: 4),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Text('重播', style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
          ),
        ),
      );
    }
    return Container();
  }

  void initAndPlay(int viewId) {
    _videoViewId = viewId;

    player?.setPlayerView(viewId);
    player?.setUrl(url);
    player?.prepare();
  }

  void toggleVideoControlBar() {
    if (videoEnded) return;

    if (videoControlVisible) {
      setState(() {
        videoControlVisible = false;
      });
    } else {
      _showVideoControlBar();
    }
  }

  void _showVideoControlBar() {
    setState(() {
      videoControlVisible = true;
    });

    if (videoControlTimer != null && videoControlTimer!.isActive) {
      videoControlTimer!.cancel();
    }
    videoControlTimer = Timer(const Duration(seconds: 5), () {
      setState(() {
        videoControlVisible = false;
      });
    });
  }

  void toggleVideoPlayAndPause() {
    _showVideoControlBar();

    if (videoPlaying) {
      player!.pause();
    } else {
      player!.play();
    }

    setState(() {
      videoPlaying = !videoPlaying;
    });
  }

  void seekTo(double value) {
    slideTo(value);

    player!.seekTo((value * _videoLength).toInt(), true);
    setState(() {
      videoLoading = false;
      _slidingInProgress = false;
    });
  }

  void slideTo(double value) {
    _showVideoControlBar();

    setState(() {
      videoPosition = value;
      _slidingInProgress = true;
    });
  }

  void replayVideo() {
    setState(() {
      videoPosition = 0;
      videoPlayedTime = '00:00';
      videoEnded = false;
    });

    toggleVideoPlayAndPause();
  }

  @override
  void dispose() {
    player?.destroy();
    videoControlTimer?.cancel();

    super.dispose();
  }
}
