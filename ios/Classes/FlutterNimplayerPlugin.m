#import "FlutterNimplayerPlugin.h"
#if __has_include(<flutter_nimplayer/flutter_nimplayer-Swift.h>)
#import <flutter_nimplayer/flutter_nimplayer-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "flutter_nimplayer-Swift.h"
#endif

@implementation FlutterNimplayerPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftFlutterNimplayerPlugin registerWithRegistrar:registrar];
}
@end
