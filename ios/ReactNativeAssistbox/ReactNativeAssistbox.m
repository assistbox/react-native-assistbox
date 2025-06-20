//
//  ReactNativeAssistbox.m
//  react-native-assistbox
//

#import "ReactNativeAssistbox.h"

@interface ReactNativeAssistbox ()
- (UIColor *)colorFromHexString:(NSString *)hexString;
@end

@implementation ReactNativeAssistbox
{
}

- (instancetype)init {
	ASTEventManager.shared.delegate = self;
	return [super init];
}

RCT_EXPORT_MODULE()

+ (BOOL)requiresMainQueueSetup {
	return NO;
}

RCT_EXPORT_METHOD(setEventListenerStatus:(NSString *)eventName isRegistered:(BOOL)isRegistered)
{
    if (!self.eventListenerRegistry) {
        self.eventListenerRegistry = [NSMutableDictionary new];
    }
    self.eventListenerRegistry[eventName] = @(isRegistered);
}

RCT_EXPORT_METHOD(showCustomViewController:(NSString *)vcClassName)
{
    dispatch_async(dispatch_get_main_queue(), ^{
        Class vcClass = NSClassFromString(vcClassName);
        if ([vcClass isSubclassOfClass:[UIViewController class]]) {
            UIViewController *vc = [[vcClass alloc] init];
            [[Assistbox shared] showCustomViewController:vc];
        }
    });
}

RCT_EXPORT_METHOD(hideCustomViewController)
{
	dispatch_async(dispatch_get_main_queue(), ^{
		[[Assistbox shared] hideCustomViewController];
	});
}

RCT_EXPORT_METHOD(closeExternally)
{
	dispatch_async(dispatch_get_main_queue(), ^{
		UIViewController* vc = [self getViewController];
		if (vc != nil) {
			[[Assistbox shared] closeExternallyWithViewController:vc completion:^{
				NSLog(@"Assistbox closed externally.");
			}];
		} else {
			NSLog(@"[Assistbox] ViewController is nil.");
		}
	});
}

RCT_EXPORT_METHOD(initVideoCallWithToken:(NSDictionary *)options
				  successCallback:(RCTResponseSenderBlock)successCallback
				  errorCallback:(RCTResponseSenderBlock)errorCallback)
{
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
}

RCT_EXPORT_METHOD(initVideoCallWithAccessKey:(NSDictionary *)options
				  successCallback:(RCTResponseSenderBlock)successCallback
				  errorCallback:(RCTResponseSenderBlock)errorCallback)
{
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
}

RCT_EXPORT_METHOD(initC2CModuleAsAgent:(NSDictionary *)options
				  successCallback:(RCTResponseSenderBlock)successCallback
				  errorCallback:(RCTResponseSenderBlock)errorCallback)
{
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
}

RCT_EXPORT_METHOD(initC2CModuleAsClientWithApiKey:(NSDictionary *)options
				  successCallback:(RCTResponseSenderBlock)successCallback
				  errorCallback:(RCTResponseSenderBlock)errorCallback)
{
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
}

RCT_EXPORT_METHOD(initC2CModuleAsClientWithToken:(NSDictionary *)options
				  successCallback:(RCTResponseSenderBlock)successCallback
				  errorCallback:(RCTResponseSenderBlock)errorCallback)
{
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
}

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

RCT_EXPORT_METHOD(dispatchAssistboxAction:(NSString *)action params:(NSDictionary *)params)
{
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([action isEqualToString:@"openMicrophone"]) {
            [AssistboxActions.shared openMicrophone];
        } else if ([action isEqualToString:@"closeMicrophone"]) {
            [AssistboxActions.shared closeMicrophone];
        } else if ([action isEqualToString:@"openCamera"]) {
            [AssistboxActions.shared openCamera];
        } else if ([action isEqualToString:@"closeCamera"]) {
            [AssistboxActions.shared closeCamera];
        } else if ([action isEqualToString:@"switchCamera"]) {
            [AssistboxActions.shared switchCamera];
        } else if ([action isEqualToString:@"openFlash"]) {
            [AssistboxActions.shared openFlash];
        } else if ([action isEqualToString:@"closeFlash"]) {
            [AssistboxActions.shared closeFlash];
        } else if ([action isEqualToString:@"enterPictureInPicture"]) {
            [AssistboxActions.shared enterPictureInPicture];
        } else if ([action isEqualToString:@"stopMeeting"]) {
            [AssistboxActions.shared stopMeeting];
        } else if ([action isEqualToString:@"tryReconnection"]) {
            BOOL showReconnectionDialog = YES;
            if (params[@"showReconnectionDialog"] != nil) {
                showReconnectionDialog = [params[@"showReconnectionDialog"] boolValue];
            }
            [AssistboxActions.shared tryReconnection:showReconnectionDialog];
        }
    });
}

- (AssistboxOptions*) createAssistboxOptionsFromDictionary: (NSDictionary*) dictionary {
	AssistboxOptions* options = [[AssistboxOptions alloc] init];
	if ([dictionary valueForKey:@"accessToken"] != nil) {
		options.token = (NSString*)[dictionary valueForKey:@"accessToken"];
	}
	if ([dictionary valueForKey:@"accessKey"] != nil) {
		options.accessKey = (NSString*)[dictionary valueForKey:@"accessKey"];
	}
	if ([dictionary valueForKey:@"mobileServiceEndpoint"] != nil) {
		options.mobileServiceEndpoint = (NSString*)[dictionary valueForKey:@"mobileServiceEndpoint"];
	}
	if ([dictionary valueForKey:@"isNotificationBased"] != nil) {
		options.isNotificationBased = [(NSNumber*)[dictionary valueForKey:@"isNotificationBased"] boolValue];
	}
	if ([dictionary valueForKey:@"redirectToMainApplication"] != nil) {
		options.redirectToMainApplication = [(NSNumber*)[dictionary valueForKey:@"redirectToMainApplication"] boolValue];
	}
	if ([dictionary valueForKey:@"splashScreenResourceName"] != nil) {
		NSString* imageName = (NSString*)[dictionary valueForKey:@"splashScreenResourceName"];
		options.splashScreenImage = [UIImage imageNamed:imageName];
	}
	if ([dictionary valueForKey:@"waitingScreenResourceName"] != nil) {
		NSString* imageName = (NSString*)[dictionary valueForKey:@"waitingScreenResourceName"];
		options.waitingScreenImage = [UIImage imageNamed:imageName];
	}
	if ([dictionary valueForKey:@"callKitIconResourceName"] != nil) {
		NSString* imageName = (NSString*)[dictionary valueForKey:@"callKitIconImage"];
		options.callKitIconImage = [UIImage imageNamed:imageName];
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
	if ([dictionary valueForKey:@"preferredLanguage"] != nil) {
		NSString* langCode = (NSString*)[dictionary valueForKey:@"preferredLanguage"];
		options.preferredLanguage = [ASTLanguageHelper fromCode:langCode];
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
	if ([dictionary valueForKey:@"externalLogoResourceName"] != nil) {
		NSString* imageName = (NSString*)[dictionary valueForKey:@"externalLogoImage"];
		options.externalLogoImage = [UIImage imageNamed:imageName];
	}
	if ([dictionary valueForKey:@"extUrlParam"] != nil) {
		options.extUrlParam = (NSString*)[dictionary valueForKey:@"extUrlParam"];
	}
	if ([dictionary valueForKey:@"isCameraEnabled"] != nil) {
		options.isCameraEnabled = [(NSNumber*)[dictionary valueForKey:@"isCameraEnabled"] boolValue];
	}
	if ([dictionary valueForKey:@"endMeetingOnScreenRecord"] != nil) {
		options.endMeetingOnScreenRecord = [(NSNumber*)[dictionary valueForKey:@"endMeetingOnScreenRecord"] boolValue];
	}
	if ([dictionary valueForKey:@"pictureInPictureOptions"] != nil) {
		NSArray *pipStrings = [dictionary valueForKey:@"pictureInPictureOptions"];
		NSMutableArray *pipRawValues = [NSMutableArray array];

		for (NSString *optionString in pipStrings) {
			if ([optionString isEqualToString:@"enabled"]) {
				[pipRawValues addObject:@(0)];
			} else if ([optionString isEqualToString:@"inAppViewForiOS14AndBefore"]) {
				[pipRawValues addObject:@(1)];
			} else if ([optionString isEqualToString:@"hasMultitaskingCapability"]) {
				[pipRawValues addObject:@(2)];
			}
		}

		options.objcPictureInPictureOptions = [NSArray arrayWithArray:pipRawValues];
	}
	if ([dictionary valueForKey:@"hiddenComponentList"] != nil) {
		id hiddenList = [dictionary valueForKey:@"hiddenComponentList"];
		NSMutableArray *numericList = [NSMutableArray array];
		if ([hiddenList isKindOfClass:[NSArray class]]) {
			for (id item in hiddenList) {
				if ([item isKindOfClass:[NSString class]]) {
					NSInteger val = -1;
					if ([item isEqualToString:@"BTN_MICROPHONE"]) val = ComponentBTN_MICROPHONE;
					else if ([item isEqualToString:@"BTN_CAMERA"]) val = ComponentBTN_CAMERA;
					else if ([item isEqualToString:@"BTN_CAMERA_SWITCH"]) val = ComponentBTN_CAMERA_SWITCH;
					else if ([item isEqualToString:@"BTN_CHAT"]) val = ComponentBTN_CHAT;
					else if ([item isEqualToString:@"BTN_CHAT_ATTACHMENT"]) val = ComponentBTN_CHAT_ATTACHMENT;
					else if ([item isEqualToString:@"BTN_FLASH"]) val = ComponentBTN_FLASH;
					else if ([item isEqualToString:@"BTN_PICTURE_IN_PICTURE"]) val = ComponentBTN_PICTURE_IN_PICTURE;
					else if ([item isEqualToString:@"BTN_HOLD"]) val = ComponentBTN_HOLD;
					else if ([item isEqualToString:@"BTN_QUEUE_FORWARD"]) val = ComponentBTN_QUEUE_FORWARD;
					else if ([item isEqualToString:@"BTN_CONTACT_FORM"]) val = ComponentBTN_CONTACT_FORM;
					else if ([item isEqualToString:@"BTN_END_MEETING"]) val = ComponentBTN_END_MEETING;
					else if ([item isEqualToString:@"BTN_CUSTOMER_INFO"]) val = ComponentBTN_CUSTOMER_INFO;
					else if ([item isEqualToString:@"BTN_EXTERNAL_LINK"]) val = ComponentBTN_EXTERNAL_LINK;
					else if ([item isEqualToString:@"LBL_QUEUE_ORDER"]) val = ComponentLBL_QUEUE_ORDER;
					else if ([item isEqualToString:@"LBL_WAITING_QUEUE"]) val = ComponentLBL_WAITING_QUEUE;
					else if ([item isEqualToString:@"BTN_PIN_VIDEO_VIEW"]) val = ComponentBTN_PIN_VIDEO_VIEW;
					
					if (val != -1) {
						[numericList addObject:@(val)];
					}
				} else if ([item isKindOfClass:[NSNumber class]]) {
					[numericList addObject:item];
				}
			}
			options.objcHiddenComponentList = numericList;
		}
	}
	if ([dictionary valueForKey:@"enableCallKit"] != nil) {
		options.enableCallKit = [(NSNumber*)[dictionary valueForKey:@"enableCallKit"] boolValue];
	}
	if ([dictionary valueForKey:@"correlationId"] != nil) {
		options.correlationId = (NSString*)[dictionary valueForKey:@"correlationId"];
	}
	if ([dictionary valueForKey:@"maxBitrate"] != nil) {
		options.maxBitrate = (NSNumber*)[dictionary valueForKey:@"maxBitrate"];
	}
	if ([dictionary valueForKey:@"waitingPlaylistName"] != nil) {
		options.waitingPlaylistName = (NSString*)[dictionary valueForKey:@"waitingPlaylistName"];
	}
	if ([dictionary valueForKey:@"holdPlaylistName"] != nil) {
		options.holdPlaylistName = (NSString*)[dictionary valueForKey:@"holdPlaylistName"];
	}
	if ([dictionary valueForKey:@"appointmentStatusToPlayWaitingPlaylist"] != nil) {
		NSString *statusString = [dictionary valueForKey:@"appointmentStatusToPlayWaitingPlaylist"];
		NSNumber *statusNumber = nil;
		if ([statusString isEqualToString:@"NEW"]) statusNumber = @(0);
		else if ([statusString isEqualToString:@"REJ"]) statusNumber = @(1);
		else if ([statusString isEqualToString:@"INP"]) statusNumber = @(2);
		else if ([statusString isEqualToString:@"WAI"]) statusNumber = @(3);
		else if ([statusString isEqualToString:@"COM"]) statusNumber = @(4);
		else if ([statusString isEqualToString:@"QUE"]) statusNumber = @(5);

		options.objcAppointmentStatusToPlayWaitingPlaylist = statusNumber;
	}
	if ([dictionary valueForKey:@"disableInternalNavigationOnCompletion"] != nil) {
		options.disableInternalNavigationOnCompletion = [(NSNumber*)[dictionary valueForKey:@"disableInternalNavigationOnCompletion"] boolValue];
	}
	if ([dictionary valueForKey:@"meetingButtonIcons"] != nil) {
		NSDictionary *iconsDict = [dictionary valueForKey:@"meetingButtonIcons"];
		NSMutableDictionary *icons = [NSMutableDictionary dictionary];
		for (NSString *key in iconsDict) {
			NSString *imageName = [iconsDict valueForKey:key];
			UIImage *image = [UIImage imageNamed:imageName];
			if (image) {
				[icons setObject:image forKey:key];
			}
		}
		options.objcMeetingButtonIcons = icons;
	}
	if ([dictionary valueForKey:@"localViewPosition"] != nil) {
		NSString *positionString = [dictionary valueForKey:@"localViewPosition"];
		NSNumber *positionNumber = nil;

		if ([positionString isEqualToString:@"topLeft"]) {
			positionNumber = @(0);
		} else if ([positionString isEqualToString:@"topRight"]) {
			positionNumber = @(1);
		} else if ([positionString isEqualToString:@"bottomLeft"]) {
			positionNumber = @(2);
		} else if ([positionString isEqualToString:@"bottomRight"]) {
			positionNumber = @(3);
		}

		if (positionNumber != nil) {
			options.objcLocalViewPosition = positionNumber;
		}
	}
	if ([dictionary valueForKey:@"disableVideoViewInteraction"] != nil) {
		options.disableVideoViewInteraction = [(NSNumber*)[dictionary valueForKey:@"disableVideoViewInteraction"] boolValue];
	}
	if ([dictionary valueForKey:@"videoCallBackgroundColor"] != nil) {
		NSString* hexString = (NSString*)[dictionary valueForKey:@"videoCallBackgroundColor"];
		options.videoCallBackgroundColor = [self colorFromHexString:hexString];
	}
	if ([dictionary valueForKey:@"progressBarColor"] != nil) {
		NSString* hexString = (NSString*)[dictionary valueForKey:@"progressBarColor"];
		options.progressBarColor = [self colorFromHexString:hexString];
	}
	if ([dictionary valueForKey:@"customFonts"] != nil) {
		NSDictionary *fontsMap = [dictionary valueForKey:@"customFonts"];
		NSMutableDictionary *customFonts = [NSMutableDictionary dictionary];
		for (NSString *weightStr in fontsMap) {
			NSDictionary *fontInfo = [fontsMap valueForKey:weightStr];
			NSString *fontResName = [fontInfo valueForKey:@"fontRes"];
			NSString *extensionStr = [fontInfo valueForKey:@"extension"];
			NSNumber *enumKey = nil;
			if ([weightStr isEqualToString:@"THIN"]) enumKey = @(100);
			else if ([weightStr isEqualToString:@"EXTRA_LIGHT"]) enumKey = @(200);
			else if ([weightStr isEqualToString:@"LIGHT"]) enumKey = @(300);
			else if ([weightStr isEqualToString:@"REGULAR"]) enumKey = @(400);
			else if ([weightStr isEqualToString:@"MEDIUM"]) enumKey = @(500);
			else if ([weightStr isEqualToString:@"SEMI_BOLD"]) enumKey = @(600);
			else if ([weightStr isEqualToString:@"BOLD"]) enumKey = @(700);
			else if ([weightStr isEqualToString:@"EXTRA_BOLD"]) enumKey = @(800);
			else if ([weightStr isEqualToString:@"BLACK"]) enumKey = @(900);
			
			if (enumKey) {
				CustomFont *font = [[CustomFont alloc] initWithFontName:fontResName fontExtensionString:extensionStr];
				[customFonts setObject:font forKey:enumKey];
			}
		}
		options.objcCustomFonts = customFonts;
	}
	return options;
}

- (UIColor *)colorFromHexString:(NSString *)hexString {
	unsigned rgbValue = 0;
	NSScanner *scanner = [NSScanner scannerWithString:hexString];
	if ([hexString hasPrefix:@"#"]) {
		scanner.scanLocation = 1;
	}
	[scanner scanHexInt:&rgbValue];
	return [UIColor colorWithRed:((rgbValue & 0xFF0000) >> 16)/255.0
						   green:((rgbValue & 0x00FF00) >> 8)/255.0
							blue:(rgbValue & 0x0000FF)/255.0
						   alpha:1.0];
}

// Called automatically by React Native to determine which events can be sent to JS.
- (NSArray<NSString *> *)supportedEvents {
    return @[
        @"onMeetingStart",
        @"onMeetingEnd",
        @"onJoinQueue",
        @"onLeaveQueue",
        @"onSocketConnectionSuccess",
        @"onSocketConnectionFail",
        @"onCameraToggle",
        @"onMicrophoneToggle",
        @"onCameraSwitch",
        @"onCameraSwitchError",
        @"onChatToggle",
        @"onFlashToggle",
        @"onFlashToggleError",
        @"onCaptureFrame",
        @"onPictureInPictureModeChanged",
        @"onHoldModeChanged",
        @"onRecordingError",
        @"onScreenRecordOrCapture",
        @"onClose",
        @"onHoldModeToggle",
        @"onMessageTemplateReceived",
        @"onPictureInPictureEnterFailed",
        @"onError",
        @"onEventHandlerError",
        @"onCameraDisconnected",
        @"onSocketReconnectionAttempt",
        @"onSocketReconnectionSuccess",
        @"onAppointmentStatusChanged",
        @"onOpenMicrophoneButtonClick",
        @"onCloseMicrophoneButtonClick",
        @"onOpenCameraButtonClick",
        @"onCloseCameraButtonClick",
        @"onOpenFlashButtonClick",
        @"onCloseFlashButtonClick",
        @"onSwitchCameraButtonClick",
        @"onEnterPictureInPictureButtonClick",
        @"onStopMeetingButtonClick"
    ];
}

// MARK: AssistboxEventDelegate Methods
- (void)onMeetingStartWithAppointmentId:(NSInteger)appointmentId participantId:(NSInteger)participantId {
    [self sendEventWithName:@"onMeetingStart" body:@{
        @"appointmentId": @(appointmentId),
        @"participantId": @(participantId)
    }];
}

- (void)onMeetingEndWithAppointmentId:(NSInteger)appointmentId endReason:(NSString *)endReason {
    [self sendEventWithName:@"onMeetingEnd" body:@{
        @"appointmentId": @(appointmentId),
        @"endReason": endReason ?: @""
    }];
}

- (void)onJoinQueueWithQueueId:(NSInteger)queueId {
    [self sendEventWithName:@"onJoinQueue" body:@{ @"queueId": @(queueId) }];
}

- (void)onLeaveQueueWithQueueId:(NSInteger)queueId {
    [self sendEventWithName:@"onLeaveQueue" body:@{ @"queueId": @(queueId) }];
}

- (void)onSocketConnectionSuccess {
    [self sendEventWithName:@"onSocketConnectionSuccess" body:nil];
}

- (void)onSocketConnectionFailWithError:(NSString *)error {
    [self sendEventWithName:@"onSocketConnectionFail" body:@{ @"error": error ?: @"" }];
}

- (void)onCameraToggleWithIsCameraOn:(BOOL)isCameraOn {
    [self sendEventWithName:@"onCameraToggle" body:@{ @"isCameraOn": @(isCameraOn) }];
}

- (void)onMicrophoneToggleWithIsMicrophoneOn:(BOOL)isMicrophoneOn {
    [self sendEventWithName:@"onMicrophoneToggle" body:@{ @"isMicrophoneOn": @(isMicrophoneOn) }];
}

- (void)onCameraSwitchWithMode:(NSString *)mode {
    [self sendEventWithName:@"onCameraSwitch" body:@{ @"mode": mode ?: @"" }];
}

- (void)onCameraSwitchErrorWithError:(NSString *)error {
    [self sendEventWithName:@"onCameraSwitchError" body:@{ @"error": error ?: @"" }];
}

- (void)onChatToggleWithIsChatOpen:(BOOL)isChatOpen {
    [self sendEventWithName:@"onChatToggle" body:@{ @"isChatOpen": @(isChatOpen) }];
}

- (void)onFlashToggleWithIsFlashOpen:(BOOL)isFlashOpen {
    [self sendEventWithName:@"onFlashToggle" body:@{ @"isFlashOpen": @(isFlashOpen) }];
}

- (void)onFlashToggleError {
    [self sendEventWithName:@"onFlashToggleError" body:nil];
}

- (void)onCaptureFrameWithBinaryFileId:(NSUInteger)binaryFileId {
    [self sendEventWithName:@"onCaptureFrame" body:@{ @"binaryFileId": @(binaryFileId) }];
}

- (void)onPictureInPictureModeChangedWithIsInPictureInPictureMode:(BOOL)isInPictureInPictureMode {
    [self sendEventWithName:@"onPictureInPictureModeChanged" body:@{ @"isInPictureInPictureMode": @(isInPictureInPictureMode) }];
}

- (void)onHoldModeChangedWithIsOnHoldMode:(BOOL)isOnHoldMode {
    [self sendEventWithName:@"onHoldModeChanged" body:@{ @"isOnHoldMode": @(isOnHoldMode) }];
}

- (void)onRecordingErrorWithType:(NSString *)type {
    [self sendEventWithName:@"onRecordingError" body:@{ @"type": type ?: @"" }];
}

- (void)onScreenRecordOrCapture {
    [self sendEventWithName:@"onScreenRecordOrCapture" body:nil];
}

- (void)onClose {
    [self sendEventWithName:@"onClose" body:nil];
}

- (void)onHoldModeToggleWithIsOnHoldMode:(BOOL)isOnHoldMode {
    [self sendEventWithName:@"onHoldModeToggle" body:@{ @"isOnHoldMode": @(isOnHoldMode) }];
}

- (void)onMessageTemplateReceivedWithMessageTemplate:(NSDictionary *)messageTemplate {
    [self sendEventWithName:@"onMessageTemplateReceived" body:messageTemplate ?: @{}];
}

- (void)onPictureInPictureEnterFailedWithError:(NSError *)error {
    [self sendEventWithName:@"onPictureInPictureEnterFailed" body:@{ @"error": error.localizedDescription ?: @"" }];
}

- (void)onErrorWithErrorCode:(NSInteger)errorCode error:(NSError *)error payload:(NSDictionary *)payload {
    NSMutableDictionary *body = [@{@"errorCode": @(errorCode)} mutableCopy];
    if (error) body[@"error"] = error.localizedDescription;
    if (payload) [body addEntriesFromDictionary:payload];
    [self sendEventWithName:@"onError" body:body];
}

- (void)onEventHandlerErrorWithPayload:(NSDictionary *)payload {
    [self sendEventWithName:@"onEventHandlerError" body:payload ?: @{}];
}

- (void)onCameraDisconnected {
    [self sendEventWithName:@"onCameraDisconnected" body:nil];
}

- (void)onSocketReconnectionAttempt {
    [self sendEventWithName:@"onSocketReconnectionAttempt" body:nil];
}

- (void)onSocketReconnectionSuccess {
    [self sendEventWithName:@"onSocketReconnectionSuccess" body:nil];
}

- (void)onAppointmentStatusChangedWithAppointmentStatus:(NSString *)appointmentStatus reason:(NSString *)reason {
    [self sendEventWithName:@"onAppointmentStatusChanged" body:@{
        @"appointmentStatus": appointmentStatus ?: @"",
        @"reason": reason ?: @""
    }];
}

- (void)onOpenMicrophoneButtonClick{
	BOOL isRegistered = [self.eventListenerRegistry[@"onOpenMicrophoneButtonClick"] boolValue];
	if (isRegistered && self.bridge) {
		[self sendEventWithName:@"onOpenMicrophoneButtonClick" body:nil];
	} else {
		[AssistboxActions.shared openMicrophone];
	}
}

- (void)onCloseMicrophoneButtonClick{
	BOOL isRegistered = [self.eventListenerRegistry[@"onCloseMicrophoneButtonClick"] boolValue];
	if (isRegistered && self.bridge) {
		[self sendEventWithName:@"onCloseMicrophoneButtonClick" body:nil];
	} else {
		[AssistboxActions.shared closeMicrophone];
	}
}

- (void)onOpenCameraButtonClick{
	BOOL isRegistered = [self.eventListenerRegistry[@"onOpenCameraButtonClick"] boolValue];
	if (isRegistered && self.bridge) {
		[self sendEventWithName:@"onOpenCameraButtonClick" body:nil];
	} else {
		[AssistboxActions.shared openCamera];
	}
}

- (void)onCloseCameraButtonClick{
	BOOL isRegistered = [self.eventListenerRegistry[@"onCloseCameraButtonClick"] boolValue];
	if (isRegistered && self.bridge) {
		[self sendEventWithName:@"onCloseCameraButtonClick" body:nil];
	} else {
		[AssistboxActions.shared closeCamera];
	}
}

- (void)onOpenFlashButtonClick{
	BOOL isRegistered = [self.eventListenerRegistry[@"onOpenFlashButtonClick"] boolValue];
	if (isRegistered && self.bridge) {
		[self sendEventWithName:@"onOpenFlashButtonClick" body:nil];
	} else {
		[AssistboxActions.shared openFlash];
	}
}

- (void)onCloseFlashButtonClick{
	BOOL isRegistered = [self.eventListenerRegistry[@"onCloseFlashButtonClick"] boolValue];
	if (isRegistered && self.bridge) {
		[self sendEventWithName:@"onCloseFlashButtonClick" body:nil];
	} else {
		[AssistboxActions.shared closeFlash];
	}
}

- (void)onSwitchCameraButtonClick{
	BOOL isRegistered = [self.eventListenerRegistry[@"onSwitchCameraButtonClick"] boolValue];
	if (isRegistered && self.bridge) {
		[self sendEventWithName:@"onSwitchCameraButtonClick" body:nil];
	} else {
		[AssistboxActions.shared switchCamera];
	}
}

- (void)onEnterPictureInPictureButtonClick{
	BOOL isRegistered = [self.eventListenerRegistry[@"onEnterPictureInPictureButtonClick"] boolValue];
	if (isRegistered && self.bridge) {
		[self sendEventWithName:@"onEnterPictureInPictureButtonClick" body:nil];
	} else {
		[AssistboxActions.shared enterPictureInPicture];
	}
}

- (void)onStopMeetingButtonClick{
	BOOL isRegistered = [self.eventListenerRegistry[@"onStopMeetingButtonClick"] boolValue];
	if (isRegistered && self.bridge) {
		[self sendEventWithName:@"onStopMeetingButtonClick" body:nil];
	} else {
		[AssistboxActions.shared stopMeeting];
	}
}
@end
