package io.assistbox.reactnative;

// Android imports
import android.app.Application;
import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.graphics.Color;

// AndroidX
import androidx.annotation.NonNull;
import androidx.fragment.app.DialogFragment;

// React Native imports
import com.facebook.react.bridge.Arguments;
import com.facebook.react.bridge.Callback;
import com.facebook.react.bridge.Promise;
import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReactContextBaseJavaModule;
import com.facebook.react.bridge.ReactMethod;
import com.facebook.react.bridge.ReadableArray;
import com.facebook.react.bridge.ReadableMap;
import com.facebook.react.bridge.ReadableMapKeySetIterator;
import com.facebook.react.bridge.UiThreadUtil;
import com.facebook.react.bridge.WritableMap;
import com.facebook.react.modules.core.DeviceEventManagerModule;

// Java utilities
import java.util.HashMap;
import java.util.HashSet;
import java.util.Map;
import java.util.Set;

// Assistbox core
import io.assistbox.Assistbox;
import io.assistbox.action.AssistboxActions;
import io.assistbox.data.net.entity.CustomFont;
import io.assistbox.enums.AppointmentStatus;
import io.assistbox.enums.Component;
import io.assistbox.enums.FontExtension;
import io.assistbox.enums.FontWeight;
import io.assistbox.enums.Language;
import io.assistbox.enums.LocalViewPosition;
import io.assistbox.enums.MeetingButtonType;
import io.assistbox.enums.SupportedMessagingServices;
import io.assistbox.enums.UsageModule;
import io.assistbox.event.AssistboxEventHandler;
import io.assistbox.util.log.LogService;

public class ReactNativeAssistboxModule extends ReactContextBaseJavaModule {
	private static final String TAG = "ReactNativeAssistboxModule";

	private final ReactApplicationContext reactContext;
	public static ReactApplicationContext reactContextInstance;

	public ReactNativeAssistboxModule(ReactApplicationContext reactContext) {
		super(reactContext);
		this.reactContext = reactContext;
		reactContextInstance = reactContext;
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
				Assistbox.initC2CModuleAsClientWithToken(reactContext.getCurrentActivity(), assistboxOptions);
				successCallback.invoke("Opening Assistbox SDK");
			} catch(Exception e) {
				errorCallback.invoke(e.getMessage());
			}
		});
	}

	@ReactMethod
	public void closeExternally() {
		UiThreadUtil.runOnUiThread(() -> {
			if (reactContext.getCurrentActivity() != null) {
				Assistbox.closeExternally(reactContext.getCurrentActivity());
			} else {
				LogService.error(TAG, "Could not get current react activity to close Assistbox");
			}
		});
	}

	@ReactMethod
	public void resumeSdk() {
		if (reactContext.getCurrentActivity() != null) {
			UiThreadUtil.runOnUiThread(() -> {
				Assistbox.resumeSdk(reactContext.getCurrentActivity());
			});
		} else {
			LogService.error(TAG, "Could not get current react activity to resume Assistbox");
		}
	}

	private int getDrawableResourceIdByName(String resourceName) {
		if (resourceName == null || resourceName.isEmpty()) {
			return 0;
		}
		return reactContext.getResources().getIdentifier(resourceName, "drawable", reactContext.getPackageName());
	}

	private int getFontResourceIdByName(String name) {
		Context context = getReactApplicationContext();
		return context.getResources().getIdentifier(name, "font", context.getPackageName());
	}

	private int getMipmapResourceIdByName(String resourceName) {
		if (resourceName == null || resourceName.isEmpty()) {
			return 0;
		}
		return reactContext.getResources().getIdentifier(resourceName, "mipmap", reactContext.getPackageName());
	}

	private Assistbox.AssistboxOptions createAssistboxOptionsFromReadableMap(ReadableMap map) {
		Assistbox.AssistboxOptions options = new Assistbox.AssistboxOptions();
		if (map.hasKey("accessToken")) {
			options.accessToken = map.getString("accessToken");
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
		if (map.hasKey("preferredLanguage")) {
			options.preferredLanguage = Language.getByCode(map.getString("preferredLanguage"));
		}
		if (map.hasKey("productName")) {
			options.productName = map.getString("productName");
		}
		if (map.hasKey("isNotificationBased")) {
			options.isNotificationBased = map.getBoolean("isNotificationBased");
		}
		if (map.hasKey("splashScreenResourceName")) {
			String splashScreenResourceName = map.getString("splashScreenResourceName");
			options.splashScreenResourceId = getDrawableResourceIdByName(splashScreenResourceName);
		}
		if (map.hasKey("waitingScreenResourceName")) {
			String waitingScreenResourceName = map.getString("waitingScreenResourceName");
			options.waitingScreenResourceId = getDrawableResourceIdByName(waitingScreenResourceName);
		}
		if (map.hasKey("notificationIconResourceName")) {
			String notificationIconResourceName = map.getString("notificationIconResourceName");
			options.notificationIconResourceId = getMipmapResourceIdByName(notificationIconResourceName);
		}
		if (map.hasKey("pushToken")) {
			options.pushToken = map.getString("pushToken");
		}
		if (map.hasKey("supportedMessagingService")) {
			options.supportedMessagingService = (SupportedMessagingServices.valueOf(map.getString(
					"supportedMessagingService")));
		}
		if (map.hasKey("redirectToMainApplication")) {
			options.redirectToMainApplication = map.getBoolean("redirectToMainApplication");
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
		if (map.hasKey("intentFlags")) {
			options.intentFlags = map.getInt("intentFlags");
		}
		if (map.hasKey("customParameter")) {
			options.customParameter = map.getString("customParameter");
		}
		if (map.hasKey("externalLogoResourceName")) {
			String externalLogoResourceName = map.getString("externalLogoResourceName");
			options.externalLogoResourceId = getDrawableResourceIdByName(externalLogoResourceName);
		}
		if (map.hasKey("extUrlParam")) {
			options.extUrlParam = map.getString("extUrlParam");
		}
		if (map.hasKey("isCameraEnabled")) {
			options.isCameraEnabled = map.getBoolean("isCameraEnabled");
		}
		if (map.hasKey("disableScreenCapture")) {
			options.disableScreenCapture = map.getBoolean("disableScreenCapture");
		}
		if (map.hasKey("isPipEnabled")) {
			options.isPipEnabled = map.getBoolean("isPipEnabled");
		}
		if (map.hasKey("sessionId")) {
			options.sessionId = map.getString("sessionId");
		}
		if (map.hasKey("hiddenComponentList")) {
			ReadableArray hiddenArray = map.getArray("hiddenComponentList");
			Set<Component> hiddenComponentSet = new HashSet<>();

			for (int i = 0; i < hiddenArray.size(); i++) {
				String compName = hiddenArray.getString(i);
				Component comp = Component.valueOf(compName);
				hiddenComponentSet.add(comp);
			}

			options.hiddenComponentList = hiddenComponentSet;
		}
		if (map.hasKey("correlationId")) {
			options.correlationId = map.getString("correlationId");
		}
		if (map.hasKey("enableConnectionService")) {
			options.enableConnectionService = map.getBoolean("enableConnectionService");
		}
		if (map.hasKey("maxBitrate")) {
			options.maxBitrate = map.getInt("maxBitrate");
		}
		if (map.hasKey("waitingPlaylistName")) {
			options.waitingPlaylistName = map.getString("waitingPlaylistName");
		}
		if (map.hasKey("holdPlaylistName")) {
			options.holdPlaylistName = map.getString("holdPlaylistName");
		}
		if (map.hasKey("appointmentStatusToPlayWaitingPlaylist")) {
			String statusName = map.getString("appointmentStatusToPlayWaitingPlaylist");
			AppointmentStatus foundStatus = AppointmentStatus.fromName(statusName);
			options.appointmentStatusToPlayWaitingPlaylist = foundStatus;
		}
		if (map.hasKey("meetingButtonIcons")) {
			ReadableMap icons = map.getMap("meetingButtonIcons");
			HashMap<MeetingButtonType, Integer> meetingButtons = new HashMap<>();

			ReadableMapKeySetIterator iterator = icons.keySetIterator();
			while (iterator.hasNextKey()) {
				String key = iterator.nextKey();
				String iconName = icons.getString(key);
				int resId = getDrawableResourceIdByName(iconName);

				MeetingButtonType type = MeetingButtonType.valueOf(key);
				meetingButtons.put(type, resId);
			}

			options.meetingButtonIcons = meetingButtons;
		}
		if (map.hasKey("customFonts")) {
			ReadableMap fontsMap = map.getMap("customFonts");
			HashMap<FontWeight, CustomFont> customFonts = new HashMap<>();
			ReadableMapKeySetIterator iterator = fontsMap.keySetIterator();

			while (iterator.hasNextKey()) {
				String weightStr = iterator.nextKey();
				ReadableMap fontInfo = fontsMap.getMap(weightStr);
				String fontResName = fontInfo.getString("fontRes");
				String extensionStr = fontInfo.getString("extension");

				int fontResId = getFontResourceIdByName(fontResName);
				FontWeight fontWeight = FontWeight.valueOf(weightStr);
				FontExtension fontExtension = FontExtension.valueOf(extensionStr);

				CustomFont customFont = new CustomFont(fontResId, fontExtension);
				customFonts.put(fontWeight, customFont);
			}

			options.customFonts = customFonts;
		}
		if (map.hasKey("disableInternalNavigationOnCompletion")) {
			options.disableInternalNavigationOnCompletion = map.getBoolean("disableInternalNavigationOnCompletion");
		}
		if (map.hasKey("progressBarDrawableName")) {
			String progressBarDrawableName = map.getString("progressBarDrawableName");
			options.progressBarDrawableId = getDrawableResourceIdByName(progressBarDrawableName);
		}
		if (map.hasKey("localViewPosition")) {
			String posName = map.getString("localViewPosition");
			options.localViewPosition = LocalViewPosition.fromName(posName);
		}
		if (map.hasKey("disableVideoViewInteraction")) {
			options.disableVideoViewInteraction = map.getBoolean("disableVideoViewInteraction");
		}
		if (map.hasKey("videoCallBackgroundColor")) {
			String colorString = map.getString("videoCallBackgroundColor");
			options.videoCallBackgroundColor = Color.parseColor(colorString);
		}
		return options;
	}

	@ReactMethod
	public void dispatchAssistboxAction(String action, ReadableMap params) {
		switch (action) {
			case "openMicrophone":
				AssistboxActions.openMicrophone();
				break;
			case "closeMicrophone":
				AssistboxActions.closeMicrophone();
				break;
			case "openCamera":
				AssistboxActions.openCamera();
				break;
			case "closeCamera":
				AssistboxActions.closeCamera();
				break;
			case "switchCamera":
				AssistboxActions.switchCamera();
				break;
			case "openFlash":
				AssistboxActions.openFlash();
				break;
			case "closeFlash":
				AssistboxActions.closeFlash();
				break;
			case "enterPictureInPicture":
				AssistboxActions.enterPictureInPicture();
				break;
			case "stopMeeting":
				AssistboxActions.stopMeeting();
				break;
			case "tryReconnection":
				boolean showReconnectionDialog = true;
				if (params.hasKey("showReconnectionDialog")) {
					showReconnectionDialog = params.getBoolean("showReconnectionDialog");
				}
				AssistboxActions.tryReconnection(showReconnectionDialog);
				break;
		}
	}

	@ReactMethod
	public void showCustomDialogFragment(String fragmentClassName) {
		if (getReactApplicationContext().getCurrentActivity() != null) {
			Application application = getReactApplicationContext().getCurrentActivity().getApplication();
			try {
				Class<?> clazz = Class.forName(fragmentClassName);
				DialogFragment fragment = (DialogFragment) clazz.getMethod("newInstance").invoke(null);
				Assistbox.showDialogFragment(application, fragment, "EXAMPLE_DIALOG_FRAGMENT");
			} catch(Exception e) {
				e.printStackTrace();
			}
		}
	}

	@ReactMethod
	public void hideCustomDialogFragment() {
		if (getReactApplicationContext().getCurrentActivity() != null) {
			Application application = getReactApplicationContext().getCurrentActivity().getApplication();
			Assistbox.hideDialogFragment(application);
		}
	}

	@ReactMethod
	public void isSdkOpen(Promise promise) {
		try {
			boolean result = Assistbox.isSdkOpen();
			promise.resolve(result);
		} catch(Exception e) {
			promise.reject("E_SDK_OPEN", e);
		}
	}

	private static final Map<String, Boolean> eventListenerRegistry = new HashMap<>();

	@ReactMethod
	public void setEventListenerStatus(String eventName, boolean isRegistered) {
		eventListenerRegistry.put(eventName, isRegistered);
	}

	public static void emitEventToReact(String eventName, WritableMap params) {
		if (reactContextInstance != null) {
			reactContextInstance
					.getJSModule(com.facebook.react.modules.core.DeviceEventManagerModule.RCTDeviceEventEmitter.class)
					.emit(eventName, params);
		}
	}

	public static void emitOpenMicrophoneButtonClick() {
		boolean isRegistered = eventListenerRegistry.get("onOpenMicrophoneButtonClick") == Boolean.TRUE;
		if (isRegistered && reactContextInstance != null && reactContextInstance.hasActiveCatalystInstance()) {
			reactContextInstance
					.getJSModule(com.facebook.react.modules.core.DeviceEventManagerModule.RCTDeviceEventEmitter.class)
					.emit("onOpenMicrophoneButtonClick", null);
		} else {
			AssistboxActions.openMicrophone();
		}
	}

	public static void emitCloseMicrophoneButtonClick() {
		boolean isRegistered = eventListenerRegistry.get("onCloseMicrophoneButtonClick") == Boolean.TRUE;
		if (isRegistered && reactContextInstance != null && reactContextInstance.hasActiveCatalystInstance()) {
			reactContextInstance
					.getJSModule(com.facebook.react.modules.core.DeviceEventManagerModule.RCTDeviceEventEmitter.class)
					.emit("onCloseMicrophoneButtonClick", null);
		} else {
			AssistboxActions.closeMicrophone();
		}
	}

	public static void emitOpenCameraButtonClick() {
		boolean isRegistered = eventListenerRegistry.get("onOpenCameraButtonClick") == Boolean.TRUE;
		if (isRegistered && reactContextInstance != null && reactContextInstance.hasActiveCatalystInstance()) {
			reactContextInstance
					.getJSModule(com.facebook.react.modules.core.DeviceEventManagerModule.RCTDeviceEventEmitter.class)
					.emit("onOpenCameraButtonClick", null);
		} else {
			AssistboxActions.openCamera();
		}
	}

	public static void emitCloseCameraButtonClick() {
		boolean isRegistered = eventListenerRegistry.get("onCloseCameraButtonClick") == Boolean.TRUE;
		if (isRegistered && reactContextInstance != null && reactContextInstance.hasActiveCatalystInstance()) {
			reactContextInstance
					.getJSModule(com.facebook.react.modules.core.DeviceEventManagerModule.RCTDeviceEventEmitter.class)
					.emit("onCloseCameraButtonClick", null);
		} else {
			AssistboxActions.closeCamera();
		}
	}

	public static void emitOpenFlashButtonClick() {
		boolean isRegistered = eventListenerRegistry.get("onOpenFlashButtonClick") == Boolean.TRUE;
		if (isRegistered && reactContextInstance != null && reactContextInstance.hasActiveCatalystInstance()) {
			reactContextInstance
					.getJSModule(com.facebook.react.modules.core.DeviceEventManagerModule.RCTDeviceEventEmitter.class)
					.emit("onOpenFlashButtonClick", null);
		} else {
			AssistboxActions.openFlash();
		}
	}

	public static void emitCloseFlashButtonClick() {
		boolean isRegistered = eventListenerRegistry.get("onCloseFlashButtonClick") == Boolean.TRUE;
		if (isRegistered && reactContextInstance != null && reactContextInstance.hasActiveCatalystInstance()) {
			reactContextInstance
					.getJSModule(com.facebook.react.modules.core.DeviceEventManagerModule.RCTDeviceEventEmitter.class)
					.emit("onCloseFlashButtonClick", null);
		} else {
			AssistboxActions.closeFlash();
		}
	}

	public static void emitSwitchCameraButtonClick() {
		boolean isRegistered = eventListenerRegistry.get("onSwitchCameraButtonClick") == Boolean.TRUE;
		if (isRegistered && reactContextInstance != null && reactContextInstance.hasActiveCatalystInstance()) {
			reactContextInstance
					.getJSModule(com.facebook.react.modules.core.DeviceEventManagerModule.RCTDeviceEventEmitter.class)
					.emit("onSwitchCameraButtonClick", null);
		} else {
			AssistboxActions.switchCamera();
		}
	}

	public static void emitStopMeetingButtonClick() {
		boolean isRegistered = eventListenerRegistry.get("onStopMeetingButtonClick") == Boolean.TRUE;
		if (isRegistered && reactContextInstance != null && reactContextInstance.hasActiveCatalystInstance()) {
			reactContextInstance
					.getJSModule(com.facebook.react.modules.core.DeviceEventManagerModule.RCTDeviceEventEmitter.class)
					.emit("onStopMeetingButtonClick", null);
		} else {
			AssistboxActions.stopMeeting();
		}
	}

	public static void emitEnterPictureInPictureButtonClick() {
		boolean isRegistered = eventListenerRegistry.get("onEnterPictureInPictureButtonClick") == Boolean.TRUE;
		if (isRegistered && reactContextInstance != null && reactContextInstance.hasActiveCatalystInstance()) {
			reactContextInstance
					.getJSModule(com.facebook.react.modules.core.DeviceEventManagerModule.RCTDeviceEventEmitter.class)
					.emit("onEnterPictureInPictureButtonClick", null);
		} else {
			AssistboxActions.enterPictureInPicture();
		}
	}

}