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

	goToAssistbox(token, mobileServiceEndpoint, mobileStorageEndpoint, splashScreenResourceName, successCallback, errorCallback) {

		registerOnAssistboxRedirectListener();

		ReactNativeAssistbox.goToAssistbox(
			token,
			mobileServiceEndpoint,
			mobileStorageEndpoint,
			splashScreenResourceName == null || splashScreenResourceName.length === 0 ? undefined : splashScreenResourceName,
			successCallback,
			errorCallback
		);
	},
};
