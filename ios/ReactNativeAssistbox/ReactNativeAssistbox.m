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
	ASTEventManager.shared.delegate = self;
	return [super init];
}

RCT_EXPORT_MODULE()

+ (BOOL)requiresMainQueueSetup {
	return NO;
}

RCT_EXPORT_METHOD(initVideoCallWithToken:(NSDictionary *)options
				  successCallback: (RCTResponseSenderBlock)successCallback
				  errorCallback: (RCTResponseSenderBlock)errorCallback {
	
	AssistboxOptions* assistboxOpt = [self createAssistboxOptionsFromDictionary:options];
	
	if (assistboxOpt.token == nil || [assistboxOpt.token length] == 0){
		errorCallback(@[@"Token is required"]);
		return;
	}
	if (assistboxOpt.mobileServiceEndpoint == nil || [assistboxOpt.mobileServiceEndpoint length] == 0){
		errorCallback(@[@"Mobile Service Endpoint is required"]);
		return;
	}
	
	dispatch_async(dispatch_get_main_queue(), ^{
		UIViewController* vc = [self getViewController];
		NSLog(@"viewController: %@", vc);
		[[Assistbox shared] initVideoCallWithTokenWithViewController:vc options:assistboxOpt];
		successCallback(@[@"Opening Assistbox SDK"]);
	});
});

RCT_EXPORT_METHOD(initVideoCallWithAccessKey:(NSDictionary *)options
				  successCallback: (RCTResponseSenderBlock)successCallback
				  errorCallback: (RCTResponseSenderBlock)errorCallback {
	
	AssistboxOptions* assistboxOpt = [self createAssistboxOptionsFromDictionary:options];
	
	if (assistboxOpt.accessKey == nil || [assistboxOpt.accessKey length] == 0){
		errorCallback(@[@"Access Key is required"]);
		return;
	}
	if (assistboxOpt.mobileServiceEndpoint == nil || [assistboxOpt.mobileServiceEndpoint length] == 0){
		errorCallback(@[@"Mobile Service Endpoint is required"]);
		return;
	}
	
	dispatch_async(dispatch_get_main_queue(), ^{
		UIViewController* vc = [self getViewController];
		[[Assistbox shared] initVideoCallWithAccessKeyWithViewController:vc options:assistboxOpt];
		successCallback(@[@"Opening Assistbox SDK"]);
	});
});

RCT_EXPORT_METHOD(initC2CModuleAsAgent:(NSDictionary *)options
				  successCallback: (RCTResponseSenderBlock)successCallback
				  errorCallback: (RCTResponseSenderBlock)errorCallback {
	
	AssistboxOptions* assistboxOpt = [self createAssistboxOptionsFromDictionary:options];
	
	if (assistboxOpt.mobileServiceEndpoint == nil || [assistboxOpt.mobileServiceEndpoint length] == 0){
		errorCallback(@[@"Mobile Service Endpoint is required"]);
		return;
	}
	if (assistboxOpt.voipNotificationToken == nil || [assistboxOpt.voipNotificationToken length] == 0){
		errorCallback(@[@"VoIP Notification Token is required"]);
		return;
	}
	
	dispatch_async(dispatch_get_main_queue(), ^{
		UIViewController* vc = [self getViewController];
		[Assistbox.shared initC2CModuleAsAgentWithViewController:vc options:assistboxOpt];
		successCallback(@[@"Opening Assistbox SDK"]);
	});
});

RCT_EXPORT_METHOD(initC2CModuleAsClientWithApiKey:(NSDictionary *)options
				  successCallback: (RCTResponseSenderBlock)successCallback
				  errorCallback: (RCTResponseSenderBlock)errorCallback {
	
	AssistboxOptions* assistboxOpt = [self createAssistboxOptionsFromDictionary:options];
	
	if (assistboxOpt.mobileServiceEndpoint == nil || [assistboxOpt.mobileServiceEndpoint length] == 0){
		errorCallback(@[@"Mobile Service Endpoint is required"]);
		return;
	}
	if (assistboxOpt.apiKey == nil || [assistboxOpt.apiKey length] == 0){
		errorCallback(@[@"Api Key is required"]);
		return;
	}
	if (assistboxOpt.queueCode == nil || [assistboxOpt.queueCode length] == 0){
		errorCallback(@[@"Queue Code is required"]);
		return;
	}
	
	dispatch_async(dispatch_get_main_queue(), ^{
		UIViewController* vc = [self getViewController];
		[Assistbox.shared initC2CModuleAsClientWithApiKeyWithViewController:vc options:assistboxOpt];
		successCallback(@[@"Opening Assistbox SDK"]);
	});
});

RCT_EXPORT_METHOD(initC2CModuleAsClientWithToken:(NSDictionary *)options
				  successCallback: (RCTResponseSenderBlock)successCallback
				  errorCallback: (RCTResponseSenderBlock)errorCallback {
	
	AssistboxOptions* assistboxOpt = [self createAssistboxOptionsFromDictionary:options];
	
	if (assistboxOpt.mobileServiceEndpoint == nil || [assistboxOpt.mobileServiceEndpoint length] == 0){
		errorCallback(@[@"Mobile Service Endpoint is required"]);
		return;
	}
	if (assistboxOpt.token == nil || [assistboxOpt.token length] == 0){
		errorCallback(@[@"Token is required"]);
		return;
	}
	
	dispatch_async(dispatch_get_main_queue(), ^{
		UIViewController* vc = [self getViewController];
		[Assistbox.shared initC2CModuleAsClientWithTokenWithViewController:vc options:assistboxOpt];
		successCallback(@[@"Opening Assistbox SDK"]);
	});
});

- (UIViewController*) getViewController {
	UIViewController* topMostViewController = [self getTopMostViewController];
	if(topMostViewController.navigationController){
		return topMostViewController;
	} else {
		UIWindow *window = [[UIApplication sharedApplication] keyWindow];
		UIViewController* navController = (UIViewController*)window.rootViewController;
		return navController;
	}
}

- (UIViewController*) getTopMostViewController {
	UIViewController *presentingViewController = [[[UIApplication sharedApplication] delegate] window].rootViewController;
	while (presentingViewController.presentedViewController != nil) {
		presentingViewController = presentingViewController.presentedViewController;
	}
	return presentingViewController;
}

- (AssistboxOptions*) createAssistboxOptionsFromDictionary: (NSDictionary*) dictionary {
	AssistboxOptions* options = [[AssistboxOptions alloc] init];
	if ([dictionary valueForKey:@"token"] != nil) {
		options.token = (NSString*)[dictionary valueForKey:@"token"];
	}
	if ([dictionary valueForKey:@"accessKey"] != nil) {
		options.accessKey = (NSString*)[dictionary valueForKey:@"accessKey"];
	}
	if ([dictionary valueForKey:@"mobileServiceEndpoint"] != nil) {
		options.mobileServiceEndpoint = (NSString*)[dictionary valueForKey:@"mobileServiceEndpoint"];
	}
	if ([dictionary valueForKey:@"isNotificationBased"] != nil) {
		options.isNotificationBased = (BOOL)[dictionary valueForKey:@"isNotificationBased"];
	}
	if ([dictionary valueForKey:@"redirectToMainApplication"] != nil) {
		options.redirectToMainApplication = (BOOL)[dictionary valueForKey:@"redirectToMainApplication"];
	}
	if ([dictionary valueForKey:@"splashScreenResourceName"] != nil) {
		options.splashScreenResourceName = (NSString*)[dictionary valueForKey:@"splashScreenResourceName"];
	}
	if ([dictionary valueForKey:@"voipNotificationToken"] != nil) {
		options.voipNotificationToken = (NSString*)[dictionary valueForKey:@"voipNotificationToken"];
	}
	if ([dictionary valueForKey:@"apiKey"] != nil) {
		options.apiKey = (NSString*)[dictionary valueForKey:@"apiKey"];
	}
	if ([dictionary valueForKey:@"queueCode"] != nil) {
		options.queueCode = (NSString*)[dictionary valueForKey:@"queueCode"];
	}
	if ([dictionary valueForKey:@"productName"] != nil) {
		options.productName = (NSString*)[dictionary valueForKey:@"productName"];
	}
	if ([dictionary valueForKey:@"language"] != nil) {
		options.language = (NSString*)[dictionary valueForKey:@"language"];
	}
	if ([dictionary valueForKey:@"firstName"] != nil) {
		options.firstName = (NSString*)[dictionary valueForKey:@"firstName"];
	}
	if ([dictionary valueForKey:@"lastName"] != nil) {
		options.lastName = (NSString*)[dictionary valueForKey:@"lastName"];
	}
	if ([dictionary valueForKey:@"email"] != nil) {
		options.email = (NSString*)[dictionary valueForKey:@"email"];
	}
	if ([dictionary valueForKey:@"phone"] != nil) {
		options.phone = (NSString*)[dictionary valueForKey:@"phone"];
	}
	if ([dictionary valueForKey:@"regularNotificationToken"] != nil) {
		options.regularNotificationToken = (NSString*)[dictionary valueForKey:@"regularNotificationToken"];
	}
	if ([dictionary valueForKey:@"customParameter"] != nil) {
		options.customParameter = (NSString*)[dictionary valueForKey:@"customParameter"];
	}
	if ([dictionary valueForKey:@"externalLogoImageName"] != nil) {
		options.externalLogoImageName = (NSString*)[dictionary valueForKey:@"externalLogoImageName"];
	}
	return options;
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

// MARK: AssistboxEventDelegate Methods

- (void)onClose{
	[self sendAssistboxRedirectEvent];
}

@end

