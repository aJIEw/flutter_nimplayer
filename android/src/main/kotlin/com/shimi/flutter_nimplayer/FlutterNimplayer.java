package com.shimi.flutter_nimplayer;

import com.netease.neliveplayer.sdk.NELivePlayer;
import com.netease.neliveplayer.sdk.NEMediaDataSource;
import com.netease.neliveplayer.sdk.model.NEAudioTrackInfo;
import com.netease.neliveplayer.sdk.model.NEDataSourceConfig;
import com.netease.neliveplayer.sdk.model.NEMediaInfo;
import com.netease.neliveplayer.sdk.model.NESDKConfig;

import java.io.IOException;
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
            case "stop":
                stop(mPlayer);
                result.success(null);
                break;
            case "destroy":
                release(mPlayer);
                result.success(null);
                break;
            case "seekTo": {
                Map<String, Object> seekToMap = (Map<String, Object>) methodCall.argument("arg");
                Integer position = (Integer) seekToMap.get("position");
                Boolean seekMode = (Boolean) seekToMap.get("isAccurate");
                seekTo(mPlayer, position.longValue(), seekMode);
                result.success(null);
            }
            break;
            /*case "getMediaInfo": {
                MediaInfo mediaInfo = getMediaInfo(mPlayer);
                if (mediaInfo != null) {
                    Map<String, Object> getMediaInfoMap = new HashMap<>();
                    getMediaInfoMap.put("title", mediaInfo.getTitle());
                    getMediaInfoMap.put("status", mediaInfo.getStatus());
                    getMediaInfoMap.put("mediaType", mediaInfo.getMediaType());
                    getMediaInfoMap.put("duration", mediaInfo.getDuration());
                    getMediaInfoMap.put("transcodeMode", mediaInfo.getTransCodeMode());
                    getMediaInfoMap.put("coverURL", mediaInfo.getCoverUrl());
                    List<Thumbnail> thumbnail = mediaInfo.getThumbnailList();
                    List<Map<String, Object>> thumbailList = new ArrayList<>();
                    for (Thumbnail thumb : thumbnail) {
                        Map<String, Object> map = new HashMap<>();
                        map.put("url", thumb.mURL);
                        thumbailList.add(map);
                        getMediaInfoMap.put("thumbnails", thumbailList);
                    }
                    List<TrackInfo> trackInfos = mediaInfo.getTrackInfos();
                    List<Map<String, Object>> trackInfoList = new ArrayList<>();
                    for (TrackInfo trackInfo : trackInfos) {
                        Map<String, Object> map = new HashMap<>();
                        map.put("vodFormat", trackInfo.getVodFormat());
                        map.put("videoHeight", trackInfo.getVideoHeight());
                        map.put("videoWidth", trackInfo.getVideoHeight());
                        map.put("subtitleLanguage", trackInfo.getSubtitleLang());
                        map.put("trackBitrate", trackInfo.getVideoBitrate());
                        map.put("vodFileSize", trackInfo.getVodFileSize());
                        map.put("trackIndex", trackInfo.getIndex());
                        map.put("trackDefinition", trackInfo.getVodDefinition());
                        map.put("audioSampleFormat", trackInfo.getAudioSampleFormat());
                        map.put("audioLanguage", trackInfo.getAudioLang());
                        map.put("vodPlayUrl", trackInfo.getVodPlayUrl());
                        map.put("trackType", trackInfo.getType().ordinal());
                        map.put("audioSamplerate", trackInfo.getAudioSampleRate());
                        map.put("audioChannels", trackInfo.getAudioChannels());
                        trackInfoList.add(map);
                        getMediaInfoMap.put("tracks", trackInfoList);
                    }
                    result.success(getMediaInfoMap);
                }
            }
            break;*/
            case "getDuration":
                result.success(getDuration(mPlayer));
                break;
            case "getCurrentPosition":
                result.success(getCurrentPosition(mPlayer));
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
