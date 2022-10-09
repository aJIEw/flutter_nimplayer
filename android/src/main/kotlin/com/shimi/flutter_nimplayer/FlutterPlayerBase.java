package com.shimi.flutter_nimplayer;

import android.content.Context;

import com.netease.neliveplayer.sdk.NELivePlayer;

import java.util.HashMap;
import java.util.Map;

public abstract class FlutterPlayerBase {

    protected Context mContext;
    protected String mPlayerId;
    protected FlutterNimplayerListener mFlutterNimplayerListener;
    protected String mSnapShotPath;

    public void setOnFlutterListener(FlutterNimplayerListener listener) {
        this.mFlutterNimplayerListener = listener;
    }

    public abstract NELivePlayer getPlayer();

    public void initListener(final NELivePlayer player) {
        player.setOnPreparedListener(neLivePlayer -> {
            Map<String, Object> map = new HashMap<>();
            map.put("method", "onPrepared");
            map.put("playerId", mPlayerId);
            if (mFlutterNimplayerListener != null) {
                mFlutterNimplayerListener.onPrepared(map);
            }
        });

        player.setOnVideoSizeChangedListener((neLivePlayer, width, height, sar_num, sar_den) -> {
            Map<String, Object> map = new HashMap<>();
            map.put("method", "onVideoSizeChanged");
            map.put("playerId", mPlayerId);
            map.put("width", width);
            map.put("height", height);
            if (mFlutterNimplayerListener != null) {
                mFlutterNimplayerListener.onVideoSizeChanged(map);
            }
        });

        player.setOnSeekCompleteListener(neLivePlayer -> {
            Map<String, Object> map = new HashMap<>();
            map.put("method", "onSeekComplete");
            map.put("playerId", mPlayerId);
            if (mFlutterNimplayerListener != null) {
                mFlutterNimplayerListener.onSeekComplete(map);
            }
        });

        player.setOnBufferingUpdateListener((neLivePlayer, percent) -> {
            if (percent == 0) {
                Map<String, Object> map = new HashMap<>();
                map.put("method", "onLoadingBegin");
                map.put("playerId", mPlayerId);
                if (mFlutterNimplayerListener != null) {
                    mFlutterNimplayerListener.onLoadingBegin(map);
                }
            } else if (percent == 100) {
                Map<String, Object> map = new HashMap<>();
                map.put("method", "onLoadingEnd");
                map.put("playerId", mPlayerId);
                if (mFlutterNimplayerListener != null) {
                    mFlutterNimplayerListener.onLoadingEnd(map);
                }
            } else {
                Map<String, Object> map = new HashMap<>();
                map.put("method", "onLoadingProgress");
                map.put("playerId", mPlayerId);
                map.put("percent", percent);
                if (mFlutterNimplayerListener != null) {
                    mFlutterNimplayerListener.onLoadingProgress(map);
                }
            }
        });

        player.setOnSubtitleListener((isShow, id, subtitle) -> {
            Map<String, Object> map = new HashMap<>();
            if (isShow) {
                map.put("method", "onSubtitleShow");
                map.put("playerId", mPlayerId);
                map.put("subtitleID", id);
                map.put("subtitle", subtitle);
                if (mFlutterNimplayerListener != null) {
                    mFlutterNimplayerListener.onSubtitleShow(map);
                }
            } else {
                map.put("method", "onSubtitleHide");
                map.put("playerId", mPlayerId);
                map.put("subtitleID", id);
                if (mFlutterNimplayerListener != null) {
                    mFlutterNimplayerListener.onSubtitleHide(map);
                }
            }
        });

        player.setOnCurrentPositionListener(200, pos -> {
            Map<String, Object> map = new HashMap<>();
            map.put("method", "onCurrentPosition");
            map.put("playerId", mPlayerId);
            map.put("pos", pos);
            if (mFlutterNimplayerListener != null) {
                mFlutterNimplayerListener.onCurrentPosition(map);
            }
        });

        player.setOnInfoListener((neLivePlayer, what, extra) -> {
            Map<String, Object> map = new HashMap<>();
            map.put("method", "onInfo");
            map.put("playerId", mPlayerId);
            map.put("infoCode", what);
            map.put("infoExtra", extra);
            if (mFlutterNimplayerListener != null) {
                mFlutterNimplayerListener.onInfo(map);
            }
            return false;
        });

        player.setOnCompletionListener(neLivePlayer -> {
            Map<String, Object> map = new HashMap<>();
            map.put("method", "onCompletion");
            map.put("playerId", mPlayerId);
            if (mFlutterNimplayerListener != null) {
                mFlutterNimplayerListener.onCompletion(map);
            }
        });

        player.setOnErrorListener((neLivePlayer, what, extra) -> {
            Map<String, Object> map = new HashMap<>();
            map.put("method", "onError");
            map.put("playerId", mPlayerId);
            map.put("errorCode", what);
            map.put("errorExtra", extra);
            if (mFlutterNimplayerListener != null) {
                mFlutterNimplayerListener.onError(map);
            }
            return false;
        });

    }

}
