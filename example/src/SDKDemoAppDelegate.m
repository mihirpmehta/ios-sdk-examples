#if !defined(__has_feature) || !__has_feature(objc_arc)
#error "This file requires ARC support."
#endif

#import "SDKDemoAppDelegate.h"
#import "SDKDemoMasterViewController.h"
#import "ApiKeys.h"

@implementation SDKDemoAppDelegate {
    id services_;
}

@synthesize window = _window;

- (BOOL)application:(UIApplication *)application
didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    NSLog(@"Build version: %d", __apple_build_version__);

    if ([kAPIKey length] == 0 || [kAPISecret length] == 0) {
        // Blow up if APIKey has not yet been set.
        NSString *bundleId = [[NSBundle mainBundle] bundleIdentifier];
        NSString *format = @"Configure API key and API secret inside ApiKeys.h for your "
        @"bundle `%@`";
        @throw [NSException exceptionWithName:@"SDKDemoAppDelegate"
                                       reason:[NSString stringWithFormat:format, bundleId]
                                     userInfo:nil];
    }
    if ([kFloorplanId length] == 0 ) {
        // Blow up if floor plan id has not yet been set.
        // Setting floor plan id in iOS platform is recommended.
        // Due to platform restrictions, it is not always possible to automatically detect floor plan.
        // Remove this check if you want to test the automatic detection.
        @throw [NSException exceptionWithName:@"SDKDemoAppDelegate"
                                       reason:@"Configure floor plan id inside ApiKeys.h"
                                     userInfo:nil];
    }
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    SDKDemoMasterViewController *master = [[SDKDemoMasterViewController alloc] init];
    master.appDelegate = self;
    self.navigationController =
    [[UINavigationController alloc] initWithRootViewController:master];

    // Force non-translucent navigation bar for consistency of demo between
    // iOS 6 and iOS 7.
    self.navigationController.navigationBar.translucent = NO;

    self.window.rootViewController = self.navigationController;

    [self.window makeKeyAndVisible];
    return YES;
}


@end
