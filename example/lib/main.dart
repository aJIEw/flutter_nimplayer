import 'dart:async';

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
  static String url =
      'http://jdvodma74obxu.vod.126.net/jdvodma74obxu/9e4cHOd2_4901711695_hd.m3u8?wsSecret=42ae6941407a96565e059314eba69d61&wsTime=1665311038';

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
    });

    videoPlayer!.setOnLoadingStatusListener(
        loadingBegin: (playerId) {
          setState(() {
            videoLoading = true;
          });
        },
        loadingProgress: (playerId, percent) {},
        loadingEnd: (playerId) {
          setState(() {
            videoLoading = false;
          });
        });

    videoPlayer?.setOnCurrentPosition((playerId, pos) {
      if (!_slidingInProgress) {
        double newPosition = pos / _videoLength;
        if (newPosition < 0) {
          newPosition = 0;
        } else if (newPosition > 1) {
          newPosition = 1;
        }
        setState(() {
          videoPosition = newPosition;
        });
      }

      String newPosition = pos.millisecondsToTimeString();
      if (newPosition != videoPlayedTime) {
        setState(() {
          videoPlayedTime = newPosition;
        });
      }
    });

    videoPlayer!.setOnCompletion((playerId, code, extra) {
      setState(() {
        videoPosition = 1;
        videoEnded = true;
        videoPlaying = false;
        videoControlVisible = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('flutter_nimplayer example')),
        body: Stack(
          children: [
            NimplayerView(
              onCreated: (viewId) {
                initAndPlay(viewId);
              },
              x: 0,
              y: 0,
              width: 400,
              height: 220,
            ),
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {
                toggleVideoControlBar();
              },
            ),
            if (videoControlVisible)
              Positioned(
                left: 0,
                right: 0,
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
                              videoPlaying ? Icons.pause : Icons.play_arrow,
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
                          style:
                              TextStyle(color: Colors.grey[400], fontSize: 11),
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
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.black38,
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Icon(
                          Icons.replay,
                          color: Colors.white,
                          size: 30,
                        ),
                        SizedBox(height: 4),
                        Text('Replay', style: TextStyle(color: Colors.white)),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
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
    initAndPlay(_videoViewId);

    setState(() {
      videoPosition = 0;
      videoPlayedTime = '00:00';
      videoEnded = false;
    });
  }
}
