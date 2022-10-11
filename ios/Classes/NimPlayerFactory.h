#import <Flutter/Flutter.h>
#import <Foundation/Foundation.h>
#import <NELivePlayerFramework/NELivePlayerFramework.h>

NS_ASSUME_NONNULL_BEGIN

@interface NimPlayerFactory : NSObject<FlutterPlatformViewFactory,FlutterStreamHandler>

- (instancetype)initWithMessenger:(NSObject<FlutterBinaryMessenger>*)messenger;

@end

NS_ASSUME_NONNULL_END
