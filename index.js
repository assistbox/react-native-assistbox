import { DeviceEventEmitter, NativeEventEmitter, NativeModules, Platform } from 'react-native';

/**
 * AssistboxOptions keys accepted via the `opts` parameter of the init* methods
 * (subset — see docs/options.md for the full list):
 * @typedef {Object} AssistboxOptions
 * @property {boolean} [enableLegacyButtonLayout] iOS and Android. Default: false.
 * @property {('snackbar'|'toast'|'none')} [messageType] iOS and Android. Default: 'snackbar'. Case-insensitive.
 * @property {('videoRoom'|'sip')} [webrtcPluginType] iOS and Android. Default: 'videoRoom'.
 * @property {string} [eventHandlerToken] iOS and Android.
 * @property {Object<string,string>} [eventHandlerHeaders] iOS and Android.
 */

/**
 * Events (subscribed via registerEventListener, iOS and Android):
 * - "onScreenShareEvent": { event: string, message?: string } — values are normalized to
 *   SCREAMING_SNAKE in the bridge ('STARTED'...'CANCELLED'); CAPTURED_CONTENT_VISIBLE /
 *   CAPTURED_CONTENT_HIDDEN are emitted by Android only.
 * - "onSipCallEvent": { event: string } — values are normalized to SCREAMING_SNAKE in the
 *   bridge ('REGISTERED'...'NO_EXTENSION').
 * - "onSocketReconnectionAttempt": { attempt?: number }.
 * - "onSocketReconnectionSuccess": null.
 * - "onStartScreenShareButtonClick" / "onStopScreenShareButtonClick": null — when a listener
 *   is registered, the SDK default behavior (start/stopScreenShare) is suppressed.
 * PiP enter failures are reported via onError with code PICTURE_IN_PICTURE_ENTER_ERROR.
 */

const ReactNativeAssistbox = NativeModules.ReactNativeAssistbox;
const eventEmitters = {};
const listeners = {};

// iOS 'updatingcall' cannot be derived via toUpperCase; this table maps iOS descriptions to
// canonical names, values not in the table (Android already emits canonical SCREAMING_SNAKE)
// pass through unchanged
const SIP_CALL_EVENT_BY_IOS_NAME = {
	registered: 'REGISTERED',
	calling: 'CALLING',
	accepted: 'ACCEPTED',
	progress: 'PROGRESS',
	unavailable: 'UNAVAILABLE',
	busy: 'BUSY',
	declined: 'DECLINED',
	hangup: 'HANGUP',
	error: 'ERROR',
	updatingcall: 'UPDATING_CALL',
	registration_failed: 'REGISTRATION_FAILED',
	no_extension: 'NO_EXTENSION',
};

// Converts platform-specific native strings to canonical SCREAMING_SNAKE; other events pass through unchanged
function normalizeEvent(eventName, payload) {
	if (eventName !== 'onScreenShareEvent' && eventName !== 'onSipCallEvent') return payload;
	if (!payload || typeof payload.event !== 'string') return payload;
	if (eventName === 'onScreenShareEvent') {
		return { ...payload, event: payload.event.toUpperCase() };
	}
	return { ...payload, event: SIP_CALL_EVENT_BY_IOS_NAME[payload.event] || payload.event };
}

function registerEventListener(eventName, listener) {
	listeners[eventName] = listener;
	setEventListenerStatus(eventName, !!listener);

	if (Platform.OS === 'ios') {
		if (!eventEmitters[eventName]) {
			eventEmitters[eventName] = new NativeEventEmitter(ReactNativeAssistbox);
		}
		eventEmitters[eventName].removeAllListeners(eventName);
		eventEmitters[eventName].addListener(eventName, (event) => {
			if (listeners[eventName]) listeners[eventName](normalizeEvent(eventName, event));
		});
	} else if (Platform.OS === 'android') {
		DeviceEventEmitter.removeAllListeners(eventName);
		DeviceEventEmitter.addListener(eventName, (event) => {
			if (listeners[eventName]) listeners[eventName](normalizeEvent(eventName, event));
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
	/** @deprecated Use initNativeVideoCallWithToken instead. */
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

	/** @deprecated Use initNativeVideoCallWithAccessKey instead. */
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

	/** @deprecated Use initNativeC2CModuleAsAgent instead. */
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

	/** @deprecated Use initNativeC2CModuleAsClientWithApiKey instead. */
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

	/** @deprecated Use initNativeC2CModuleAsClientWithToken instead. */
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

	/** Native init (iOS and Android). On iOS the current screen must be inside a UINavigationController; otherwise errorCallback is invoked. */
	initNativeVideoCallWithToken(opts, successCallback, errorCallback) {
		if (!ReactNativeAssistbox || !ReactNativeAssistbox.initNativeVideoCallWithToken) {
			console.warn('ReactNativeAssistbox.initNativeVideoCallWithToken is not available.');
			if (errorCallback) errorCallback('ReactNativeAssistbox.initNativeVideoCallWithToken is not available.');
			return;
		}
		ReactNativeAssistbox.initNativeVideoCallWithToken(
			opts,
			successCallback,
			errorCallback
		);
	},

	/** Native init (iOS and Android). On iOS the current screen must be inside a UINavigationController; otherwise errorCallback is invoked. */
	initNativeVideoCallWithAccessKey(opts, successCallback, errorCallback) {
		if (!ReactNativeAssistbox || !ReactNativeAssistbox.initNativeVideoCallWithAccessKey) {
			console.warn('ReactNativeAssistbox.initNativeVideoCallWithAccessKey is not available.');
			if (errorCallback) errorCallback('ReactNativeAssistbox.initNativeVideoCallWithAccessKey is not available.');
			return;
		}
		ReactNativeAssistbox.initNativeVideoCallWithAccessKey(
			opts,
			successCallback,
			errorCallback
		);
	},

	/** Native init (iOS and Android). On iOS the current screen must be inside a UINavigationController; otherwise errorCallback is invoked. */
	initNativeC2CModuleAsAgent(opts, successCallback, errorCallback) {
		if (!ReactNativeAssistbox || !ReactNativeAssistbox.initNativeC2CModuleAsAgent) {
			console.warn('ReactNativeAssistbox.initNativeC2CModuleAsAgent is not available.');
			if (errorCallback) errorCallback('ReactNativeAssistbox.initNativeC2CModuleAsAgent is not available.');
			return;
		}
		ReactNativeAssistbox.initNativeC2CModuleAsAgent(
			opts,
			successCallback,
			errorCallback
		);
	},

	/** Native init (iOS and Android). On iOS the current screen must be inside a UINavigationController; otherwise errorCallback is invoked. */
	initNativeC2CModuleAsClientWithApiKey(opts, successCallback, errorCallback) {
		if (!ReactNativeAssistbox || !ReactNativeAssistbox.initNativeC2CModuleAsClientWithApiKey) {
			console.warn('ReactNativeAssistbox.initNativeC2CModuleAsClientWithApiKey is not available.');
			if (errorCallback) errorCallback('ReactNativeAssistbox.initNativeC2CModuleAsClientWithApiKey is not available.');
			return;
		}
		ReactNativeAssistbox.initNativeC2CModuleAsClientWithApiKey(
			opts,
			successCallback,
			errorCallback
		);
	},

	/** Native init (iOS and Android). On iOS the current screen must be inside a UINavigationController; otherwise errorCallback is invoked. */
	initNativeC2CModuleAsClientWithToken(opts, successCallback, errorCallback) {
		if (!ReactNativeAssistbox || !ReactNativeAssistbox.initNativeC2CModuleAsClientWithToken) {
			console.warn('ReactNativeAssistbox.initNativeC2CModuleAsClientWithToken is not available.');
			if (errorCallback) errorCallback('ReactNativeAssistbox.initNativeC2CModuleAsClientWithToken is not available.');
			return;
		}
		ReactNativeAssistbox.initNativeC2CModuleAsClientWithToken(
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

	/** iOS only — closes the active native module (VideoCall or C2C). Use closeExternally() for the legacy flows and on Android. */
	closeNativeExternally() {
		if (!ReactNativeAssistbox || !ReactNativeAssistbox.closeNativeExternally) {
			console.warn('ReactNativeAssistbox.closeNativeExternally is not available.');
			return;
		}
		ReactNativeAssistbox.closeNativeExternally();
	},

	/**
	 * iOS only — PiP support for the native module. The PiP hide/show policy belongs to the app:
	 * in the onPictureInPictureModeChanged event call hideNativeSdk() when isInPictureInPictureMode
	 * is true, and showNativeSdk() when it is false.
	 */
	hideNativeSdk() {
		if (!ReactNativeAssistbox || !ReactNativeAssistbox.hideNativeSdk) {
			console.warn('ReactNativeAssistbox.hideNativeSdk is not available.');
			return;
		}
		ReactNativeAssistbox.hideNativeSdk();
	},

	/** iOS only — restores the native SDK screen hidden by hideNativeSdk. */
	showNativeSdk() {
		if (!ReactNativeAssistbox || !ReactNativeAssistbox.showNativeSdk) {
			console.warn('ReactNativeAssistbox.showNativeSdk is not available.');
			return;
		}
		ReactNativeAssistbox.showNativeSdk();
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

	/**
	 * Actions (iOS and Android) include: startScreenShare, stopScreenShare, pauseScreenShare,
	 * resumeScreenShare, hideComponents/showComponents ({ components: string[] }) and
	 * stopMeeting ({ showEndMeetingDialog?: boolean }). See docs/api/dispatchAction.md.
	 */
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