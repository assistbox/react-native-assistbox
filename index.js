import { DeviceEventEmitter, NativeEventEmitter, NativeModules, Platform } from 'react-native';

const ReactNativeAssistbox = NativeModules.ReactNativeAssistbox;
const eventEmitters = {};
const listeners = {};

function registerEventListener(eventName, listener) {
	listeners[eventName] = listener;
	setEventListenerStatus(eventName, !!listener);

	if (Platform.OS === 'ios') {
		if (!eventEmitters[eventName]) {
			eventEmitters[eventName] = new NativeEventEmitter(ReactNativeAssistbox);
		}
		eventEmitters[eventName].removeAllListeners(eventName);
		eventEmitters[eventName].addListener(eventName, (event) => {
			if (listeners[eventName]) listeners[eventName](event);
		});
	} else if (Platform.OS === 'android') {
		DeviceEventEmitter.removeAllListeners(eventName);
		DeviceEventEmitter.addListener(eventName, (event) => {
			if (listeners[eventName]) listeners[eventName](event);
		});
	}
}

function unregisterEventListener(eventName) {
	listeners[eventName] = null;
	setEventListenerStatus(eventName, false);

	if (Platform.OS === 'ios' && eventEmitters[eventName]) {
		eventEmitters[eventName].removeAllListeners(eventName);
	} else if (Platform.OS === 'android') {
		DeviceEventEmitter.removeAllListeners(eventName);
	}
}

function setEventListenerStatus(eventName, isRegistered) {
	if (ReactNativeAssistbox && ReactNativeAssistbox.setEventListenerStatus) {
		ReactNativeAssistbox.setEventListenerStatus(eventName, isRegistered);
	}
}

export default {
	registerEventListener,
	unregisterEventListener,
	initVideoCallWithToken(opts, successCallback, errorCallback) {
		if (!ReactNativeAssistbox) {
			console.warn('ReactNativeAssistbox native module is not available.');
			if (errorCallback) errorCallback('ReactNativeAssistbox native module is not available.');
			return;
		}
		ReactNativeAssistbox.initVideoCallWithToken(
			opts,
			successCallback,
			errorCallback
		);
	},

	initVideoCallWithAccessKey(opts, successCallback, errorCallback) {
		if (!ReactNativeAssistbox) {
			console.warn('ReactNativeAssistbox native module is not available.');
			if (errorCallback) errorCallback('ReactNativeAssistbox native module is not available.');
			return;
		}
		ReactNativeAssistbox.initVideoCallWithAccessKey(
			opts,
			successCallback,
			errorCallback
		);
	},

	initC2CModuleAsAgent(opts, successCallback, errorCallback) {
		if (!ReactNativeAssistbox) {
			console.warn('ReactNativeAssistbox native module is not available.');
			if (errorCallback) errorCallback('ReactNativeAssistbox native module is not available.');
			return;
		}
		ReactNativeAssistbox.initC2CModuleAsAgent(
			opts,
			successCallback,
			errorCallback
		);
	},

	initC2CModuleAsClientWithApiKey(opts, successCallback, errorCallback) {
		if (!ReactNativeAssistbox) {
			console.warn('ReactNativeAssistbox native module is not available.');
			if (errorCallback) errorCallback('ReactNativeAssistbox native module is not available.');
			return;
		}
		ReactNativeAssistbox.initC2CModuleAsClientWithApiKey(
			opts,
			successCallback,
			errorCallback
		);
	},

	initC2CModuleAsClientWithToken(opts, successCallback, errorCallback) {
		if (!ReactNativeAssistbox) {
			console.warn('ReactNativeAssistbox native module is not available.');
			if (errorCallback) errorCallback('ReactNativeAssistbox native module is not available.');
			return;
		}
		ReactNativeAssistbox.initC2CModuleAsClientWithToken(
			opts,
			successCallback,
			errorCallback
		);
	},

	closeExternally() {
		if (!ReactNativeAssistbox) {
			console.warn('ReactNativeAssistbox native module is not available.');
			return;
		}
		ReactNativeAssistbox.closeExternally();
	},

	showCustomDialog(className) {
		if (!ReactNativeAssistbox) {
			console.warn('ReactNativeAssistbox native module is not available.');
			return;
		}
		if (Platform.OS === 'ios') {
			ReactNativeAssistbox.showCustomViewController(className);
		} else {
			ReactNativeAssistbox.showCustomDialogFragment(className);
		}
	},

	dispatchAction(action, params = {}) {
		if (!ReactNativeAssistbox) {
			console.warn('ReactNativeAssistbox native module is not available.');
			return;
		}
		ReactNativeAssistbox.dispatchAssistboxAction(action, params);
	},

	hideCustomDialog() {
		if (!ReactNativeAssistbox) {
			console.warn('ReactNativeAssistbox native module is not available.');
			return;
		}
		if (Platform.OS === 'ios') {
			ReactNativeAssistbox.hideCustomViewController();
		} else {
			ReactNativeAssistbox.hideCustomDialogFragment();
		}
	},

	isSdkOpen() {
		if (!ReactNativeAssistbox) {
			console.warn('ReactNativeAssistbox native module is not available.');
			return false;
		}
		return ReactNativeAssistbox.isSdkOpen();
	},

	resumeSdk() {
		if (!ReactNativeAssistbox) {
			console.warn('ReactNativeAssistbox native module is not available.');
			return;
		}
		ReactNativeAssistbox.resumeSdk();
	},
};