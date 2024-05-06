#import "RNNAppDelegate.h"
#import <ReactNativeNavigation/ReactNativeNavigation.h>

#ifdef RCT_NEW_ARCH_ENABLED
#import "RCTAppSetupUtils.h"
#import <React/CoreModulesPlugins.h>
#import <React/RCTCxxBridgeDelegate.h>
#import <React/RCTLegacyViewManagerInteropComponentView.h>
#import <React/RCTSurfacePresenter.h>
#import <React/RCTSurfacePresenterStub.h>
#import <React/RCTSurfacePresenterBridgeAdapter.h>
#import <ReactCommon/RCTTurboModuleManager.h>
#import <react/config/ReactNativeConfig.h>
#import <react/renderer/runtimescheduler/RuntimeScheduler.h>
#import <react/renderer/runtimescheduler/RuntimeSchedulerCallInvoker.h>
#import <React/RCTSurfacePresenter.h>
#import <React/RCTComponentViewFactory.h>
#import <React/RCTBridge+Private.h>
#import <React/RCTImageLoader.h>
#import <React/RCTBridgeProxy.h>
#import <react/utils/ManagedObjectWrapper.h>

static NSString *const kRNConcurrentRoot = @"concurrentRoot";

@interface RNNAppDelegate () <RCTTurboModuleManagerDelegate, RCTCxxBridgeDelegate> {
    
}
@end

#endif

@implementation RNNAppDelegate

- (BOOL)application:(UIApplication *)application
    didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    RCTAppSetupPrepareApp(application, self.turboModuleEnabled);
    self.rootViewFactory = [self createRCTRootViewFactory];
    //NSDictionary *initProps = updateInitialProps(initialProperties, self.fabricEnabled);

#ifdef RCT_NEW_ARCH_ENABLED
    if (self.bridgelessEnabled) {
        RCTSetUseNativeViewConfigsInBridgelessMode(self.fabricEnabled);

        // Enable TurboModule interop by default in Bridgeless mode
        RCTEnableTurboModuleInterop(YES);
        RCTEnableTurboModuleInteropBridgeProxy(YES);
        
        self.rootViewFactory.reactHost = [self.rootViewFactory createReactHost:launchOptions];
        
        [RCTComponentViewFactory currentComponentViewFactory].thirdPartyFabricComponentsProvider = self;
        
        [ReactNativeNavigation bootstrapWithHost:self.rootViewFactory.reactHost];
        
        return YES;
    }
#endif

    // Force init bridge, ignoring generated RCTView
    [self.rootViewFactory viewWithModuleName:self.moduleName];
    
    if (self.fabricEnabled) {
      [RCTComponentViewFactory currentComponentViewFactory].thirdPartyFabricComponentsProvider = self;
    }
    
    [ReactNativeNavigation bootstrapWithBridge:self.bridge];
    
    return YES;
}

- (NSArray<id<RCTBridgeModule>> *)extraModulesForBridge:(RCTBridge *)bridge {
    return [ReactNativeNavigation extraModulesForBridge:bridge];
}


- (RCTRootViewFactory *)createRCTRootViewFactory
{
    __weak __typeof(self) weakSelf = self;
    RCTBundleURLBlock bundleUrlBlock = ^{
        RCTAppDelegate *strongSelf = weakSelf;
        return strongSelf.bundleURL;
    };
    
    RCTRootViewFactoryConfiguration *configuration =
    [[RCTRootViewFactoryConfiguration alloc] initWithBundleURLBlock:bundleUrlBlock
                                                     newArchEnabled:self.fabricEnabled
                                                 turboModuleEnabled:self.turboModuleEnabled
                                                  bridgelessEnabled:self.bridgelessEnabled];
    
    configuration.createRootViewWithBridge = ^UIView *(RCTBridge *bridge, NSString *moduleName, NSDictionary *initProps)
    {
        return [weakSelf createRootViewWithBridge:bridge moduleName:moduleName initProps:initProps];
    };
    
    configuration.createBridgeWithDelegate = ^RCTBridge *(id<RCTBridgeDelegate> delegate, NSDictionary *launchOptions)
    {
        return [weakSelf createBridgeWithDelegate:delegate launchOptions:launchOptions];
    };
    
    return [[RCTRootViewFactory alloc] initWithConfiguration:configuration andTurboModuleManagerDelegate:self];
}

- (NSURL *)sourceURLForBridge:(RCTBridge *)bridge {
    [NSException raise:@"RCTBridgeDelegate::sourceURLForBridge not implemented"
                format:@"Subclasses must implement a valid sourceURLForBridge method"];
    return nil;
}

- (BOOL)concurrentRootEnabled {
    return true;
}

- (NSDictionary<NSString *, Class<RCTComponentViewProtocol>> *)thirdPartyFabricComponents
{
    return @{};
}

@end
