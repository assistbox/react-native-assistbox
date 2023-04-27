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
				opts,
				successCallback,
				errorCallback
			);
		} else if (Platform.OS.toLowerCase() === "android") {
			ReactNativeAssistbox.initVideoCallWithToken(
				opts,
				successCallback,
				errorCallback
			);
		}
	},

	initVideoCallWithAccessKey(opts, successCallback, errorCallback) {
		registerOnAssistboxRedirectListener();
		if (Platform.OS.toLowerCase() === 'ios') {
			ReactNativeAssistbox.initVideoCallWithAccessKey(
				opts,
				successCallback,
				errorCallback
			);
		} else if (Platform.OS.toLowerCase() === "android") {
			ReactNativeAssistbox.initVideoCallWithAccessKey(
				opts,
				successCallback,
				errorCallback
			);
		}
	},

	initC2CModuleAsAgent(opts, successCallback, errorCallback) {
		registerOnAssistboxRedirectListener();
		if (Platform.OS.toLowerCase() === 'ios') {
			ReactNativeAssistbox.initC2CModuleAsAgent(
				opts,
				successCallback,
				errorCallback
			);
		} else if (Platform.OS.toLowerCase() === "android") {
			ReactNativeAssistbox.initC2CModuleAsAgent(
				opts,
				successCallback,
				errorCallback
			);
		}
	},

	initC2CModuleAsClientWithApiKey(opts, successCallback, errorCallback) {
		registerOnAssistboxRedirectListener();
		if (Platform.OS.toLowerCase() === 'ios') {
			ReactNativeAssistbox.initC2CModuleAsClientWithApiKey(
				opts,
				successCallback,
				errorCallback
			);
		} else if (Platform.OS.toLowerCase() === "android") {
			ReactNativeAssistbox.initC2CModuleAsClientWithApiKey(
				opts,
				successCallback,
				errorCallback
			);
		}
	},

	initC2CModuleAsClientWithToken(opts, successCallback, errorCallback) {
		registerOnAssistboxRedirectListener();
		if (Platform.OS.toLowerCase() === 'ios') {
			ReactNativeAssistbox.initC2CModuleAsClientWithToken(
				opts,
				successCallback,
				errorCallback
			);
		} else if (Platform.OS.toLowerCase() === "android") {
			ReactNativeAssistbox.initC2CModuleAsClientWithToken(
				opts,
				successCallback,
				errorCallback
			);
		}
	}
};
