import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_nimplayer/flutter_nimplayer.dart';
import 'package:flutter_nimplayer_example/ext/int.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String url =
      'http://jdvodma74obxu.vod.126.net/jdvodma74obxu/9e4cHOd2_4901711695_hd.m3u8?wsSecret=f990f407b0e5bcca610dcb6c52020f37&wsTime=1665538963';

  bool fullscreenMode = false;

  FlutterNimplayer? videoPlayer;
  int _videoViewId = -1;
  bool videoPlaying = false;
  bool videoLoading = false;
  bool videoEnded = false;

  Timer? videoControlTimer;
  bool videoControlVisible = false;
  int _videoLength = 0;
  String videoTotalTime = '00.00';
  String videoPlayedTime = '00:00';
  double videoPosition = 0.0;
  bool _slidingInProgress = false;

  @override
  void initState() {
    super.initState();

    videoPlayer = FlutterNimplayerFactory.createPlayer();
    videoPlayer?.setOnPrepared((playerId) async {
      videoPlaying = true;
      _showVideoControlBar();

      _videoLength = await videoPlayer?.getDuration();
      setState(() {
        videoTotalTime = _videoLength.millisecondsToTimeString();
      });

      videoPlayer!.setOnLoadingStatusListener(
          loadingBegin: (playerId) {
            setState(() {
              videoLoading = true;
            });
          },
          loadingProgress: (playerId, percent) {
            if (percent > 70) {
              videoLoading = false;
            }
          },
          loadingEnd: (playerId) {});

      videoPlayer!.setOnCompletion((playerId, code, extra) {
        setState(() {
          videoPosition = 1;
          videoEnded = true;
          videoPlaying = false;
          videoControlVisible = false;
        });

        videoPlayer!.setOnError((playerId, code, extra) {
          print('_MyAppState - initState: playerId = $playerId, code = $code, extra = $extra');
        });
      });
    });

    Timer.periodic(const Duration(milliseconds: 200), (timer) async {
      int pos = 0;
      if (!_slidingInProgress && videoPlaying) {
        pos = await videoPlayer?.getCurrentPosition() ?? 0;
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
          return RotatedBox(
            quarterTurns: fullscreenMode ? 45 : 0,
            child: SizedBox(
              width: fullscreenMode ? height : width,
              height: fullscreenMode ? width : height,
              child: Stack(
                children: [
                  NimplayerView(
                    onCreated: (viewId) {
                      initAndPlay(viewId);
                    },
                    x: 0,
                    y: 0,
                    width: fullscreenMode ? height : width,
                    height: fullscreenMode ? width : height,
                  ),
                  GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () {
                      toggleVideoControlBar();
                    },
                  ),
                  if (videoLoading)
                    Center(
                        child: TranslucentContainer(
                            padding: const EdgeInsets.all(8),
                            child: Theme(
                                data: ThemeData(
                                    cupertinoOverrideTheme:
                                        const CupertinoThemeData(
                                            brightness: Brightness.dark)),
                                child: const CupertinoActivityIndicator()))),
                  if (videoControlVisible)
                    Positioned(
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
                                icon: Icon(
                                    videoPlaying
                                        ? Icons.pause
                                        : Icons.play_arrow,
                                    color: Colors.white,
                                    size: 24)),
                            SizedBox(
                              width: 35,
                              child: Text(
                                videoPlayedTime,
                                style: const TextStyle(
                                    color: Colors.white, fontSize: 11),
                              ),
                            ),
                            SizedBox(
                              width: 40,
                              child: Text(
                                '/ $videoTotalTime',
                                style: TextStyle(
                                    color: Colors.grey[400], fontSize: 11),
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
                            // if (canGoFullscreen)
                            //   IconButton(
                            //       onPressed: onToggleFullscreen,
                            //       icon: Icon(
                            //         fullscreenMode ? Icons.fullscreen_exit : Icons.fullscreen,
                            //         color: Colors.white,
                            //         size: 24,
                            //       )),
                            // if (!canGoFullscreen)
                            //   SizedBox(
                            //     width: 40,
                            //     child: Text(
                            //       videoController.videoTotalTime.value,
                            //       style: TextStyle(color: Colors.grey[400], fontSize: 11),
                            //     ),
                            //   ),
                            // SizedBox(
                            //     width:
                            //     fullscreenMode ? MediaQuery.of(context).padding.bottom : 0),
                          ],
                        ),
                      ),
                    ),
                  if (videoEnded)
                    Center(
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
                              Text('Replay',
                                  style: TextStyle(color: Colors.white)),
                            ],
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }

  void initAndPlay(int viewId) {
    _videoViewId = viewId;

    videoPlayer?.setPlayerView(viewId);
    videoPlayer?.setUrl(url);
    videoPlayer?.prepare();
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
      videoPlayer!.pause();
    } else {
      videoPlayer!.play();
    }

    setState(() {
      videoPlaying = !videoPlaying;
    });
  }

  void seekTo(double value) {
    slideTo(value);

    videoPlayer!.seekTo((value * _videoLength).toInt(), true);
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
}

class TranslucentContainer extends StatelessWidget {
  const TranslucentContainer(
      {Key? key,
      this.padding = const EdgeInsets.all(8),
      this.translucentColor = Colors.black38,
      this.borderRadius = 5,
      required this.child})
      : super(key: key);

  final EdgeInsetsGeometry padding;

  final Color translucentColor;

  final double borderRadius;

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: translucentColor,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: child,
    );
  }
}
