import { DeviceEventEmitter, NativeEventEmitter, NativeModules, Platform } from 'react-native';

const ReactNativeAssistbox = Platform.select({
	ios: NativeModules.ReactNativeAssistbox,
	android: NativeModules.ReactNativeAssistbox,
});

let iosRedirectListener;

function sendRedirectEventToMainApplication() {
	console.debug("Emitting onAssistboxRedirect event");
	DeviceEventEmitter.emit("onAssistboxRedirect");
	if (iosRedirectListener) {
		iosRedirectListener.remove();
	}
}

function registerOnAssistboxRedirectListener() {
	if (Platform.OS.toLowerCase() === 'ios') {
		const eventEmitter = new NativeEventEmitter(ReactNativeAssistbox);
		eventEmitter.removeAllListeners("onAssistboxRedirectPrivate");
		iosRedirectListener = eventEmitter.addListener('onAssistboxRedirectPrivate', sendRedirectEventToMainApplication);
	} else if (Platform.OS.toLowerCase() === "android") {
		DeviceEventEmitter.removeAllListeners("onAssistboxRedirectPrivate");
		DeviceEventEmitter.addListener('onAssistboxRedirectPrivate', sendRedirectEventToMainApplication);
	}
}

export default {

	initVideoCallWithToken(opts, successCallback, errorCallback) {
		registerOnAssistboxRedirectListener();
		if (Platform.OS.toLowerCase() === 'ios') {
			ReactNativeAssistbox.initVideoCallWithToken(
				opts.token,
				opts.mobileServiceEndpoint,
				opts.splashScreenResourceName,
				opts.regularNotificationToken,
				successCallback,
				errorCallback
			);
		} else if (Platform.OS.toLowerCase() === "android") {
			ReactNativeAssistbox.initVideoCallWithToken(
				opts.token,
				opts.mobileServiceEndpoint,
				opts.splashScreenResourceName,
				opts.notificationIconResourceName,
				opts.regularNotificationToken,
				successCallback,
				errorCallback
			);
		}
	},

	initVideoCallWithAccessKey(opts, successCallback, errorCallback) {
		registerOnAssistboxRedirectListener();
		if (Platform.OS.toLowerCase() === 'ios') {
			ReactNativeAssistbox.initVideoCallWithAccessKey(
				opts.accessKey,
				opts.mobileServiceEndpoint,
				opts.splashScreenResourceName,
				opts.regularNotificationToken,
				successCallback,
				errorCallback
			);
		} else if (Platform.OS.toLowerCase() === "android") {
			ReactNativeAssistbox.initVideoCallWithAccessKey(
				opts.accessKey,
				opts.mobileServiceEndpoint,
				opts.splashScreenResourceName,
				opts.notificationIconResourceName,
				opts.regularNotificationToken,
				successCallback,
				errorCallback
			);
		}
	},

	initC2CModuleAsAgent(opts, successCallback, errorCallback) {
		registerOnAssistboxRedirectListener();
		if (Platform.OS.toLowerCase() === 'ios') {
			ReactNativeAssistbox.initC2CModuleAsAgent(
				opts.mobileServiceEndpoint,
				opts.voipNotificationToken,
				opts.splashScreenResourceName,
				opts.regularNotificationToken,
				successCallback,
				errorCallback
			);
		} else if (Platform.OS.toLowerCase() === "android") {
			ReactNativeAssistbox.initC2CModuleAsAgent(
				opts.mobileServiceEndpoint,
				opts.splashScreenResourceName,
				opts.notificationIconResourceName,
				opts.regularNotificationToken,
				opts.oneSignalPushId,
				successCallback,
				errorCallback
			);
		}
	},

	initC2CModuleAsClientWithApiKey(opts, successCallback, errorCallback) {
		registerOnAssistboxRedirectListener();
		if (Platform.OS.toLowerCase() === 'ios') {
			ReactNativeAssistbox.initC2CModuleAsClientWithApiKey(
				opts.apiKey,
				opts.queueCode,
				opts.mobileServiceEndpoint,
				opts.firstName,
				opts.lastName,
				opts.email,
				opts.phone,
				opts.productName,
				opts.language,
				opts.splashScreenResourceName,
				opts.regularNotificationToken,
				successCallback,
				errorCallback
			);
		} else if (Platform.OS.toLowerCase() === "android") {
			ReactNativeAssistbox.initC2CModuleAsClientWithApiKey(
				opts.apiKey,
				opts.queueCode,
				opts.mobileServiceEndpoint,
				opts.firstName,
				opts.lastName,
				opts.email,
				opts.phone,
				opts.productName,
				opts.language,
				opts.showContactForm,
				opts.splashScreenResourceName,
				opts.notificationIconResourceName,
				successCallback,
				errorCallback
			);
		}
	},

	initC2CModuleAsClientWithToken(opts, successCallback, errorCallback) {
		registerOnAssistboxRedirectListener();
		if (Platform.OS.toLowerCase() === 'ios') {
			ReactNativeAssistbox.initC2CModuleAsClientWithToken(
				opts.token,
				opts.mobileServiceEndpoint,
				opts.splashScreenResourceName,
				opts.regularNotificationToken,
				successCallback,
				errorCallback
			);
		} else if (Platform.OS.toLowerCase() === "android") {
			ReactNativeAssistbox.initC2CModuleAsClientWithToken(
				opts.token,
				opts.mobileServiceEndpoint,
				opts.splashScreenResourceName,
				opts.notificationIconResourceName,
				successCallback,
				errorCallback
			);
		}
	}
};
