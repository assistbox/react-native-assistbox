# react-native-assistbox

React Native bridge for the [Assistbox](https://assistbox.io) video calling and Click-to-Call (C2C) SDKs on iOS and Android. It lets a React Native app start video calls, listen to SDK events, and trigger in-call actions.

## Requirements

- **iOS:** 13.0+, CocoaPods. The `AssistboxLib` and `WebRTC` xcframeworks (provided by Assistbox) must be added by the consuming app.
- **Android:** minSdk 24, compileSdk 34. The Assistbox SDK 21.x AARs (`assistbox-*.aar`, `libwebrtc-*.aar`) must be provided by the consuming app.

## Installation

Add the package from a git tag:

```json
"dependencies": {
	"react-native-assistbox": "github:assistbox/react-native-assistbox#v22.0.0"
}
```

### iOS

1. The podspec lives under `ios/` (not the package root), so add an explicit pod entry to your app's Podfile:

   ```ruby
   pod 'react-native-assistbox', :path => '../node_modules/react-native-assistbox/ios'
   ```

2. Add the `AssistboxLib` and `WebRTC` xcframeworks to your app and make them visible to the pod target (e.g. via `FRAMEWORK_SEARCH_PATHS` in your Podfile). The bridge imports `AssistboxLib` directly.

3. Install pods:

   ```sh
   cd ios && pod install
   ```

### Android

The bridge compiles against the Assistbox SDK with `compileOnly`; your app provides the AARs at build time in one of two ways:

- Copy `assistbox-*.aar` and `libwebrtc-*.aar` into the `libs/` folder at your project root, **or**
- Define `libs.assistbox.lib` and `libs.assistbox.webrtc` in your Gradle version catalog.

The native module and its event handler are registered automatically (React Native autolinking + manifest meta-data); no additional setup is required.

## Usage

```js
import Assistbox from 'react-native-assistbox';

// Listen to SDK events
Assistbox.registerEventListener('onMeetingStart', (e) => {
	console.log('Meeting started', e.appointmentId, e.participantId);
});

// Start a video call
Assistbox.initVideoCallWithAccessKey(
	{
		accessKey: '<ACCESS_KEY>',
		mobileServiceEndpoint: 'https://<mobile-service-endpoint>',
	},
	(msg) => console.log(msg),
	(err) => console.error(err),
);

// Trigger an in-call action
Assistbox.dispatchAction('closeMicrophone');
```

> **Note (iOS):** the native init methods (`initNativeVideoCallWithToken`, `initNativeVideoCallWithAccessKey`, `initNativeC2CModule*`) require the app's root view controller to be — or be embedded in — a `UINavigationController`; otherwise the error callback is invoked. The legacy `init*` methods do not have this requirement.

## API reference

Full documentation lives in [docs/](docs/README.md):

- [All init options (`AssistboxOptions`)](docs/options.md)
- [Events and payloads](docs/events.md)
- [In-call actions (`dispatchAction`)](docs/api/dispatchAction.md)
- [Native module architecture](docs/native-modules.md)

## License

MIT
