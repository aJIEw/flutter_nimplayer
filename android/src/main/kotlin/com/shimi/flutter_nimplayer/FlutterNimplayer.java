package com.shimi.flutter_nimplayer;

import com.netease.neliveplayer.sdk.NELivePlayer;
import com.netease.neliveplayer.sdk.NEMediaDataSource;
import com.netease.neliveplayer.sdk.model.NEAudioTrackInfo;
import com.netease.neliveplayer.sdk.model.NEDataSourceConfig;
import com.netease.neliveplayer.sdk.model.NESDKConfig;

import java.io.IOException;
import java.util.HashMap;
import java.util.Map;

import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;

public class FlutterNimplayer extends FlutterPlayerBase {

    private NELivePlayer mPlayer;

    public FlutterNimplayer(FlutterPlugin.FlutterPluginBinding flutterPluginBinding, String playerId) {
        this.mContext = flutterPluginBinding.getApplicationContext();
        this.mPlayerId = playerId;
        NESDKConfig config = new NESDKConfig();
        NELivePlayer.init(mContext, config);
        mPlayer = NELivePlayer.create();
        initListener(mPlayer);
    }

    @Override
    public NELivePlayer getPlayer() {
        return mPlayer;
    }

    public void onMethodCall(MethodCall methodCall, MethodChannel.Result result) {
        switch (methodCall.method) {
            case "setUrl":
                String url = methodCall.argument("arg");
                setDataSource(mPlayer, url);
                result.success(null);
                break;
            case "prepare":
                prepare(mPlayer);
                result.success(null);
                break;
            case "play":
                start(mPlayer);
                result.success(null);
                break;
            case "pause":
                pause(mPlayer);
                result.success(null);
                break;
            case "switchContentUrl":
                String switchUrl = methodCall.argument("arg");
                switchContentUrl(mPlayer, switchUrl);
                result.success(null);
                break;
            case "stop":
                stop(mPlayer);
                result.success(null);
                break;
            case "destroy":
                release(mPlayer);
                result.success(null);
                break;
            case "seekTo":
                Map<String, Object> seekToMap = (Map<String, Object>) methodCall.argument("arg");
                Integer position = (Integer) seekToMap.get("position");
                Boolean seekMode = (Boolean) seekToMap.get("isAccurate");
                seekTo(mPlayer, position.longValue(), seekMode);
                result.success(null);
                break;
            case "getDuration":
                result.success(getDuration(mPlayer));
                break;
            case "getCurrentPosition":
                result.success(getCurrentPosition(mPlayer));
                break;
            case "getVideoSize":
                result.success(getVideoSize(mPlayer));
                break;
            case "snapshot":
                mSnapShotPath = methodCall.argument("arg").toString();
                snapshot(mPlayer);
                result.success(null);
                break;
            case "setLoop":
                setLoop(mPlayer, (Integer) methodCall.argument("arg"));
                result.success(null);
                break;
            case "isLoop":
                result.success(isLoop(mPlayer));
                break;
            case "setAutoPlay":
                setAutoPlay(mPlayer, (Boolean) methodCall.argument("arg"));
                result.success(null);
                break;
            case "setScalingMode":
                setScalingMode(mPlayer, (Integer) methodCall.argument("arg"));
                result.success(null);
                break;
            case "setMuted":
                setMuted(mPlayer, (Boolean) methodCall.argument("arg"));
                result.success(null);
                break;
            case "setEnableHardwareDecoder":
                Boolean setEnableHardwareDecoder = (Boolean) methodCall.argument("arg");
                setEnableHardWareDecoder(mPlayer, setEnableHardwareDecoder);
                result.success(null);
                break;
            case "setVolume":
                setVolume(mPlayer, (Double) methodCall.argument("arg"));
                result.success(null);
                break;
            case "getCurrentTrack":
                /*Integer currentTrackIndex = (Integer) methodCall.argument("arg");
                TrackInfo currentTrack = getCurrentTrack(mPlayer, currentTrackIndex);
                if (currentTrack != null) {
                    Map<String, Object> map = new HashMap<>();
                    map.put("vodFormat", currentTrack.getVodFormat());
                    map.put("videoHeight", currentTrack.getVideoHeight());
                    map.put("videoWidth", currentTrack.getVideoHeight());
                    map.put("subtitleLanguage", currentTrack.getSubtitleLang());
                    map.put("trackBitrate", currentTrack.getVideoBitrate());
                    map.put("vodFileSize", currentTrack.getVodFileSize());
                    map.put("trackIndex", currentTrack.getIndex());
                    map.put("trackDefinition", currentTrack.getVodDefinition());
                    map.put("audioSampleFormat", currentTrack.getAudioSampleFormat());
                    map.put("audioLanguage", currentTrack.getAudioLang());
                    map.put("vodPlayUrl", currentTrack.getVodPlayUrl());
                    map.put("trackType", currentTrack.getType().ordinal());
                    map.put("audioSamplerate", currentTrack.getAudioSampleRate());
                    map.put("audioChannels", currentTrack.getAudioChannels());
                    result.success(map);
                }
                break;*/
            case "selectTrack":
                Map<String, Object> selectTrackMap = (Map<String, Object>) methodCall.argument("arg");
                Integer trackIdx = (Integer) selectTrackMap.get("trackIdx");
                selectTrack(mPlayer, trackIdx);
                result.success(null);
                break;
            default:
                result.notImplemented();
        }
    }

    private void setDataSource(NELivePlayer mPlayer, String url) {
        if (mPlayer != null) {
            try {
                mPlayer.setDataSource(url);
            } catch (IOException e) {
                e.printStackTrace();
            }
        }
    }

    private void setDataSource(NELivePlayer mPlayer, String url, NEDataSourceConfig config) {
        if (mPlayer != null) {
            try {
                mPlayer.setDataSource(url, config);
            } catch (IOException e) {
                e.printStackTrace();
            }
        }
    }

    private void setDataSource(NELivePlayer mPlayer, NEMediaDataSource source) {
        if (mPlayer != null) {
            mPlayer.setDataSource(source);
        }
    }

    private void prepare(NELivePlayer mPlayer) {
        if (mPlayer != null) {
            mPlayer.prepareAsync();
        }
    }

    private void start(NELivePlayer mPlayer) {
        if (mPlayer != null) {
            mPlayer.start();
        }
    }

    private void pause(NELivePlayer mPlayer) {
        if (mPlayer != null) {
            mPlayer.pause();
        }
    }

    private void switchContentUrl(NELivePlayer mPlayer, String url) {
        if (mPlayer != null) {
            mPlayer.switchContentUrl(url);
        }
    }

    private void stop(NELivePlayer mPlayer) {
        if (mPlayer != null) {
            mPlayer.stop();
        }
    }

    private void release(NELivePlayer mPlayer) {
        if (mPlayer != null) {
            mPlayer.release();
            mPlayer = null;
        }
    }

    private void seekTo(NELivePlayer mPlayer, long position, Boolean isAccurate) {
        if (mPlayer != null) {
            mPlayer.setAccurateSeek(isAccurate);
            mPlayer.seekTo(position);
        }
    }


    private long getDuration(NELivePlayer mPlayer) {
        if (mPlayer != null) {
            return mPlayer.getDuration();
        }
        return 0;
    }

    private long getCurrentPosition(NELivePlayer mPlayer) {
        if (mPlayer != null) {
            return mPlayer.getCurrentPosition();
        }
        return 0;
    }

    private Map<String, Integer> getVideoSize(NELivePlayer mPlayer) {
        Map<String, Integer> map = new HashMap<>();
        if (mPlayer != null) {
            map.put("width", mPlayer.getVideoWidth());
            map.put("height", mPlayer.getVideoHeight());
        }
        return map;
    }

    private void snapshot(NELivePlayer mPlayer) {
        if (mPlayer != null) {
            mPlayer.getSnapshot();
        }
    }

    private void setLoop(NELivePlayer mPlayer, int isLoop) {
        if (mPlayer != null) {
            mPlayer.setLoopCount(isLoop);
        }
    }

    private Boolean isLoop(NELivePlayer mPlayer) {
        return mPlayer != null && mPlayer.isLooping();
    }

    private void setAutoPlay(NELivePlayer mPlayer, Boolean isAutoPlay) {
        if (mPlayer != null) {
            mPlayer.setShouldAutoplay(isAutoPlay);
        }
    }

    private void setScalingMode(NELivePlayer mPlayer, Integer mode) {
    }

    private void setMuted(NELivePlayer mPlayer, Boolean muted) {
        if (mPlayer != null) {
            mPlayer.setMute(muted);
        }
    }

    private void setEnableHardWareDecoder(NELivePlayer mPlayer, Boolean mEnableHardwareDecoder) {
        if (mPlayer != null) {
            mPlayer.setHardwareDecoder(mEnableHardwareDecoder);
        }
    }

    private void setSpeed(NELivePlayer mPlayer, double speed) {
        if (mPlayer != null) {
            mPlayer.setPlaybackSpeed((float) speed);
        }
    }

    private void setVolume(NELivePlayer mPlayer, double volume) {
        if (mPlayer != null) {
            mPlayer.setVolume((float) volume);
        }
    }

    private NEAudioTrackInfo getCurrentTrack(NELivePlayer mPlayer, int currentTrackIndex) {
        if (mPlayer != null) {
            return mPlayer.getAudioTracksInfo()[currentTrackIndex];
        } else {
            return null;
        }
    }

    private void selectTrack(NELivePlayer mPlayer, int trackId) {
        if (mPlayer != null) {
            mPlayer.setSelectedAudioTrack(trackId);
        }
    }
}
