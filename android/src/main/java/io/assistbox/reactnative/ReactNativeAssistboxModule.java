package io.assistbox.reactnative;

import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;

import androidx.annotation.NonNull;

import com.facebook.react.bridge.Callback;
import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReactContextBaseJavaModule;
import com.facebook.react.bridge.ReactMethod;
import com.facebook.react.bridge.ReadableMap;
import com.facebook.react.bridge.UiThreadUtil;
import com.facebook.react.modules.core.DeviceEventManagerModule;

import io.assistbox.Assistbox;
import io.assistbox.LogService;
import io.assistbox.enums.SupportedMessagingService;

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

	@NonNull
	@Override
	public String getName() {
		return "ReactNativeAssistbox";
	}

	@ReactMethod
	public void initVideoCallWithToken(ReadableMap options,
									   Callback successCallback,
									   Callback errorCallback) {
		Assistbox.AssistboxOptions assistboxOptions = createAssistboxOptionsFromReadableMap(options);

		UiThreadUtil.runOnUiThread(() -> {
			try {
				if (assistboxOptions.accessToken == null || assistboxOptions.accessToken.isEmpty()) {
					errorCallback.invoke("Token is required");
					return;
				}
				if (assistboxOptions.mobileServiceEndpoint == null || assistboxOptions.mobileServiceEndpoint.isEmpty()) {
					errorCallback.invoke("Mobile Service Endpoint is required");
					return;
				}
				if (reactContext.getCurrentActivity() == null) {
					errorCallback.invoke("Could not get current react activity");
					return;
				}

				this.reactContext.registerReceiver(redirectReceiver, new IntentFilter("AssistboxRedirection"));
				Assistbox.initVideoCallWithToken(reactContext.getCurrentActivity(), assistboxOptions);
				successCallback.invoke("Opening Assistbox SDK");
			} catch(Exception e) {
				errorCallback.invoke(e.getMessage());
			}
		});
	}

	@ReactMethod
	public void initVideoCallWithAccessKey(ReadableMap options,
										   Callback successCallback,
										   Callback errorCallback) {

		Assistbox.AssistboxOptions assistboxOptions = createAssistboxOptionsFromReadableMap(options);

		UiThreadUtil.runOnUiThread(() -> {
			try {
				if (assistboxOptions.accessKey == null || assistboxOptions.accessKey.isEmpty()) {
					errorCallback.invoke("Access Key is required");
					return;
				}
				if (assistboxOptions.mobileServiceEndpoint == null || assistboxOptions.mobileServiceEndpoint.isEmpty()) {
					errorCallback.invoke("Mobile Service Endpoint is required");
					return;
				}
				if (reactContext.getCurrentActivity() == null) {
					errorCallback.invoke("Could not get current react activity");
					return;
				}

				this.reactContext.registerReceiver(redirectReceiver, new IntentFilter("AssistboxRedirection"));
				Assistbox.initVideoCallWithAccessKey(reactContext.getCurrentActivity(), assistboxOptions);
				successCallback.invoke("Opening Assistbox SDK");
			} catch(Exception e) {
				errorCallback.invoke(e.getMessage());
			}
		});
	}

	@ReactMethod
	public void initC2CModuleAsAgent(ReadableMap options,
									 Callback successCallback,
									 Callback errorCallback) {

		Assistbox.AssistboxOptions assistboxOptions = createAssistboxOptionsFromReadableMap(options);

		UiThreadUtil.runOnUiThread(() -> {
			try {

				if (assistboxOptions.mobileServiceEndpoint == null || assistboxOptions.mobileServiceEndpoint.isEmpty()) {
					errorCallback.invoke("Mobile Service Endpoint is required");
					return;
				}
				if (assistboxOptions.pushToken == null || assistboxOptions.pushToken.isEmpty()) {
					errorCallback.invoke("Firebase Cloud Messaging Token is required");
					return;
				}
				if (reactContext.getCurrentActivity() == null) {
					errorCallback.invoke("Could not get current react activity");
					return;
				}

				this.reactContext.registerReceiver(redirectReceiver, new IntentFilter("AssistboxRedirection"));
				Assistbox.initC2CModuleAsAgent(reactContext.getCurrentActivity(), assistboxOptions);
				successCallback.invoke("Opening Assistbox SDK");
			} catch(Exception e) {
				errorCallback.invoke(e.getMessage());
			}
		});
	}

	@ReactMethod
	public void initC2CModuleAsClientWithApiKey(ReadableMap options,
												Callback successCallback,
												Callback errorCallback) {

		Assistbox.AssistboxOptions assistboxOptions = createAssistboxOptionsFromReadableMap(options);

		UiThreadUtil.runOnUiThread(() -> {
			try {
				if (assistboxOptions.mobileServiceEndpoint == null || assistboxOptions.mobileServiceEndpoint.isEmpty()) {
					errorCallback.invoke("Mobile Service Endpoint is required");
					return;
				}
				if (assistboxOptions.apiKey == null || assistboxOptions.apiKey.isEmpty()) {
					errorCallback.invoke("Api Key is required");
					return;
				}
				if (assistboxOptions.queueCode == null || assistboxOptions.queueCode.isEmpty()) {
					errorCallback.invoke("Queue Code is required");
					return;
				}
				if (reactContext.getCurrentActivity() == null) {
					errorCallback.invoke("Could not get current react activity");
					return;
				}

				this.reactContext.registerReceiver(redirectReceiver, new IntentFilter("AssistboxRedirection"));
				Assistbox.initC2CModuleAsClientWithApiKey(reactContext.getCurrentActivity(), assistboxOptions);
				successCallback.invoke("Opening Assistbox SDK");
			} catch(Exception e) {
				errorCallback.invoke(e.getMessage());
			}
		});
	}

	@ReactMethod
	public void initC2CModuleAsClientWithToken(ReadableMap options,
											   Callback successCallback,
											   Callback errorCallback) {

		Assistbox.AssistboxOptions assistboxOptions = createAssistboxOptionsFromReadableMap(options);

		UiThreadUtil.runOnUiThread(() -> {
			try {
				if (assistboxOptions.mobileServiceEndpoint == null || assistboxOptions.mobileServiceEndpoint.isEmpty()) {
					errorCallback.invoke("Mobile Service Endpoint is required");
					return;
				}
				if (assistboxOptions.accessToken == null || assistboxOptions.accessToken.isEmpty()) {
					errorCallback.invoke("Token is required");
					return;
				}
				if (reactContext.getCurrentActivity() == null) {
					errorCallback.invoke("Could not get current react activity");
					return;
				}

				this.reactContext.registerReceiver(redirectReceiver, new IntentFilter("AssistboxRedirection"));
				Assistbox.initC2CModuleAsClientWithToken(reactContext.getCurrentActivity(), assistboxOptions);
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

	private Assistbox.AssistboxOptions createAssistboxOptionsFromReadableMap(ReadableMap map) {
		Assistbox.AssistboxOptions options = new Assistbox.AssistboxOptions();
		if (map.hasKey("token")) {
			options.accessToken = map.getString("token");
		}
		if (map.hasKey("accessKey")) {
			options.accessKey = map.getString("accessKey");
		}
		if (map.hasKey("mobileServiceEndpoint")) {
			options.mobileServiceEndpoint = map.getString("mobileServiceEndpoint");
		}
		if (map.hasKey("apiKey")) {
			options.apiKey = map.getString("apiKey");
		}
		if (map.hasKey("queueCode")) {
			options.queueCode = map.getString("queueCode");
		}
		if (map.hasKey("splashScreenResourceName")) {
			String splashScreenResourceName = map.getString("splashScreenResourceName");
			options.splashScreenResourceId = getDrawableResourceIdByName(splashScreenResourceName);
		}
		if (map.hasKey("notificationIconResourceName")) {
			String notificationIconResourceName = map.getString("notificationIconResourceName");
			options.notificationIconResourceId = getMipmapResourceIdByName(notificationIconResourceName);
		}
		if (map.hasKey("externalLogoResourceName")) {
			String externalLogoResourceName = map.getString("externalLogoResourceName");
			options.externalLogoResourceId = getDrawableResourceIdByName(externalLogoResourceName);
		}
		if (map.hasKey("isNotificationBased")) {
			options.isNotificationBased = map.getBoolean("isNotificationBased");
		}
		if (map.hasKey("pushToken")) {
			options.pushToken = map.getString("pushToken");
		}
		if (map.hasKey("supportedMessagingService")) {
			options.supportedMessagingService = (SupportedMessagingService.valueOf(map.getString(
					"supportedMessagingService")));
		}
		if (map.hasKey("redirectToMainApplication")) {
			options.redirectToMainApplication = map.getBoolean("redirectToMainApplication");
		}
		if (map.hasKey("customParameter")) {
			options.customParameter = map.getString("customParameter");
		}
		if (map.hasKey("removeTaskOnFinish")) {
			options.removeTaskOnFinish = map.getBoolean("removeTaskOnFinish");
		}
		if (map.hasKey("firstName")) {
			options.firstName = map.getString("firstName");
		}
		if (map.hasKey("lastName")) {
			options.lastName = map.getString("lastName");
		}
		if (map.hasKey("email")) {
			options.email = map.getString("email");
		}
		if (map.hasKey("phone")) {
			options.phone = map.getString("phone");
		}
		if (map.hasKey("language")) {
			options.language = map.getString("language");
		}
		if (map.hasKey("productName")) {
			options.productName = map.getString("productName");
		}
		return options;
	}
}