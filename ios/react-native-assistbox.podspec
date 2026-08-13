require 'json'

package = JSON.parse(File.read(File.join(__dir__, '../package.json')))

Pod::Spec.new do |s|
  s.name         = package['name']
  s.version      = package['version']
  s.summary      = package['description']
  s.license      = package['license']

  s.authors      = package['author']
  s.homepage     = package['homepage']
  # iOS 13 minimum: required for Swift concurrency (MainActor.assumeIsolated) and Scanner.currentIndex
  s.platform     = :ios, "13.0"
  s.swift_version = "5.0"

  # NOTE: The consumer app's Podfile must provide the AssistboxLib/WebRTC xcframework paths
  # via SDK-conditional FRAMEWORK_SEARCH_PATHS (a recursive glob may pick the wrong slice).
  # NOTE: Xcode rejects SWIFT_OBJC_BRIDGING_HEADER on pod framework targets ("using bridging
  # headers with framework targets is unsupported"); React headers are imported in Swift via
  # `import React`. The bridging header file exists only for the standalone Xcode project.
  s.pod_target_xcconfig = {
    'SWIFT_VERSION' => '5.0'
  }

  s.source       = { :git => "https://github.com/assistbox/react-native-assistbox.git", :tag => "v#{s.version}" }
  s.source_files  = "**/*.{h,m,swift}"

  s.dependency 'React-Core'
end
