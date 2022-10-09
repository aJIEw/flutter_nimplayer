package com.shimi.flutter_nimplayer;

import java.util.Map;

/**
 * NimPlayer 监听接口
 */
public interface FlutterNimplayerListener {

    void onPrepared(Map<String,Object> map);

    void onVideoSizeChanged(Map<String,Object> map);

    void onSeekComplete(Map<String,Object> map);

    void onLoadingBegin(Map<String,Object> map);

    void onLoadingProgress(Map<String,Object> map);

    void onLoadingEnd(Map<String,Object> map);

    void onSubtitleShow(Map<String,Object> map);

    void onSubtitleHide(Map<String,Object> map);

    void onCurrentPosition(Map<String, Object> map);

    void onInfo(Map<String,Object> map);

    void onCompletion(Map<String,Object> map);

    void onError(Map<String,Object> map);
}
