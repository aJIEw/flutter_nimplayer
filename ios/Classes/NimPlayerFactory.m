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
    FlutterNimPlayerView *fapv = [_viewDic objectForKey:viewIdKey];
    if (fapv) {
        //更新参数
        [fapv updateWithWithFrame:frame arguments:args];
    }else{
        fapv =
        [[FlutterNimPlayerView alloc] initWithWithFrame:frame
                                         viewIdentifier:viewId
                                              arguments:args
                                        binaryMessenger:_messenger];
        [_viewDic setObject:fapv forKey:viewIdKey];
    }
    
    return fapv;
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
    FlutterNimPlayerView *fapv = [_viewDic objectForKey:[NSString stringWithFormat:@"%@",viewId]];
    [proxy bindPlayerView:fapv];
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

- (void)prepare:(NSArray*)arr {
    FlutterResult result = arr[1];
    NimPlayerProxy *proxy = arr[2];
//    [proxy.player setShouldAutoplay:YES];
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

- (void)destroy:(NSArray*)arr {
    FlutterResult result = arr[1];
    NimPlayerProxy *proxy = arr[2];
    [proxy.player shutdown];
    
    if ([_playerProxyDic objectForKey:proxy.playerId]) {
        [_playerProxyDic removeObjectForKey:proxy.playerId];
    }
    
    if (proxy.fapv) {
        NSString *viewId = [NSString stringWithFormat:@"%li",(long)proxy.fapv.viewId];
        if ([_viewDic objectForKey:viewId]) {
            [_viewDic removeObjectForKey:viewId];
        }
    }
    result(nil);
}

- (void)seekTo:(NSArray*)arr {
    FlutterResult result = arr[1];
    NimPlayerProxy *proxy = arr[2];
    NSDictionary* dic = arr[3];
    NSNumber *position = dic[@"position"];
    [proxy.player setCurrentPlaybackTime:position.integerValue];
    result(nil);
}

@end

