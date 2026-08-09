//
//  ReactNativeAssistbox.m
//  react-native-assistbox
//
//  Registers the Swift module (ReactNativeAssistbox.swift) with the RN bridge via
//  RCT_EXTERN macros. Selectors must match the Swift @objc signatures exactly;
//  a mismatch fails silently at runtime.
//

#import <React/RCTBridgeModule.h>
#import <React/RCTEventEmitter.h>

@interface RCT_EXTERN_MODULE(ReactNativeAssistbox, RCTEventEmitter)

RCT_EXTERN_METHOD(setEventListenerStatus:(NSString *)eventName isRegistered:(BOOL)isRegistered)

RCT_EXTERN_METHOD(showCustomViewController:(NSString *)vcClassName)

RCT_EXTERN_METHOD(hideCustomViewController)

RCT_EXTERN_METHOD(hideNativeSdk)

RCT_EXTERN_METHOD(showNativeSdk)

RCT_EXTERN_METHOD(closeExternally)

RCT_EXTERN_METHOD(closeNativeExternally)

// Legacy init methods
RCT_EXTERN_METHOD(initVideoCallWithToken:(NSDictionary *)options
                  successCallback:(RCTResponseSenderBlock)successCallback
                  errorCallback:(RCTResponseSenderBlock)errorCallback)

RCT_EXTERN_METHOD(initVideoCallWithAccessKey:(NSDictionary *)options
                  successCallback:(RCTResponseSenderBlock)successCallback
                  errorCallback:(RCTResponseSenderBlock)errorCallback)

RCT_EXTERN_METHOD(initC2CModuleAsAgent:(NSDictionary *)options
                  successCallback:(RCTResponseSenderBlock)successCallback
                  errorCallback:(RCTResponseSenderBlock)errorCallback)

RCT_EXTERN_METHOD(initC2CModuleAsClientWithApiKey:(NSDictionary *)options
                  successCallback:(RCTResponseSenderBlock)successCallback
                  errorCallback:(RCTResponseSenderBlock)errorCallback)

RCT_EXTERN_METHOD(initC2CModuleAsClientWithToken:(NSDictionary *)options
                  successCallback:(RCTResponseSenderBlock)successCallback
                  errorCallback:(RCTResponseSenderBlock)errorCallback)

// Native init methods
RCT_EXTERN_METHOD(initNativeVideoCallWithToken:(NSDictionary *)options
                  successCallback:(RCTResponseSenderBlock)successCallback
                  errorCallback:(RCTResponseSenderBlock)errorCallback)

RCT_EXTERN_METHOD(initNativeVideoCallWithAccessKey:(NSDictionary *)options
                  successCallback:(RCTResponseSenderBlock)successCallback
                  errorCallback:(RCTResponseSenderBlock)errorCallback)

RCT_EXTERN_METHOD(initNativeC2CModuleAsAgent:(NSDictionary *)options
                  successCallback:(RCTResponseSenderBlock)successCallback
                  errorCallback:(RCTResponseSenderBlock)errorCallback)

RCT_EXTERN_METHOD(initNativeC2CModuleAsClientWithApiKey:(NSDictionary *)options
                  successCallback:(RCTResponseSenderBlock)successCallback
                  errorCallback:(RCTResponseSenderBlock)errorCallback)

RCT_EXTERN_METHOD(initNativeC2CModuleAsClientWithToken:(NSDictionary *)options
                  successCallback:(RCTResponseSenderBlock)successCallback
                  errorCallback:(RCTResponseSenderBlock)errorCallback)

RCT_EXTERN_METHOD(dispatchAssistboxAction:(NSString *)action params:(NSDictionary *)params)

@end
