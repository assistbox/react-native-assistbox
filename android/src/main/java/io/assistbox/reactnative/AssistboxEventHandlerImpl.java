package io.assistbox.reactnative;

import com.facebook.react.bridge.Arguments;
import com.facebook.react.bridge.WritableMap;

import io.assistbox.event.AssistboxEventHandler;

import io.assistbox.Assistbox;
import io.assistbox.annotation.OverridesDefaultBehavior;
import io.assistbox.enums.AppointmentStatus;
import io.assistbox.enums.MeetingEndReason;
import io.assistbox.event.AssistboxEventHandler;
import io.assistbox.event.ErrorEventCode;
import io.assistbox.util.log.LogService;

import android.app.Application;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.annotation.OptIn;
import androidx.lifecycle.Lifecycle;

import org.json.JSONObject;

public class AssistboxEventHandlerImpl implements AssistboxEventHandler {

	@Override
	public void onMeetingStart(Integer appointmentId, Integer participantId) {
		WritableMap params = Arguments.createMap();
		params.putInt("appointmentId", appointmentId);
		params.putInt("participantId", participantId);
		ReactNativeAssistboxModule.emitEventToReact("onMeetingStart", params);
	}

	@Override
	public void onMeetingEnd(Integer appointmentId, String endReason) {
		WritableMap params = Arguments.createMap();
		params.putInt("appointmentId", appointmentId);
		params.putString("endReason", endReason);
		ReactNativeAssistboxModule.emitEventToReact("onMeetingEnd", params);
	}

	@Override
	public void onJoinQueue(Integer queueId) {
		WritableMap params = Arguments.createMap();
		params.putInt("queueId", queueId);
		ReactNativeAssistboxModule.emitEventToReact("onJoinQueue", params);
	}

	@Override
	public void onLeaveQueue(Integer queueId) {
		WritableMap params = Arguments.createMap();
		params.putInt("queueId", queueId);
		ReactNativeAssistboxModule.emitEventToReact("onLeaveQueue", params);
	}

	@Override
	public void onSocketConnectionSuccess() {
		ReactNativeAssistboxModule.emitEventToReact("onSocketConnectionSuccess", null);
	}

	@Override
	public void onSocketConnectionFail(String error) {
		WritableMap params = Arguments.createMap();
		params.putString("error", error);
		ReactNativeAssistboxModule.emitEventToReact("onSocketConnectionFail", params);
	}

	@Override
	public void onCameraToggle(boolean isCameraOn) {
		WritableMap params = Arguments.createMap();
		params.putBoolean("isCameraOn", isCameraOn);
		ReactNativeAssistboxModule.emitEventToReact("onCameraToggle", params);
	}

	@Override
	public void onMicrophoneToggle(boolean isMicrophoneOn) {
		WritableMap params = Arguments.createMap();
		params.putBoolean("isMicrophoneOn", isMicrophoneOn);
		ReactNativeAssistboxModule.emitEventToReact("onMicrophoneToggle", params);
	}

	@Override
	public void onCameraSwitch(String mode) {
		WritableMap params = Arguments.createMap();
		params.putString("mode", mode);
		ReactNativeAssistboxModule.emitEventToReact("onCameraSwitch", params);
	}

	@Override
	public void onCameraSwitchError(String error) {
		WritableMap params = Arguments.createMap();
		params.putString("error", error);
		ReactNativeAssistboxModule.emitEventToReact("onCameraSwitchError", params);
	}

	@Override
	public void onChatToggle(boolean isChatOpen) {
		WritableMap params = Arguments.createMap();
		params.putBoolean("isChatOpen", isChatOpen);
		ReactNativeAssistboxModule.emitEventToReact("onChatToggle", params);
	}

	@Override
	public void onFlashToggle(boolean isFlashOpen) {
		WritableMap params = Arguments.createMap();
		params.putBoolean("isFlashOpen", isFlashOpen);
		ReactNativeAssistboxModule.emitEventToReact("onFlashToggle", params);
	}

	@Override
	public void onFlashToggleError(String error) {
		WritableMap params = Arguments.createMap();
		params.putString("error", error);
		ReactNativeAssistboxModule.emitEventToReact("onFlashToggleError", params);
	}

	@Override
	public void onPictureInPictureModeChanged(boolean isInPictureInPictureMode) {
		WritableMap params = Arguments.createMap();
		params.putBoolean("isInPictureInPictureMode", isInPictureInPictureMode);
		ReactNativeAssistboxModule.emitEventToReact("onPictureInPictureModeChanged", params);
	}

	@Override
	public void onHoldModeChanged(boolean isInHoldMode) {
		WritableMap params = Arguments.createMap();
		params.putBoolean("isInHoldMode", isInHoldMode);
		ReactNativeAssistboxModule.emitEventToReact("onHoldModeChanged", params);
	}

	@Override
	public void onClose() {
		ReactNativeAssistboxModule.emitEventToReact("onClose", null);
	}

	@Override
	public void onCaptureFrame(long binaryFileId) {
		WritableMap params = Arguments.createMap();
		params.putDouble("binaryFileId", binaryFileId);
		ReactNativeAssistboxModule.emitEventToReact("onCaptureFrame", params);
	}

	@Override
	public void onRecordingError(String type) {
		WritableMap params = Arguments.createMap();
		params.putString("type", type);
		ReactNativeAssistboxModule.emitEventToReact("onRecordingError", params);
	}

	@Override
	public void onMessageTemplateReceived(JSONObject messageTemplate) {
		WritableMap params = Arguments.createMap();
		params.putString("messageTemplate", messageTemplate != null ? messageTemplate.toString() : null);
		ReactNativeAssistboxModule.emitEventToReact("onMessageTemplateReceived", params);
	}

	@Override
	public void onHoldModeToggle(boolean isInHoldMode) {
		WritableMap params = Arguments.createMap();
		params.putBoolean("isInHoldMode", isInHoldMode);
		ReactNativeAssistboxModule.emitEventToReact("onHoldModeToggle", params);
	}

	@Override
	public void onBackPressed() {
		ReactNativeAssistboxModule.emitEventToReact("onBackPressed", null);
	}

	@Override
	public void onError(@NonNull ErrorEventCode errorEventCode, @Nullable String message, @Nullable JSONObject payload) {
		WritableMap params = Arguments.createMap();
		params.putString("errorCode", errorEventCode != null ? errorEventCode.name() : null);
		params.putString("message", message);
		params.putString("payload", payload != null ? payload.toString() : null);
		ReactNativeAssistboxModule.emitEventToReact("onError", params);
	}

	@Override
	public void onEventHandlerError(JSONObject payload) {
		WritableMap params = Arguments.createMap();
		params.putString("payload", payload != null ? payload.toString() : null);
		ReactNativeAssistboxModule.emitEventToReact("onEventHandlerError", params);
	}

	@Override
	public void onActivityLifecycleEvent(Lifecycle.Event lifecycleEvent) {
		WritableMap params = Arguments.createMap();
		params.putString("lifecycleEvent", lifecycleEvent != null ? lifecycleEvent.name() : null);
		ReactNativeAssistboxModule.emitEventToReact("onActivityLifecycleEvent", params);
	}

	@Override
	public void onAppointmentStatusChanged(AppointmentStatus status, String reason) {
		WritableMap params = Arguments.createMap();
		params.putString("status", status != null ? status.getName() : null);
		params.putString("reason", reason);
		ReactNativeAssistboxModule.emitEventToReact("onAppointmentStatusChanged", params);
	}

	@Override
	public void onCameraDisconnected() {
		ReactNativeAssistboxModule.emitEventToReact("onCameraDisconnected", null);
	}


	@Override
	public void onOpenMicrophoneButtonClick() {
		ReactNativeAssistboxModule.emitOpenMicrophoneButtonClick();
	}

	@Override
	public void onCloseMicrophoneButtonClick() {
		ReactNativeAssistboxModule.emitCloseMicrophoneButtonClick();
	}

	@Override
	public void onOpenCameraButtonClick() {
		ReactNativeAssistboxModule.emitOpenCameraButtonClick();
	}

	@Override
	public void onCloseCameraButtonClick() {
		ReactNativeAssistboxModule.emitCloseCameraButtonClick();
	}

	@Override
	public void onOpenFlashButtonClick() {
		ReactNativeAssistboxModule.emitOpenFlashButtonClick();
	}

	@Override
	public void onCloseFlashButtonClick() {
		ReactNativeAssistboxModule.emitCloseFlashButtonClick();
	}

	@Override
	public void onSwitchCameraButtonClick() {
		ReactNativeAssistboxModule.emitSwitchCameraButtonClick();
	}

	@Override
	public void onStopMeetingButtonClick() {
		ReactNativeAssistboxModule.emitStopMeetingButtonClick();
	}

	@Override
	public void onEnterPictureInPictureButtonClick() {
		ReactNativeAssistboxModule.emitEnterPictureInPictureButtonClick();
	}
}