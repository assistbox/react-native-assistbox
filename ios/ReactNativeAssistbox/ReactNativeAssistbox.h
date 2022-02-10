//
//  ReactNativeAssistbox.h
//  react-native-assistbox
//

#import <UIKit/UIKit.h>
#import <React/RCTBridgeModule.h>
#import <React/RCTEventEmitter.h>
#import <React/RCTUtils.h>
#import <AssistBoxLib/AssistBoxViewController.h>

@interface ReactNativeAssistbox : RCTEventEmitter <RCTBridgeModule, AssistBoxViewDelegate>
@end
