//
//  ReactNativeAssistbox.swift
//  react-native-assistbox
//
//  Selectors exposed to JS must match the RCT_EXTERN_METHOD declarations in
//  ReactNativeAssistbox.m exactly; a mismatch fails silently at runtime.
//

import UIKit
import React
import AssistboxLib

@objc(ReactNativeAssistbox)
class ReactNativeAssistbox: RCTEventEmitter {

	private var eventListenerRegistry: [String: Bool] = [:]

	// For some events the framework invokes the legacy and the current overload back to back
	// in the SAME call chain (ASTEventManager.dispatchOnMeetingEndEvent fires both;
	// SignallingManager fires both when attempt == 1). A per-chain flag prevents double JS emits;
	// it is cleared on the next runloop tick (in-chain calls are synchronous on the same thread).
	private var didEmitMeetingEndInChain = false
	private var didEmitReconnectAttemptInChain = false
	private var pendingLegacyReconnectEmit = false
	// Nav reference kept to restore after hideNativeSdk in PiP (hide pops the VC off the stack)
	private weak var nativeSdkHostNavController: UINavigationController?

	override init() {
		super.init()
		ASTEventManager.shared.delegate = self
	}

	// ASTEventManager holds its delegate strongly; release it on bridge teardown or the module leaks
	override func invalidate() {
		if ASTEventManager.shared.delegate === self {
			ASTEventManager.shared.delegate = nil
		}
		super.invalidate()
	}

	override static func requiresMainQueueSetup() -> Bool {
		return false
	}

	// MARK: - Methods exposed to JS

	@objc func setEventListenerStatus(_ eventName: String, isRegistered: Bool) {
		eventListenerRegistry[eventName] = isRegistered
	}

	@objc func showCustomViewController(_ vcClassName: String) {
		DispatchQueue.main.async {
			if let vcClass = NSClassFromString(vcClassName) as? UIViewController.Type {
				let vc = vcClass.init()
				Assistbox.shared.showCustomViewController(vc)
			}
		}
	}

	@objc func hideCustomViewController() {
		DispatchQueue.main.async {
			Assistbox.shared.hideCustomViewController()
		}
	}

	// The PiP hide/show policy belongs to the app, not the bridge; JS may call these two
	// methods from the onPictureInPictureModeChanged event.
	@objc func hideNativeSdk() {
		Task { @MainActor in
			// Capture the nav reference before hiding; it is gone once hide pops the VC
			self.nativeSdkHostNavController = self.getViewController()?.navigationController
			Assistbox.shared.hideNativeSdk()
		}
	}

	@objc func showNativeSdk() {
		Task { @MainActor in
			guard let nav = self.nativeSdkHostNavController ?? self.getViewController()?.navigationController else {
				NSLog("[Assistbox] Could not find a navigation controller to show the native SDK")
				return
			}
			Assistbox.shared.showNativeSdk(in: nav)
			self.nativeSdkHostNavController = nil
		}
	}

	@objc func closeExternally() {
		DispatchQueue.main.async {
			if let vc = self.getViewController() {
				Assistbox.shared.closeExternally(viewController: vc) {
					NSLog("Assistbox closed externally.")
				}
			} else {
				NSLog("[Assistbox] ViewController is nil.")
			}
		}
	}

	// Closes the active native module (VideoCall or C2C); no-op for the legacy flows.
	@objc func closeNativeExternally() {
		Task { @MainActor in
			Assistbox.shared.closeNativeExternally()
		}
	}

	// MARK: - Legacy init methods

	@available(*, deprecated, message: "Use initNativeVideoCallWithToken instead")
	@objc func initVideoCallWithToken(_ options: NSDictionary,
									  successCallback: @escaping RCTResponseSenderBlock,
									  errorCallback: @escaping RCTResponseSenderBlock) {
		let assistboxOpt = createAssistboxOptions(from: options)
		if (assistboxOpt.token ?? "").isEmpty {
			errorCallback(["Token is required"])
			return
		}
		if (assistboxOpt.mobileServiceEndpoint ?? "").isEmpty {
			errorCallback(["Mobile Service Endpoint is required"])
			return
		}
		DispatchQueue.main.async {
			guard let vc = self.getViewController() else {
				errorCallback(["Could not get current view controller"])
				return
			}
			Assistbox.shared.initVideoCallWithToken(viewController: vc, options: assistboxOpt)
			successCallback(["Opening Assistbox SDK"])
		}
	}

	@available(*, deprecated, message: "Use initNativeVideoCallWithAccessKey instead")
	@objc func initVideoCallWithAccessKey(_ options: NSDictionary,
										  successCallback: @escaping RCTResponseSenderBlock,
										  errorCallback: @escaping RCTResponseSenderBlock) {
		let assistboxOpt = createAssistboxOptions(from: options)
		if (assistboxOpt.accessKey ?? "").isEmpty {
			errorCallback(["Access Key is required"])
			return
		}
		if (assistboxOpt.mobileServiceEndpoint ?? "").isEmpty {
			errorCallback(["Mobile Service Endpoint is required"])
			return
		}
		DispatchQueue.main.async {
			guard let vc = self.getViewController() else {
				errorCallback(["Could not get current view controller"])
				return
			}
			Assistbox.shared.initVideoCallWithAccessKey(viewController: vc, options: assistboxOpt)
			successCallback(["Opening Assistbox SDK"])
		}
	}

	@available(*, deprecated, message: "Use initNativeC2CModuleAsAgent instead")
	@objc func initC2CModuleAsAgent(_ options: NSDictionary,
									successCallback: @escaping RCTResponseSenderBlock,
									errorCallback: @escaping RCTResponseSenderBlock) {
		let assistboxOpt = createAssistboxOptions(from: options)
		if (assistboxOpt.mobileServiceEndpoint ?? "").isEmpty {
			errorCallback(["Mobile Service Endpoint is required"])
			return
		}
		if (assistboxOpt.voipNotificationToken ?? "").isEmpty {
			errorCallback(["VoIP Notification Token is required"])
			return
		}
		DispatchQueue.main.async {
			guard let vc = self.getViewController() else {
				errorCallback(["Could not get current view controller"])
				return
			}
			Assistbox.shared.initC2CModuleAsAgent(viewController: vc, options: assistboxOpt)
			successCallback(["Opening Assistbox SDK"])
		}
	}

	@available(*, deprecated, message: "Use initNativeC2CModuleAsClientWithApiKey instead")
	@objc func initC2CModuleAsClientWithApiKey(_ options: NSDictionary,
											   successCallback: @escaping RCTResponseSenderBlock,
											   errorCallback: @escaping RCTResponseSenderBlock) {
		let assistboxOpt = createAssistboxOptions(from: options)
		if (assistboxOpt.mobileServiceEndpoint ?? "").isEmpty {
			errorCallback(["Mobile Service Endpoint is required"])
			return
		}
		if (assistboxOpt.apiKey ?? "").isEmpty {
			errorCallback(["Api Key is required"])
			return
		}
		if (assistboxOpt.queueCode ?? "").isEmpty {
			errorCallback(["Queue Code is required"])
			return
		}
		DispatchQueue.main.async {
			guard let vc = self.getViewController() else {
				errorCallback(["Could not get current view controller"])
				return
			}
			Assistbox.shared.initC2CModuleAsClientWithApiKey(viewController: vc, options: assistboxOpt)
			successCallback(["Opening Assistbox SDK"])
		}
	}

	@available(*, deprecated, message: "Use initNativeC2CModuleAsClientWithToken instead")
	@objc func initC2CModuleAsClientWithToken(_ options: NSDictionary,
											  successCallback: @escaping RCTResponseSenderBlock,
											  errorCallback: @escaping RCTResponseSenderBlock) {
		let assistboxOpt = createAssistboxOptions(from: options)
		if (assistboxOpt.mobileServiceEndpoint ?? "").isEmpty {
			errorCallback(["Mobile Service Endpoint is required"])
			return
		}
		if (assistboxOpt.token ?? "").isEmpty {
			errorCallback(["Token is required"])
			return
		}
		DispatchQueue.main.async {
			guard let vc = self.getViewController() else {
				errorCallback(["Could not get current view controller"])
				return
			}
			Assistbox.shared.initC2CModuleAsClientWithToken(viewController: vc, options: assistboxOpt)
			successCallback(["Opening Assistbox SDK"])
		}
	}

	// MARK: - Native init methods

	@objc func initNativeVideoCallWithToken(_ options: NSDictionary,
											successCallback: @escaping RCTResponseSenderBlock,
											errorCallback: @escaping RCTResponseSenderBlock) {
		let assistboxOpt = createAssistboxOptions(from: options)
		if (assistboxOpt.token ?? "").isEmpty {
			errorCallback(["Token is required"])
			return
		}
		if (assistboxOpt.mobileServiceEndpoint ?? "").isEmpty {
			errorCallback(["Mobile Service Endpoint is required"])
			return
		}
		runNativeInit(successCallback: successCallback, errorCallback: errorCallback) { vc in
			try Assistbox.shared.initNativeVideoCallWithToken(viewController: vc, options: assistboxOpt)
		}
	}

	@objc func initNativeVideoCallWithAccessKey(_ options: NSDictionary,
												successCallback: @escaping RCTResponseSenderBlock,
												errorCallback: @escaping RCTResponseSenderBlock) {
		let assistboxOpt = createAssistboxOptions(from: options)
		if (assistboxOpt.accessKey ?? "").isEmpty {
			errorCallback(["Access Key is required"])
			return
		}
		if (assistboxOpt.mobileServiceEndpoint ?? "").isEmpty {
			errorCallback(["Mobile Service Endpoint is required"])
			return
		}
		runNativeInit(successCallback: successCallback, errorCallback: errorCallback) { vc in
			try Assistbox.shared.initNativeVideoCallWithAccessKey(viewController: vc, options: assistboxOpt)
		}
	}

	@objc func initNativeC2CModuleAsAgent(_ options: NSDictionary,
										  successCallback: @escaping RCTResponseSenderBlock,
										  errorCallback: @escaping RCTResponseSenderBlock) {
		let assistboxOpt = createAssistboxOptions(from: options)
		if (assistboxOpt.mobileServiceEndpoint ?? "").isEmpty {
			errorCallback(["Mobile Service Endpoint is required"])
			return
		}
		if (assistboxOpt.voipNotificationToken ?? "").isEmpty {
			errorCallback(["VoIP Notification Token is required"])
			return
		}
		runNativeInit(successCallback: successCallback, errorCallback: errorCallback) { vc in
			try Assistbox.shared.initNativeC2CModuleAsAgent(viewController: vc, options: assistboxOpt)
		}
	}

	@objc func initNativeC2CModuleAsClientWithApiKey(_ options: NSDictionary,
													 successCallback: @escaping RCTResponseSenderBlock,
													 errorCallback: @escaping RCTResponseSenderBlock) {
		let assistboxOpt = createAssistboxOptions(from: options)
		if (assistboxOpt.mobileServiceEndpoint ?? "").isEmpty {
			errorCallback(["Mobile Service Endpoint is required"])
			return
		}
		if (assistboxOpt.apiKey ?? "").isEmpty {
			errorCallback(["Api Key is required"])
			return
		}
		if (assistboxOpt.queueCode ?? "").isEmpty {
			errorCallback(["Queue Code is required"])
			return
		}
		runNativeInit(successCallback: successCallback, errorCallback: errorCallback) { vc in
			try Assistbox.shared.initNativeC2CModuleAsClientWithApiKey(viewController: vc, options: assistboxOpt)
		}
	}

	@objc func initNativeC2CModuleAsClientWithToken(_ options: NSDictionary,
													successCallback: @escaping RCTResponseSenderBlock,
													errorCallback: @escaping RCTResponseSenderBlock) {
		let assistboxOpt = createAssistboxOptions(from: options)
		if (assistboxOpt.mobileServiceEndpoint ?? "").isEmpty {
			errorCallback(["Mobile Service Endpoint is required"])
			return
		}
		if (assistboxOpt.token ?? "").isEmpty {
			errorCallback(["Token is required"])
			return
		}
		runNativeInit(successCallback: successCallback, errorCallback: errorCallback) { vc in
			try Assistbox.shared.initNativeC2CModuleAsClientWithToken(viewController: vc, options: assistboxOpt)
		}
	}

	// Shared native init flow. The framework throws if the given view controller has no
	// navigationController; the error is forwarded to errorCallback — the bridge does NOT
	// attempt any reparenting/nav wrapping (embedding is the host app's responsibility).
	private func runNativeInit(successCallback: @escaping RCTResponseSenderBlock,
							   errorCallback: @escaping RCTResponseSenderBlock,
							   _ initCall: @escaping @MainActor (UIViewController) throws -> Void) {
		DispatchQueue.main.async {
			MainActor.assumeIsolated {
				guard let vc = self.getViewController() else {
					errorCallback(["Could not get current view controller"])
					return
				}
				do {
					try initCall(vc)
					successCallback(["Opening Assistbox SDK"])
				} catch {
					errorCallback([error.localizedDescription])
				}
			}
		}
	}

	@objc func dispatchAssistboxAction(_ action: String, params: NSDictionary) {
		DispatchQueue.main.async {
			switch action {
			case "openMicrophone":
				AssistboxActions.shared.openMicrophone()
			case "closeMicrophone":
				AssistboxActions.shared.closeMicrophone()
			case "openCamera":
				AssistboxActions.shared.openCamera()
			case "closeCamera":
				AssistboxActions.shared.closeCamera()
			case "switchCamera":
				AssistboxActions.shared.switchCamera()
			case "openFlash":
				AssistboxActions.shared.openFlash()
			case "closeFlash":
				AssistboxActions.shared.closeFlash()
			case "enterPictureInPicture":
				AssistboxActions.shared.enterPictureInPicture()
			case "stopMeeting":
				if let showEndMeetingDialog = params["showEndMeetingDialog"] as? Bool {
					AssistboxActions.shared.stopMeeting(showEndMeetingDialog)
				} else {
					AssistboxActions.shared.stopMeeting()
				}
			case "startScreenShare":
				AssistboxActions.shared.startScreenShare()
			case "stopScreenShare":
				AssistboxActions.shared.stopScreenShare()
			case "pauseScreenShare":
				AssistboxActions.shared.pauseScreenShare()
			case "resumeScreenShare":
				AssistboxActions.shared.resumeScreenShare()
			case "hideComponents":
				if let list = params["components"] as? [Any] {
					AssistboxActions.shared.hideComponents(components: Self.components(from: list))
				}
			case "showComponents":
				if let list = params["components"] as? [Any] {
					AssistboxActions.shared.showComponents(components: Self.components(from: list))
				}
			case "tryReconnection":
				var showReconnectionDialog = true
				if let value = params["showReconnectionDialog"] as? Bool {
					showReconnectionDialog = value
				}
				AssistboxActions.shared.tryReconnection(showReconnectionDialog)
			default:
				break
			}
		}
	}

	// MARK: - View controller helpers

	private func getViewController() -> UIViewController? {
		guard let topMostViewController = getTopMostViewController() else { return nil }
		if topMostViewController.navigationController != nil {
			return topMostViewController
		}
		// If the root is a UINavigationController, pass its visible child to the framework:
		// the nav controller's own .navigationController is nil, so the framework rejects it
		if let nav = topMostViewController as? UINavigationController,
		   let visible = nav.visibleViewController {
			return visible
		}
		// keyWindow is deprecated; the legacy lookup behavior is deliberately preserved
		let window = UIApplication.shared.keyWindow
		if let rootNav = window?.rootViewController as? UINavigationController,
		   let visible = rootNav.visibleViewController {
			return visible
		}
		return window?.rootViewController
	}

	private func getTopMostViewController() -> UIViewController? {
		var presentingViewController = UIApplication.shared.delegate?.window??.rootViewController
		while let presented = presentingViewController?.presentedViewController {
			presentingViewController = presented
		}
		return presentingViewController
	}

	// MARK: - Options mapping

	private static let componentByName: [String: Component] = [
		"BTN_MICROPHONE": .BTN_MICROPHONE,
		"BTN_CAMERA": .BTN_CAMERA,
		"BTN_CAMERA_SWITCH": .BTN_CAMERA_SWITCH,
		"BTN_CHAT": .BTN_CHAT,
		"BTN_CHAT_ATTACHMENT": .BTN_CHAT_ATTACHMENT,
		"BTN_FLASH": .BTN_FLASH,
		"BTN_PICTURE_IN_PICTURE": .BTN_PICTURE_IN_PICTURE,
		"BTN_HOLD": .BTN_HOLD,
		"BTN_SCREEN_SHARE": .BTN_SCREEN_SHARE,
		"BTN_QUEUE_FORWARD": .BTN_QUEUE_FORWARD,
		"BTN_CONTACT_FORM": .BTN_CONTACT_FORM,
		"BTN_END_MEETING": .BTN_END_MEETING,
		"BTN_CUSTOMER_INFO": .BTN_CUSTOMER_INFO,
		"BTN_EXTERNAL_LINK": .BTN_EXTERNAL_LINK,
		"LBL_QUEUE_ORDER": .LBL_QUEUE_ORDER,
		"LBL_WAITING_QUEUE": .LBL_WAITING_QUEUE,
		"VIEW_CONNECTION_QUALITY": .VIEW_CONNECTION_QUALITY,
		"VIEW_MEETING_TIME": .VIEW_MEETING_TIME,
	]

	private static let localViewPositionRawByName: [String: Int] = [
		"topLeft": 0,
		"topRight": 1,
		"bottomLeft": 2,
		"bottomRight": 3,
	]

	private static let fontWeightRawByName: [String: Int] = [
		"THIN": 100,
		"EXTRA_LIGHT": 200,
		"LIGHT": 300,
		"REGULAR": 400,
		"MEDIUM": 500,
		"SEMI_BOLD": 600,
		"BOLD": 700,
		"EXTRA_BOLD": 800,
		"BLACK": 900,
	]

	// JS sends "videoRoom" / "sip" (contract shared with Android)
	private static let webrtcPluginTypeByName: [String: WebRTCPluginType] = [
		"videoRoom": .videoRoom,
		"sip": .sip,
	]

	// Maps a JS string/NSNumber list to Components; shared by hiddenComponentList and the
	// hide/showComponents actions. Unknown names are skipped.
	private static func components(from list: [Any]) -> [Component] {
		var components: [Component] = []
		for item in list {
			if let name = item as? String, let component = componentByName[name] {
				components.append(component)
			} else if let number = item as? NSNumber, let component = Component(rawValue: number.intValue) {
				components.append(component)
			}
		}
		return components
	}

	// Absent keys leave the corresponding option untouched (framework defaults preserved)
	private func createAssistboxOptions(from dictionary: NSDictionary) -> AssistboxOptions {
		let options = AssistboxOptions()
		if let accessToken = dictionary["accessToken"] as? String {
			options.token = accessToken
		}
		if let accessKey = dictionary["accessKey"] as? String {
			options.accessKey = accessKey
		}
		if let mobileServiceEndpoint = dictionary["mobileServiceEndpoint"] as? String {
			options.mobileServiceEndpoint = mobileServiceEndpoint
		}
		if let isNotificationBased = dictionary["isNotificationBased"] as? Bool {
			options.isNotificationBased = isNotificationBased
		}
		if let redirectToMainApplication = dictionary["redirectToMainApplication"] as? Bool {
			options.redirectToMainApplication = redirectToMainApplication
		}
		if let imageName = dictionary["splashScreenResourceName"] as? String {
			options.splashScreenImage = UIImage(named: imageName)
		}
		if let imageName = dictionary["waitingScreenResourceName"] as? String {
			options.waitingScreenImage = UIImage(named: imageName)
		}
		if let imageName = dictionary["callKitIconResourceName"] as? String {
			// Single-key read: the documented callKitIconResourceName key is both checked and read
			options.callKitIconImage = UIImage(named: imageName)
		}
		if let voipNotificationToken = dictionary["voipNotificationToken"] as? String {
			options.voipNotificationToken = voipNotificationToken
		}
		if let apiKey = dictionary["apiKey"] as? String {
			options.apiKey = apiKey
		}
		if let queueCode = dictionary["queueCode"] as? String {
			options.queueCode = queueCode
		}
		if let productName = dictionary["productName"] as? String {
			options.productName = productName
		}
		if let langCode = dictionary["preferredLanguage"] as? String {
			options.preferredLanguage = ASTLanguageHelper.fromCode(langCode)
		}
		if let firstName = dictionary["firstName"] as? String {
			options.firstName = firstName
		}
		if let lastName = dictionary["lastName"] as? String {
			options.lastName = lastName
		}
		if let email = dictionary["email"] as? String {
			options.email = email
		}
		if let phone = dictionary["phone"] as? String {
			options.phone = phone
		}
		if let regularNotificationToken = dictionary["regularNotificationToken"] as? String {
			options.regularNotificationToken = regularNotificationToken
		}
		if let customParameter = dictionary["customParameter"] as? String {
			options.customParameter = customParameter
		}
		if let imageName = dictionary["externalLogoResourceName"] as? String {
			// Single-key read: the documented externalLogoResourceName key (shared with Android) is both checked and read
			options.externalLogoImage = UIImage(named: imageName)
		}
		if let extUrlParam = dictionary["extUrlParam"] as? String {
			options.extUrlParam = extUrlParam
		}
		if let isCameraEnabled = dictionary["isCameraEnabled"] as? Bool {
			options.isCameraEnabled = isCameraEnabled
		}
		if let endMeetingOnScreenRecord = dictionary["endMeetingOnScreenRecord"] as? Bool {
			options.endMeetingOnScreenRecord = endMeetingOnScreenRecord
		}
		if let pipStrings = dictionary["pictureInPictureOptions"] as? [String] {
			var pipOptions: [AssistboxOptions.PipOptions] = []
			for optionString in pipStrings {
				switch optionString {
				case "enabled":
					pipOptions.append(.enabled)
				case "inAppViewForiOS14AndBefore":
					pipOptions.append(.inAppViewForiOS14AndBefore)
				case "hasMultitaskingCapability":
					pipOptions.append(.hasMultitaskingCapability)
				default:
					break
				}
			}
			options.pictureInPictureOptions = pipOptions
		}
		if let hiddenList = dictionary["hiddenComponentList"] as? [Any] {
			options.hiddenComponentList = Self.components(from: hiddenList)
		}
		if let enableCallKit = dictionary["enableCallKit"] as? Bool {
			options.enableCallKit = enableCallKit
		}
		if let correlationId = dictionary["correlationId"] as? String {
			options.correlationId = correlationId
		}
		if let maxBitrate = dictionary["maxBitrate"] as? NSNumber {
			options.maxBitrate = maxBitrate
		}
		if let waitingPlaylistName = dictionary["waitingPlaylistName"] as? String {
			options.waitingPlaylistName = waitingPlaylistName
		}
		if let holdPlaylistName = dictionary["holdPlaylistName"] as? String {
			options.holdPlaylistName = holdPlaylistName
		}
		if let statusString = dictionary["appointmentStatusToPlayWaitingPlaylist"] as? String {
			switch statusString {
			case "NEW": options.appointmentStatusToPlayWaitingPlaylist = .NEW
			case "REJ": options.appointmentStatusToPlayWaitingPlaylist = .REJ
			case "INP": options.appointmentStatusToPlayWaitingPlaylist = .INP
			case "WAI": options.appointmentStatusToPlayWaitingPlaylist = .WAI
			case "COM": options.appointmentStatusToPlayWaitingPlaylist = .COM
			case "QUE": options.appointmentStatusToPlayWaitingPlaylist = .QUE
			case "CANCELLED": options.appointmentStatusToPlayWaitingPlaylist = .CANCELLED
			default: break
			}
		}
		if let disableInternalNavigationOnCompletion = dictionary["disableInternalNavigationOnCompletion"] as? Bool {
			options.disableInternalNavigationOnCompletion = disableInternalNavigationOnCompletion
		}
		if let iconsDict = dictionary["meetingButtonIcons"] as? [String: String] {
			var icons: [MeetingButtonType: UIImage] = [:]
			for (key, imageName) in iconsDict {
				if let type = MeetingButtonType(rawValue: key), let image = UIImage(named: imageName) {
					icons[type] = image
				}
			}
			options.meetingButtonIcons = icons
		}
		if let positionString = dictionary["localViewPosition"] as? String {
			if let raw = Self.localViewPositionRawByName[positionString],
			   let position = LocalViewPosition(rawValue: raw) {
				options.localViewPosition = position
			}
		}
		if let disableVideoViewInteraction = dictionary["disableVideoViewInteraction"] as? Bool {
			options.disableVideoViewInteraction = disableVideoViewInteraction
		}
		if let hexString = dictionary["videoCallBackgroundColor"] as? String {
			options.videoCallBackgroundColor = colorFromHexString(hexString)
		}
		if let hexString = dictionary["progressBarColor"] as? String {
			options.progressBarColor = colorFromHexString(hexString)
		}
		if let fontsMap = dictionary["customFonts"] as? [String: [String: String]] {
			var customFonts: [FontWeight: CustomFont] = [:]
			for (weightStr, fontInfo) in fontsMap {
				guard let raw = Self.fontWeightRawByName[weightStr],
					  let fontWeight = FontWeight(rawValue: raw),
					  let fontResName = fontInfo["fontRes"],
					  let extensionStr = fontInfo["extension"] else { continue }
				customFonts[fontWeight] = CustomFont(fontName: fontResName, fontExtensionString: extensionStr)
			}
			options.customFonts = customFonts
		}
		if let enableLegacyButtonLayout = dictionary["enableLegacyButtonLayout"] as? Bool {
			options.enableLegacyButtonLayout = enableLegacyButtonLayout
		}
		if let messageTypeString = dictionary["messageType"] as? String,
		   let messageType = MessageType.fromString(messageTypeString) {
			options.messageType = messageType
		}
		if let pluginTypeString = dictionary["webrtcPluginType"] as? String,
		   let pluginType = Self.webrtcPluginTypeByName[pluginTypeString] {
			options.webrtcPluginType = pluginType
		}
		if let eventHandlerToken = dictionary["eventHandlerToken"] as? String {
			options.eventHandlerToken = eventHandlerToken
		}
		if let eventHandlerHeaders = dictionary["eventHandlerHeaders"] as? [String: String] {
			options.eventHandlerHeaders = eventHandlerHeaders
		}
		return options
	}

	private func colorFromHexString(_ hexString: String) -> UIColor {
		var rgbValue: UInt64 = 0
		let scanner = Scanner(string: hexString)
		if hexString.hasPrefix("#") {
			scanner.currentIndex = hexString.index(after: hexString.startIndex)
		}
		scanner.scanHexInt64(&rgbValue)
		return UIColor(red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
					   green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
					   blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
					   alpha: 1.0)
	}

	// MARK: - Event string mappings

	// Mapped via rawValue to avoid referencing deprecated enum cases (raw 5, 6)
	private func errorEventCodeString(_ errorCode: ErrorEventCode) -> String {
		switch errorCode.rawValue {
		case 0: return "CAMERA_TOGGLING_ERROR"
		case 1: return "MICROPHONE_TOGGLING_ERROR"
		case 2: return "HOLD_TOGGLING_ERROR"
		case 3: return "CAMERA_SWITCHING_ERROR"
		case 4: return "FILE_UPLOADING_ERROR"
		case 5: return "FLASHLIGHT_TOGGLING_ERROR"
		case 6: return "SIGNAL_CONNECTION_ERROR"
		case 7: return "VIDEO_RECORDING_ERROR"
		case 8: return "AUDIO_RECORDING_ERROR"
		case 9: return "PICTURE_IN_PICTURE_ENTER_ERROR"
		case 10: return "UNAUTHORIZED_ERROR"
		case 11: return "FORBIDDEN_ERROR"
		case 12: return "WEB_VIEW_VERSION_OLD_ERROR"
		case 13: return "PERMISSIONS_NOT_GRANTED_ERROR"
		case 14: return "ACCESS_KEY_NOT_FOUND_ERROR"
		case 15: return "API_KEY_NOT_FOUND_ERROR"
		case 16: return "POLICY_DENIED_ERROR"
		case 17: return "CONNECTION_ERROR"
		case 18: return "UNKNOWN_API_ERROR"
		case 19: return "CAMERA_ERROR"
		case 20: return "MICROPHONE_ERROR"
		case 21: return "TRANSLATE_FILE_FETCH_ERROR"
		case 22: return "SOCKET_REPLACED"
		case 23: return "CANCEL_SOCKET_REPLACEMENT"
		default: return "UNKNOWN"
		}
	}

	private func appointmentStatusString(_ status: AppointmentStatus) -> String {
		switch status {
		case .NEW: return "NEW"
		case .REJ: return "REJ"
		case .INP: return "INP"
		case .WAI: return "WAI"
		case .COM: return "COM"
		case .QUE: return "QUE"
		case .CANCELLED: return "CANCELLED"
		@unknown default: return "UNKNOWN"
		}
	}

	// SCREAMING_SNAKE strings, consistent with the bridge's other enum mappings
	private func flashlightErrorString(_ error: FlashlightError) -> String {
		switch error {
		case .cameraNotOpen: return "CAMERA_NOT_OPEN"
		case .cameraSwitchInProgress: return "CAMERA_SWITCH_IN_PROGRESS"
		case .flashlightNotSupported: return "FLASHLIGHT_NOT_SUPPORTED"
		case .flashlightAlreadyClosed: return "FLASHLIGHT_ALREADY_CLOSED"
		case .flashlightAlreadyOpen: return "FLASHLIGHT_ALREADY_OPEN"
		case .flashlightToggleInProgress: return "FLASHLIGHT_TOGGLE_IN_PROGRESS"
		case .flashlightOnError: return "FLASHLIGHT_ON_ERROR"
		case .flashlightOffError: return "FLASHLIGHT_OFF_ERROR"
		case .frontFlashNotAvailable: return "FRONT_FLASH_NOT_AVAILABLE"
		@unknown default: return "UNKNOWN"
		}
	}

	// MARK: - Event emitter

	// onTriggerRemoteAction is intentionally not exposed.
	override func supportedEvents() -> [String]! {
		return [
			"onMeetingStart",
			"onMeetingEnd",
			"onJoinQueue",
			"onLeaveQueue",
			"onSocketConnectionSuccess",
			"onSocketConnectionFail",
			"onCameraToggle",
			"onMicrophoneToggle",
			"onCameraSwitch",
			"onCameraSwitchError",
			"onChatToggle",
			"onFlashToggle",
			"onFlashToggleError",
			"onCaptureFrame",
			"onPictureInPictureModeChanged",
			"onHoldModeChanged",
			"onRecordingError",
			"onScreenRecordOrCapture",
			"onClose",
			"onHoldModeToggle",
			"onMessageTemplateReceived",
			"onError",
			"onEventHandlerError",
			"onCameraDisconnected",
			"onSocketReconnectionAttempt",
			"onSocketReconnectionSuccess",
			"onAppointmentStatusChanged",
			"onScreenShareEvent",
			"onSipCallEvent",
			"onOpenMicrophoneButtonClick",
			"onCloseMicrophoneButtonClick",
			"onOpenCameraButtonClick",
			"onCloseCameraButtonClick",
			"onOpenFlashButtonClick",
			"onCloseFlashButtonClick",
			"onSwitchCameraButtonClick",
			"onEnterPictureInPictureButtonClick",
			"onStopMeetingButtonClick",
			"onStartScreenShareButtonClick",
			"onStopScreenShareButtonClick",
		]
	}

	// Button-click events are forwarded to JS when a listener is registered; otherwise the native default behavior runs
	fileprivate func emitOrFallback(_ eventName: String, fallback: () -> Void) {
		let isRegistered = eventListenerRegistry[eventName] == true
		if isRegistered && bridge != nil {
			sendEvent(withName: eventName, body: nil)
		} else {
			fallback()
		}
	}
}

// MARK: - AssistboxEventDelegate (all protocol methods are @objc optional)
extension ReactNativeAssistbox: AssistboxEventDelegate {

	func onMeetingStart(appointmentId: Int, participantId: Int) {
		sendEvent(withName: "onMeetingStart", body: [
			"appointmentId": appointmentId,
			"participantId": participantId,
		])
	}

	// On the normal path the framework calls this overload first and then the legacy one;
	// the legacy overload fires ALONE only when the endReason string cannot be mapped to
	// MeetingEndReason.
	func onMeetingEnd(meetingId: Int, meetingEndReason: MeetingEndReason) {
		didEmitMeetingEndInChain = true
		DispatchQueue.main.async { self.didEmitMeetingEndInChain = false }
		sendEvent(withName: "onMeetingEnd", body: [
			"appointmentId": meetingId, // legacy field name kept for JS backward compatibility
			"meetingId": meetingId,
			"endReason": meetingEndReason.stringValue, // SCREAMING_SNAKE, mapped by the framework
			"meetingEndReason": meetingEndReason.stringValue,
		])
	}

	func onMeetingEnd(appointmentId: Int, endReason: String) {
		if didEmitMeetingEndInChain { return }
		sendEvent(withName: "onMeetingEnd", body: [
			"appointmentId": appointmentId,
			"endReason": endReason,
		])
	}

	func onJoinQueue(queueId: Int) {
		sendEvent(withName: "onJoinQueue", body: ["queueId": queueId])
	}

	func onLeaveQueue(queueId: Int) {
		sendEvent(withName: "onLeaveQueue", body: ["queueId": queueId])
	}

	func onSocketConnectionSuccess() {
		sendEvent(withName: "onSocketConnectionSuccess", body: nil)
	}

	func onSocketConnectionFail(error: String) {
		sendEvent(withName: "onSocketConnectionFail", body: ["error": error])
	}

	func onCameraToggle(isCameraOn: Bool) {
		sendEvent(withName: "onCameraToggle", body: ["isCameraOn": isCameraOn])
	}

	func onMicrophoneToggle(isMicrophoneOn: Bool) {
		sendEvent(withName: "onMicrophoneToggle", body: ["isMicrophoneOn": isMicrophoneOn])
	}

	func onCameraSwitch(mode: String) {
		sendEvent(withName: "onCameraSwitch", body: ["mode": mode])
	}

	func onCameraSwitchError(error: String) {
		sendEvent(withName: "onCameraSwitchError", body: ["error": error])
	}

	func onChatToggle(isChatOpen: Bool) {
		sendEvent(withName: "onChatToggle", body: ["isChatOpen": isChatOpen])
	}

	func onFlashToggle(isFlashOpen: Bool) {
		sendEvent(withName: "onFlashToggle", body: ["isFlashOpen": isFlashOpen])
	}

	func onFlashToggleError(error: FlashlightError) {
		sendEvent(withName: "onFlashToggleError", body: ["error": flashlightErrorString(error)])
	}

	// UInt64 matches the framework signature onCaptureFrame(binaryFileId: UInt64) exactly.
	// UInt64 fits in NSNumber, but JS numbers lose precision above 2^53.
	func onCaptureFrame(binaryFileId: UInt64) {
		sendEvent(withName: "onCaptureFrame", body: ["binaryFileId": binaryFileId])
	}

	func onPictureInPictureModeChanged(isInPictureInPictureMode: Bool) {
		sendEvent(withName: "onPictureInPictureModeChanged",
				  body: ["isInPictureInPictureMode": isInPictureInPictureMode])
	}

	func onHoldModeChanged(isOnHoldMode: Bool) {
		sendEvent(withName: "onHoldModeChanged", body: ["isOnHoldMode": isOnHoldMode])
	}

	func onRecordingError(type: String) {
		sendEvent(withName: "onRecordingError", body: ["type": type])
	}

	func onScreenRecordOrCapture() {
		sendEvent(withName: "onScreenRecordOrCapture", body: nil)
	}

	func onClose() {
		sendEvent(withName: "onClose", body: nil)
	}

	func onHoldModeToggle(isOnHoldMode: Bool) {
		sendEvent(withName: "onHoldModeToggle", body: ["isOnHoldMode": isOnHoldMode])
	}

	func onMessageTemplateReceived(messageTemplate: [String: Any]) {
		sendEvent(withName: "onMessageTemplateReceived", body: messageTemplate)
	}

	func onError(errorCode: ErrorEventCode, error: Error?, payload: [String: Any]?) {
		var body: [String: Any] = ["errorCode": errorEventCodeString(errorCode)]
		if let error = error {
			body["error"] = error.localizedDescription
		}
		if let payload = payload {
			for (key, value) in payload {
				body[key] = value
			}
		}
		sendEvent(withName: "onError", body: body)
	}

	func onEventHandlerError(payload: [String: Any]) {
		sendEvent(withName: "onEventHandlerError", body: payload)
	}

	func onCameraDisconnected() {
		sendEvent(withName: "onCameraDisconnected", body: nil)
	}

	// When attempt == 1 the framework may call both overloads in the same chain (order differs
	// by code path); attempt >= 2 calls only (attempt:), and content without attempt info calls
	// only the parameterless one. The parameterless emit is deferred one tick so the payload
	// carrying `attempt` wins in either order.
	func onSocketReconnectionAttempt() {
		if didEmitReconnectAttemptInChain { return }
		pendingLegacyReconnectEmit = true
		DispatchQueue.main.async {
			guard self.pendingLegacyReconnectEmit else { return }
			self.pendingLegacyReconnectEmit = false
			self.sendEvent(withName: "onSocketReconnectionAttempt", body: nil)
		}
	}

	func onSocketReconnectionAttempt(attempt: Int) {
		pendingLegacyReconnectEmit = false // cancel a pending parameterless emit from the same chain
		didEmitReconnectAttemptInChain = true
		DispatchQueue.main.async { self.didEmitReconnectAttemptInChain = false }
		// attempt is optional; the parameterless overload still sends body:nil
		sendEvent(withName: "onSocketReconnectionAttempt", body: ["attempt": attempt])
	}

	func onSocketReconnectionSuccess() {
		sendEvent(withName: "onSocketReconnectionSuccess", body: nil)
	}

	func onAppointmentStatusChanged(appointmentStatus: AppointmentStatus, reason: String) {
		sendEvent(withName: "onAppointmentStatusChanged", body: [
			"status": appointmentStatusString(appointmentStatus),
			"reason": reason,
		])
	}

	func onScreenShareEvent(screenShareEvent: ScreenShareEvent, message: String?) {
		var body: [String: Any] = ["event": screenShareEvent.stringValue]
		if let message = message {
			body["message"] = message
		}
		sendEvent(withName: "onScreenShareEvent", body: body)
	}

	func onSipCallEvent(event: SipCallEvent) {
		// description resolves from the enum case; no manual raw-value mapping
		sendEvent(withName: "onSipCallEvent", body: ["event": event.description])
	}

	func onOpenMicrophoneButtonClick() {
		emitOrFallback("onOpenMicrophoneButtonClick") { AssistboxActions.shared.openMicrophone() }
	}

	func onCloseMicrophoneButtonClick() {
		emitOrFallback("onCloseMicrophoneButtonClick") { AssistboxActions.shared.closeMicrophone() }
	}

	func onOpenCameraButtonClick() {
		emitOrFallback("onOpenCameraButtonClick") { AssistboxActions.shared.openCamera() }
	}

	func onCloseCameraButtonClick() {
		emitOrFallback("onCloseCameraButtonClick") { AssistboxActions.shared.closeCamera() }
	}

	func onOpenFlashButtonClick() {
		emitOrFallback("onOpenFlashButtonClick") { AssistboxActions.shared.openFlash() }
	}

	func onCloseFlashButtonClick() {
		emitOrFallback("onCloseFlashButtonClick") { AssistboxActions.shared.closeFlash() }
	}

	func onSwitchCameraButtonClick() {
		emitOrFallback("onSwitchCameraButtonClick") { AssistboxActions.shared.switchCamera() }
	}

	func onEnterPictureInPictureButtonClick() {
		emitOrFallback("onEnterPictureInPictureButtonClick") { AssistboxActions.shared.enterPictureInPicture() }
	}

	func onStopMeetingButtonClick() {
		emitOrFallback("onStopMeetingButtonClick") { AssistboxActions.shared.stopMeeting() }
	}

	func onStartScreenShareButtonClick() {
		emitOrFallback("onStartScreenShareButtonClick") { AssistboxActions.shared.startScreenShare() }
	}

	func onStopScreenShareButtonClick() {
		emitOrFallback("onStopScreenShareButtonClick") { AssistboxActions.shared.stopScreenShare() }
	}
}
