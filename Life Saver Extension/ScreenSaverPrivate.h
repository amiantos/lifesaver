#import <AppKit/AppKit.h>
#import <Foundation/Foundation.h>
#import <ScreenSaver/ScreenSaver.h>

@interface ScreenSaverExtension : NSObject <NSExtensionRequestHandling>
@end

@interface ScreenSaverViewController : NSViewController
- (void)startAnimation;
- (void)stopAnimation;
@end

@interface ScreenSaverConfigurationViewController : NSViewController
@end
