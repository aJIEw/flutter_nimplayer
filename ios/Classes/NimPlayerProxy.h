#import <Foundation/Foundation.h>
#import <Flutter/Flutter.h>
#import <NELivePlayerFramework/NELivePlayerFramework.h>
#import "FlutterNimPlayerView.h"

#define kNimPlayerMethod    @"method"
#define kNimPlayerId        @"playerId"

NS_ASSUME_NONNULL_BEGIN

@interface NimPlayerProxy : NSObject

@property (nonatomic, copy) FlutterEventSink eventSink;

@property(nonatomic,strong,nullable) NELivePlayerController *player;

@property(nonatomic,strong) NSString *playerId;

@property(nonatomic,strong) FlutterNimPlayerView *fapv;

-(void)bindPlayerView:(FlutterNimPlayerView*)fapv;

@end

NS_ASSUME_NONNULL_END
