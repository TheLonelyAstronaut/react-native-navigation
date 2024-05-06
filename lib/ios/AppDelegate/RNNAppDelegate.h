#import <Foundation/Foundation.h>
#if __has_include(<React-RCTAppDelegate/RCTAppDelegate.h>)
#import <React-RCTAppDelegate/RCTAppDelegate.h>
#elif __has_include(<React_RCTAppDelegate/RCTAppDelegate.h>)
// for importing the header from framework, the dash will be transformed to underscore
#import <React_RCTAppDelegate/RCTAppDelegate.h>
#endif

#ifdef RCT_NEW_ARCH_ENABLED
#import <React/RCTComponentViewFactory.h>
#endif

@interface RNNAppDelegate : RCTAppDelegate<RCTComponentViewFactoryComponentProvider>

- (NSDictionary<NSString *, Class<RCTComponentViewProtocol>> *)thirdPartyFabricComponents;

@end
