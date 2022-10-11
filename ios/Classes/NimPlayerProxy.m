#import "NimPlayerProxy.h"

@interface NimPlayerProxy ()
@end

@implementation NimPlayerProxy

#pragma mark callbacks

/**
 @brief 错误代理回调
 @param player 播放器player指针
 */
//- (void)onError:(NELivePlayerController*)player errorModel:(AVPErrorModel *)errorModel {
//    self.eventSink(@{kNimPlayerMethod:@"onError",@"errorCode":@(errorModel.code),@"errorMsg":errorModel.message,kNimPlayerId:_playerId});
//}

/**
 @brief 播放器事件回调
 @param player 播放器player指针
 @param eventType 播放器事件类型，@see AVPEventType
 */
//-(void)onPlayerEvent:(NELivePlayerController*)player eventType:(AVPEventType)eventType {
//    switch (eventType) {
//        case AVPEventPrepareDone:
//            self.eventSink(@{kNimPlayerMethod:@"onPrepared",kNimPlayerId:_playerId});
//            break;
//        case AVPEventLoadingStart:
//            self.eventSink(@{kNimPlayerMethod:@"onLoadingBegin",kNimPlayerId:_playerId});
//            break;
//        case AVPEventLoadingEnd:
//            self.eventSink(@{kNimPlayerMethod:@"onLoadingEnd",kNimPlayerId:_playerId});
//            break;
//        case AVPEventCompletion:
//            self.eventSink(@{kNimPlayerMethod:@"onCompletion",kNimPlayerId:_playerId});
//            break;
//        case AVPEventSeekEnd:
//            self.eventSink(@{kNimPlayerMethod:@"onSeekComplete",kNELivePlayerControllerId:_playerId});
//            break;
//        default:
//            break;
//    }
//}

/**
 @brief 播放器事件回调
 @param player 播放器player指针
 @param eventWithString 播放器事件类型
 @param description 播放器事件说明
 @see AVPEventType
 */
//-(void)onPlayerEvent:(NELivePlayerController*)player eventWithString:(AVPEventWithString)eventWithString description:(NSString *)description {
//    self.eventSink(@{kNimPlayerMethod:@"onInfo",@"infoCode":@(eventWithString),@"extraMsg":description,kNimPlayerId:_playerId});
//}

/**
 @brief 视频缓冲进度回调
 @param player 播放器player指针
 @param progress 缓存进度0-100
 */
//- (void)onLoadingProgress:(NELivePlayerController*)player progress:(float)progress {
//    self.eventSink(@{kNimPlayerMethod:@"onLoadingProgress",@"percent":@((int)progress),kNimPlayerId:_playerId});
//}

-(void)bindPlayerView:(FlutterNimPlayerView*)fapv{
    _fapv = fapv;
    self.player.view.frame = fapv.view.bounds;
    [fapv.view addSubview:self.player.view];
}

#pragma --mark getters
- (NELivePlayerController *)player{
    if (!_player) {
        _player = [[NELivePlayerController alloc] init];
    }
    return _player;
}

@end
