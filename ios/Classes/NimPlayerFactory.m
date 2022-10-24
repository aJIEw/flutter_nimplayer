#import "NimPlayerFactory.h"
#import "FlutterNimPlayerView.h"
#import "NimPlayerProxy.h"

@interface NimPlayerFactory () {
    NSObject<FlutterBinaryMessenger>* _messenger;
    FlutterMethodChannel* _commonChannel;
    UIView *playerView;
}
@property (nonatomic, assign) BOOL enableMix;

@property (nonatomic, strong) FlutterEventSink eventSink;
@property(nonatomic,strong) NSMutableDictionary *viewDic;
@property(nonatomic,strong) NSMutableDictionary *playerProxyDic;

@end

@implementation NimPlayerFactory

- (instancetype)initWithMessenger:(NSObject<FlutterBinaryMessenger>*)messenger {
    self = [super init];
    if (self) {
        _messenger = messenger;
        __weak __typeof__(self) weakSelf = self;
        
        _viewDic = @{}.mutableCopy;
        _playerProxyDic = @{}.mutableCopy;
        
        _commonChannel = [FlutterMethodChannel methodChannelWithName:@"flutter_nimplayer" binaryMessenger:messenger];
        [_commonChannel setMethodCallHandler:^(FlutterMethodCall* call, FlutterResult result) {
            NSObject* obj = [call arguments];
            if ([obj isKindOfClass:NSDictionary.class]) {
                NSDictionary *dic = (NSDictionary*)obj;
                NSString *playerId = [dic objectForKey:@"playerId"];
                NimPlayerProxy *proxy = [weakSelf.playerProxyDic objectForKey:playerId];
                
                if(!proxy && playerId.length>0 && ![call.method isEqualToString:@"createPlayer"]){
                    NSLog(@"flutter nimplayer sdk err : player whith playerId %@ is not exist",playerId);
                    return;
                }
                
                NSObject *arguments= [dic objectForKey:@"arg"];
                [weakSelf onMethodCall:call result:result atObj:proxy?:@"" arg:arguments?:@""];
            }else{
                [weakSelf onMethodCall:call result:result atObj:@"" arg:@""];
            }
        }];
        
        FlutterEventChannel *eventChannel = [FlutterEventChannel eventChannelWithName:@"flutter_nimplayer_event" binaryMessenger:messenger];
        [eventChannel setStreamHandler:self];
        
    }
    return self;
}

#pragma mark - FlutterStreamHandler
- (FlutterError* _Nullable)onListenWithArguments:(id _Nullable)arguments
                                       eventSink:(FlutterEventSink)eventSink{
    self.eventSink = eventSink;
    return nil;
}

- (FlutterError* _Nullable)onCancelWithArguments:(id _Nullable)arguments {
    return nil;
}

- (NSObject<FlutterMessageCodec>*)createArgsCodec {
    return [FlutterStandardMessageCodec sharedInstance];
}

- (nonnull NSObject<FlutterPlatformView> *)createWithFrame:(CGRect)frame
                                            viewIdentifier:(int64_t)viewId
                                                 arguments:(id _Nullable)args {
    NSString *viewIdKey = [NSString stringWithFormat:@"%lli",viewId];
    FlutterNimPlayerView *fnpv = [_viewDic objectForKey:viewIdKey];
    if (fnpv) {
        [fnpv updateWithWithFrame:frame arguments:args];
    }else{
        fnpv =
        [[FlutterNimPlayerView alloc] initWithWithFrame:frame
                                         viewIdentifier:viewId
                                              arguments:args
                                        binaryMessenger:_messenger];
        [_viewDic setObject:fnpv forKey:viewIdKey];
    }
    
    return fnpv;
}

- (void)onMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result atObj:(NSObject*)player arg:(NSObject*)arg{
    NSString* method = [call method];
    SEL methodSel=NSSelectorFromString([NSString stringWithFormat:@"%@:",method]);
    NSArray *arr = @[call,result,player,arg];
    if([self respondsToSelector:methodSel]){
        IMP imp = [self methodForSelector:methodSel];
        void (*func)(id, SEL, NSArray*) = (void *)imp;
        func(self, methodSel, arr);
    }else{
        result(FlutterMethodNotImplemented);
    }
}


-(void)createPlayer:(NSArray*)arr {
    FlutterMethodCall* call = arr.firstObject;
    FlutterResult result = arr[1];
    NSDictionary *dic = [call arguments];
    NSString *playerId = [dic objectForKey:@"playerId"];
    NimPlayerProxy *proxy = [NimPlayerProxy new];
    proxy.playerId = playerId;
    proxy.eventSink = self.eventSink;
    
    [_playerProxyDic setObject:proxy forKey:playerId];
    
    result(nil);
}

- (void)setPlayerView:(NSArray*)arr {
    FlutterResult result = arr[1];
    NimPlayerProxy *proxy = arr[2];
    NSNumber* viewId = arr[3];
    FlutterNimPlayerView *fnpv = [_viewDic objectForKey:[NSString stringWithFormat:@"%@",viewId]];
    [proxy bindPlayerView:fnpv];
    [proxy doInitPlayerNotification];
    result(nil);
}

- (void)setUrl:(NSArray*)arr {
    FlutterResult result = arr[1];
    NimPlayerProxy *proxy = arr[2];
    NSString* urlString = arr[3];
    NSURL* url = [NSURL URLWithString:urlString];
    [proxy.player setPlayUrl:url];
    result(nil);
}

- (void)setAutoPlay:(NSArray*)arr {
    FlutterResult result = arr[1];
    NimPlayerProxy *proxy = arr[2];
    NSNumber* val = arr[3];
    [proxy.player setShouldAutoplay:val.boolValue];
    result(nil);
}

- (void)setScalingMode:(NSArray*)arr {
    FlutterResult result = arr[1];
    NimPlayerProxy *proxy = arr[2];
    NSNumber* mode = arr[3];
    NELPMovieScalingMode scalingMode = NELPMovieScalingModeNone;
    switch (mode.intValue) {
        case 0:
            scalingMode = NELPMovieScalingModeFill;
            break;
        case 1:
            scalingMode = NELPMovieScalingModeAspectFit;
            break;
        case 2:
            scalingMode = NELPMovieScalingModeAspectFill;
            break;
        default:
            break;
    }
    [proxy.player setScalingMode:scalingMode];
    result(nil);
}

- (void)prepare:(NSArray*)arr {
    FlutterResult result = arr[1];
    NimPlayerProxy *proxy = arr[2];
    [proxy.player prepareToPlay];
    result(nil);
}

- (void)play:(NSArray*)arr {
    FlutterResult result = arr[1];
    NimPlayerProxy *proxy = arr[2];
    [proxy.player play];
    result(nil);
}

- (void)pause:(NSArray*)arr {
    FlutterResult result = arr[1];
    NimPlayerProxy *proxy = arr[2];
    [proxy.player pause];
    result(nil);
}

- (void)switchContentUrl:(NSArray*)arr {
    FlutterResult result = arr[1];
    NimPlayerProxy *proxy = arr[2];
    NSString* urlString = arr[3];
    NSURL* url = [NSURL URLWithString:urlString];
    [proxy.player switchContentUrl:url];
    result(nil);
}

- (void)destroy:(NSArray*)arr {
    FlutterResult result = arr[1];
    NimPlayerProxy *proxy = arr[2];
    [proxy.player shutdown];
    
    if ([_playerProxyDic objectForKey:proxy.playerId]) {
        [_playerProxyDic removeObjectForKey:proxy.playerId];
    }
    
    if (proxy.fnpv) {
        NSString *viewId = [NSString stringWithFormat:@"%li",(long)proxy.fnpv.viewId];
        if ([_viewDic objectForKey:viewId]) {
            [_viewDic removeObjectForKey:viewId];
        }
    }
    result(nil);
}

- (void)getDuration:(NSArray*)arr {
    FlutterResult result = arr[1];
    NimPlayerProxy *proxy = arr[2];
    __block NSInteger duration = [proxy.player duration]; // 单位是秒
    result(@((int)duration * 1000)); // 转换成毫秒返回
}

- (void)getCurrentPosition:(NSArray*)arr {
    FlutterResult result = arr[1];
    NimPlayerProxy *proxy = arr[2];
    __block NSInteger position = [proxy.player currentPlaybackTime];
    result(@((int)position * 1000));
}

- (void)seekTo:(NSArray*)arr {
    FlutterResult result = arr[1];
    NimPlayerProxy *proxy = arr[2];
    NSDictionary* dic = arr[3];
    NSNumber *position = dic[@"position"]; // 单位是毫秒
    [proxy.player setCurrentPlaybackTime:(int)([position doubleValue] / 1000)]; // 设置时需要先转换成秒
    result(nil);
}

@end

