package io.assistbox.reactnative;

import android.content.BroadcastReceiver;
import android.content.Intent;
import android.content.Context;
import android.content.IntentFilter;

import com.facebook.react.bridge.Callback;
import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReactContextBaseJavaModule;
import com.facebook.react.bridge.ReactMethod;
import com.facebook.react.bridge.UiThreadUtil;
import com.facebook.react.modules.core.DeviceEventManagerModule;

import io.assistbox.Assistbox;
import io.assistbox.LogService;

public class ReactNativeAssistboxModule extends ReactContextBaseJavaModule {
	private static final String TAG = "ReactNativeAssistboxModule";

	private final ReactApplicationContext reactContext;

	BroadcastReceiver redirectReceiver = new BroadcastReceiver() {
		@Override
		public void onReceive(Context context, Intent intent) {
			LogService.info(TAG, "AssistboxRedirection Broadcast Received");
			reactContext.getJSModule(DeviceEventManagerModule.RCTDeviceEventEmitter.class)
					.emit("onAssistboxRedirectPrivate", null);
			try {
				context.unregisterReceiver(this);
			} catch(Exception e) {
				// TODO add error as parameter to error log with Assistbox SDK version 4.2.1
				LogService.error(TAG, "Encountered error while unregistering register");
			}
		}
	};

	public ReactNativeAssistboxModule(ReactApplicationContext reactContext) {
		super(reactContext);
		this.reactContext = reactContext;
	}

	@Override
	public String getName() {
		return "ReactNativeAssistbox";
	}

	@ReactMethod
	public void initVideoCallWithToken(String token,
									   String mobileServiceEndpoint,
									   String splashScreenResourceName,
									   String notificationIconResourceName,
									   String fcmToken,
									   Callback successCallback,
									   Callback errorCallback) {
		UiThreadUtil.runOnUiThread(() -> {
			try {
				if (token == null || token.isEmpty()) {
					errorCallback.invoke("Token is required");
					return;
				}
				if (mobileServiceEndpoint == null || mobileServiceEndpoint.isEmpty()) {
					errorCallback.invoke("Mobile Service Endpoint is required");
					return;
				}
				this.reactContext.registerReceiver(redirectReceiver, new IntentFilter("AssistboxRedirection"));
				int splashScreenResourceId = getDrawableResourceIdByName(splashScreenResourceName);
				int notificationIconResourceId = getMipmapResourceIdByName(notificationIconResourceName);

				Assistbox.initVideoCallWithToken(reactContext.getCurrentActivity(), token, mobileServiceEndpoint, splashScreenResourceId, notificationIconResourceId, fcmToken);
				successCallback.invoke("Opening Assistbox SDK");
			} catch(Exception e) {
				errorCallback.invoke(e.getMessage());
			}
		});
	}

	@ReactMethod
	public void initVideoCallWithAccessKey(String accessKey,
										   String mobileServiceEndpoint,
										   String splashScreenResourceName,
										   String notificationIconResourceName,
										   String fcmToken,
										   Callback successCallback,
										   Callback errorCallback) {
		UiThreadUtil.runOnUiThread(() -> {
			try {
				if (accessKey == null || accessKey.isEmpty()) {
					errorCallback.invoke("Access Key is required");
					return;
				}
				if (mobileServiceEndpoint == null || mobileServiceEndpoint.isEmpty()) {
					errorCallback.invoke("Mobile Service Endpoint is required");
					return;
				}
				this.reactContext.registerReceiver(redirectReceiver, new IntentFilter("AssistboxRedirection"));
				int splashScreenResourceId = getDrawableResourceIdByName(splashScreenResourceName);
				int notificationIconResourceId = getMipmapResourceIdByName(notificationIconResourceName);

				Assistbox.initVideoCallWithAccessKey(reactContext.getCurrentActivity(), accessKey, mobileServiceEndpoint, splashScreenResourceId, notificationIconResourceId, fcmToken);
				successCallback.invoke("Opening Assistbox SDK");
			} catch(Exception e) {
				errorCallback.invoke(e.getMessage());
			}
		});
	}

	@ReactMethod
	public void initC2CModuleAsAgent(String mobileServiceEndpoint,
									 String splashScreenResourceName,
									 String notificationIconResourceName,
									 String fcmToken,
									 String oneSignalPushId,
									 Callback successCallback,
									 Callback errorCallback) {
		UiThreadUtil.runOnUiThread(() -> {
			try {

				if (mobileServiceEndpoint == null || mobileServiceEndpoint.isEmpty()) {
					errorCallback.invoke("Mobile Service Endpoint is required");
					return;
				}
				if (fcmToken == null || fcmToken.isEmpty()) {
					errorCallback.invoke("Firebase Cloud Messaging Token is required");
					return;
				}
				this.reactContext.registerReceiver(redirectReceiver, new IntentFilter("AssistboxRedirection"));
				int splashScreenResourceId = getDrawableResourceIdByName(splashScreenResourceName);
				int notificationIconResourceId = getMipmapResourceIdByName(notificationIconResourceName);

				Assistbox.initC2CModuleAsAgent(reactContext.getCurrentActivity(), mobileServiceEndpoint, fcmToken, oneSignalPushId, splashScreenResourceId, notificationIconResourceId);
				successCallback.invoke("Opening Assistbox SDK");
			} catch(Exception e) {
				errorCallback.invoke(e.getMessage());
			}
		});
	}

	@ReactMethod
	public void initC2CModuleAsClientWithApiKey(String apiKey,
												String queueCode,
												String mobileServiceEndpoint,
												String firstName,
												String lastName,
												String email,
												String phone,
												String productName,
												String language,
												boolean showContactForm,
												String splashScreenResourceName,
												String notificationIconResourceName,
												Callback successCallback,
												Callback errorCallback) {
		UiThreadUtil.runOnUiThread(() -> {
			try {
				if (mobileServiceEndpoint == null || mobileServiceEndpoint.isEmpty()) {
					errorCallback.invoke("Mobile Service Endpoint is required");
					return;
				}
				if (apiKey == null || apiKey.isEmpty()) {
					errorCallback.invoke("Api Key is required");
					return;
				}
				if (queueCode == null || queueCode.isEmpty()) {
					errorCallback.invoke("Queue Code is required");
					return;
				}
				this.reactContext.registerReceiver(redirectReceiver, new IntentFilter("AssistboxRedirection"));
				int splashScreenResourceId = getDrawableResourceIdByName(splashScreenResourceName);
				int notificationIconResourceId = getMipmapResourceIdByName(notificationIconResourceName);

				Assistbox.initC2CModuleAsClientWithApiKey(reactContext.getCurrentActivity(), mobileServiceEndpoint, apiKey, queueCode, firstName, lastName, email, phone, productName,
						language, showContactForm, splashScreenResourceId, notificationIconResourceId);
				successCallback.invoke("Opening Assistbox SDK");
			} catch(Exception e) {
				errorCallback.invoke(e.getMessage());
			}
		});
	}

	@ReactMethod
	public void initC2CModuleAsClientWithToken(String token,
												String mobileServiceEndpoint,
												String splashScreenResourceName,
												String notificationIconResourceName,
												Callback successCallback,
												Callback errorCallback) {
		UiThreadUtil.runOnUiThread(() -> {
			try {
				if (mobileServiceEndpoint == null || mobileServiceEndpoint.isEmpty()) {
					errorCallback.invoke("Mobile Service Endpoint is required");
					return;
				}
				if (token == null || token.isEmpty()) {
					errorCallback.invoke("Token is required");
					return;
				}
				this.reactContext.registerReceiver(redirectReceiver, new IntentFilter("AssistboxRedirection"));
				int splashScreenResourceId = getDrawableResourceIdByName(splashScreenResourceName);
				int notificationIconResourceId = getMipmapResourceIdByName(notificationIconResourceName);

				Assistbox.initC2CModuleAsClientWithToken(reactContext.getCurrentActivity(), token, mobileServiceEndpoint, splashScreenResourceId, notificationIconResourceId);
				successCallback.invoke("Opening Assistbox SDK");
			} catch(Exception e) {
				errorCallback.invoke(e.getMessage());
			}
		});
	}

	private int getDrawableResourceIdByName(String resourceName) {
		if (resourceName == null || resourceName.isEmpty()) {
			return 0;
		}
		return reactContext.getResources().getIdentifier(resourceName, "drawable", reactContext.getPackageName());
	}

	private int getMipmapResourceIdByName(String resourceName) {
		if (resourceName == null || resourceName.isEmpty()) {
			return 0;
		}
		return reactContext.getResources().getIdentifier(resourceName, "mipmap", reactContext.getPackageName());
	}

}