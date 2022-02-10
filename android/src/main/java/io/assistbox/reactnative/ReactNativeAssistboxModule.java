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
import com.nayah.assistbox.AssistBoxActivity;
import com.nayah.assistbox.LogService;

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
	public void goToAssistbox(String token, String mobileServiceEndpoint, String mobileStorageEndpoint, String splashScreenResourceName, Callback successCallback,
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
				if (mobileStorageEndpoint == null || mobileStorageEndpoint.isEmpty()) {
					errorCallback.invoke("Mobile Storage Endpoint is required");
					return;
				}

				this.reactContext.registerReceiver(redirectReceiver, new IntentFilter("AssistboxRedirection"));

				Intent intent = new Intent(reactContext, AssistBoxActivity.class);

				int resourceId = getResourceIdByName(splashScreenResourceName);

				intent.putExtra("accessToken", token);
				intent.putExtra("mobileServiceEndpoint", mobileServiceEndpoint);
				intent.putExtra("mobileStorageEndpoint", mobileStorageEndpoint);
				intent.putExtra("splashScreenResourceId", resourceId);
				reactContext.getCurrentActivity().startActivity(intent);
				successCallback.invoke("Opening Assistbox SDK");

			} catch(Exception e) {
				errorCallback.invoke(e.getMessage());
			}
		});
	}

	private int getResourceIdByName(String resourceName) {
		if (resourceName == null || resourceName.isEmpty()) {
			return 0;
		}
		return reactContext.getResources().getIdentifier(resourceName, "drawable", reactContext.getPackageName());
	}
}