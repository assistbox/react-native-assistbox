//
//  ReactNativeAssistbox.m
//  react-native-assistbox
//

#import "ReactNativeAssistbox.h"

@implementation ReactNativeAssistbox
{
	bool hasListeners;
}
- (instancetype)init {
	return [super init];
}

RCT_EXPORT_MODULE()

+ (BOOL)requiresMainQueueSetup {
	return NO;
}

RCT_EXPORT_METHOD(goToAssistbox:(NSString *)token
				  mobileServiceEndpoint:(NSString *)mobileServiceEndpoint
				  mobileStorageEndpoint:(NSString *)mobileStorageEndpoint
				  splashScreenResourceName:(NSString *)splashScreenResourceName
				  successCallback: (RCTResponseSenderBlock)successCallback
				  errorCallback: (RCTResponseSenderBlock)errorCallback {

#if TARGET_IPHONE_SIMULATOR
	errorCallback(@[@"Assistbox SDK does not support iOS Simulators"]);
	return;
#endif

	dispatch_async(dispatch_get_main_queue(), ^{
		NSBundle *frameworkBundle = [NSBundle bundleForClass:[AssistBoxViewController class]];
		UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"AssistBox" bundle:frameworkBundle];
		AssistBoxViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"assistBoxViewController"];
		vc.delegate = self;
		
		if (token == nil || [token length] == 0){
			errorCallback(@[@"Token is required"]);
			return;
		}
		if (mobileServiceEndpoint == nil || [mobileServiceEndpoint length] == 0){
			errorCallback(@[@"Mobile Service Endpoint is required"]);
			return;
		}
		if (mobileStorageEndpoint == nil || [mobileStorageEndpoint length] == 0){
			errorCallback(@[@"Mobile Storage Endpoint is required"]);
			return;
		}
		
		vc.token = token;
		vc.mobileServiceEndpoint = mobileServiceEndpoint;
		vc.mobileStorageEndpoint = mobileStorageEndpoint;
		vc.splashScreenResourceName = splashScreenResourceName;
		vc.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
		
		UIWindow *window = [[UIApplication sharedApplication] keyWindow];
		
		UIViewController* topMostViewController = [self getTopMostViewController];
		
		if(topMostViewController.navigationController){
			vc.isMainAppNavigationBarHidden = topMostViewController.navigationController.isNavigationBarHidden;
			if(!topMostViewController.navigationController.isNavigationBarHidden){
				topMostViewController.navigationController.navigationBar.hidden = true;
			}
			vc.hasNavigationStack = YES;
			[topMostViewController.navigationController pushViewController:vc animated:NO];
		} else {
			UIViewController* navController = (UIViewController*)window.rootViewController;
			vc.hasNavigationStack = NO;
			[navController presentViewController:vc animated:NO completion:nil];
		}
		successCallback(@[@"Opening Assistbox SDK"]);
		
	});
});

- (UIViewController*) getTopMostViewController {
	UIViewController *presentingViewController = [[[UIApplication sharedApplication] delegate] window].rootViewController;
	while (presentingViewController.presentedViewController != nil) {
		presentingViewController = presentingViewController.presentedViewController;
	}
	return presentingViewController;
}

- (void)AssistBoxViewWillDisappear:(BOOL)animated {
	[self sendAssistboxRedirectEvent];
}

- (NSArray<NSString *> *)supportedEvents {
	return @[@"onAssistboxRedirectPrivate"];
}

-(void)startObserving {
	hasListeners = YES;
}

-(void)stopObserving {
	hasListeners = NO;
}

- (void) sendAssistboxRedirectEvent{
	if(hasListeners){
		[self sendEventWithName:@"onAssistboxRedirectPrivate" body:@{}];
	}
}

@end

