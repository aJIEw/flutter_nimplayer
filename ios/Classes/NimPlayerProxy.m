#import "NimPlayerProxy.h"
#import <NELivePlayerFramework/NELivePlayerFramework.h>

@interface NimPlayerProxy ()
@end

@implementation NimPlayerProxy

#pragma mark callbacks

/**
 @brief 视频缓冲进度回调
 @param player 播放器player指针
 @param progress 缓存进度0-100
 */
//- (void)onLoadingProgress:(NELivePlayerController*)player progress:(float)progress {
//    self.eventSink(@{kNimPlayerMethod:@"onLoadingProgress",@"percent":@((int)progress),kNimPlayerId:_playerId});
//}

- (void)doInitPlayerNotification {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(NELivePlayerDidPreparedToPlay:)
                                                 name:NELivePlayerDidPreparedToPlayNotification
                                               object:_player];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(NELivePlayerPlaybackStateChanged:)
                                                 name:NELivePlayerPlaybackStateChangedNotification
                                               object:_player];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(NeLivePlayerloadStateChanged:)
                                                 name:NELivePlayerLoadStateChangedNotification
                                               object:_player];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(NELivePlayerPlayBackFinished:)
                                                 name:NELivePlayerPlaybackFinishedNotification
                                               object:_player];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(NELivePlayerFirstVideoDisplayed:)
                                                 name:NELivePlayerFirstVideoDisplayedNotification
                                               object:_player];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(NELivePlayerFirstAudioDisplayed:)
                                                 name:NELivePlayerFirstAudioDisplayedNotification
                                               object:_player];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(NELivePlayerReleaseSuccess:)
                                                 name:NELivePlayerReleaseSueecssNotification
                                               object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(NELivePlayerSeekComplete:)
                                                 name:NELivePlayerMoviePlayerSeekCompletedNotification
                                               object:_player];
}

#pragma mark - 播放器通知事件
- (void)NELivePlayerDidPreparedToPlay:(NSNotification*)notification {
    NSLog(@"[FlutterNimPlayer] 收到 NELivePlayerDidPreparedToPlayNotification 通知");
    
    // 开始播放
    [_player play];
    self.eventSink(@{kNimPlayerMethod:@"onPrepared",kNimPlayerId:_playerId});
}

- (void)NELivePlayerPlaybackStateChanged:(NSNotification*)notification {
    NSLog(@"[FlutterNimPlayer] 收到 NELivePlayerPlaybackStateChangedNotification 通知");
}

- (void)NeLivePlayerloadStateChanged:(NSNotification*)notification {
    NSLog(@"[FlutterNimPlayer] 收到 NELivePlayerLoadStateChangedNotification 通知");
    
    NELPMovieLoadState nelpLoadState = _player.loadState;
    
    if (nelpLoadState == NELPMovieLoadStateStalled)
    {
        NSLog(@"begin buffering");
        self.eventSink(@{kNimPlayerMethod:@"onLoadingBegin",kNimPlayerId:_playerId});
    }
    else if (nelpLoadState == NELPMovieLoadStatePlaythroughOK)
    {
        NSLog(@"finish buffering");
        self.eventSink(@{kNimPlayerMethod:@"onLoadingEnd",kNimPlayerId:_playerId});
    }
}

- (void)NELivePlayerPlayBackFinished:(NSNotification*)notification {
    NSLog(@"[FlutterNimPlayer] 收到 NELivePlayerPlaybackFinishedNotification 通知");
    
    switch ([[[notification userInfo] valueForKey:NELivePlayerPlaybackDidFinishReasonUserInfoKey] intValue])
    {
        case NELPMovieFinishReasonPlaybackEnded:
        {
            self.eventSink(@{kNimPlayerMethod:@"onCompletion",kNimPlayerId:_playerId});
            break;
        }

        case NELPMovieFinishReasonPlaybackError:
        {
            self.eventSink(@{kNimPlayerMethod:@"onError",kNimPlayerId:_playerId});
            break;
        }

        case NELPMovieFinishReasonUserExited:
        {
            break;
        }

        default:
            break;
    }
}

- (void)NELivePlayerFirstVideoDisplayed:(NSNotification*)notification {
    NSLog(@"[FlutterNimPlayer] 收到 NELivePlayerFirstVideoDisplayedNotification 通知");
}

- (void)NELivePlayerFirstAudioDisplayed:(NSNotification*)notification {
    NSLog(@"[FlutterNimPlayer] 收到 NELivePlayerFirstAudioDisplayedNotification 通知");
}

- (void)NELivePlayerSeekComplete:(NSNotification*)notification {
    NSLog(@"[FlutterNimPlayer] 收到 NELivePlayerMoviePlayerSeekCompletedNotification 通知");
    self.eventSink(@{kNimPlayerMethod:@"onSeekComplete",kNimPlayerId:_playerId});
}

- (void)NELivePlayerReleaseSuccess:(NSNotification*)notification {
    NSLog(@"[FlutterNimPlayer] 收到 NELivePlayerReleaseSueecssNotification 通知");
}

-(void)bindPlayerView:(FlutterNimPlayerView*)fnpv{
    _fnpv = fnpv;
    self.player.view.frame = fnpv.view.bounds;
    [fnpv.view addSubview:self.player.view];
}

#pragma --mark getters
- (NELivePlayerController *)player{
    if (!_player) {
        _player = [[NELivePlayerController alloc] init];
    }
    return _player;
}

@end
