//
//  ReactNativeAssistbox.h
//  react-native-assistbox
//

#import <UIKit/UIKit.h>
#import <React/RCTBridgeModule.h>
#import <React/RCTEventEmitter.h>
#import <React/RCTUtils.h>
#import <AssistboxLib/AssistboxLib-Swift.h>

@interface ReactNativeAssistbox : RCTEventEmitter <RCTBridgeModule, AssistboxEventDelegate>
@end
