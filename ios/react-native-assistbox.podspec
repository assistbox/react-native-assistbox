require 'json'

package = JSON.parse(File.read(File.join(__dir__, '../package.json')))

Pod::Spec.new do |s|
  s.name         = package['name']
  s.version      = package['version']
  s.summary      = package['description']
  s.license      = package['license']

  s.authors      = package['author']
  s.homepage     = package['homepage']
  s.platform     = :ios, "12.0"

  s.xcconfig = { 'FRAMEWORK_SEARCH_PATHS' => '"${SRCROOT}/.."/**' }

  s.source       = { :git => "https://github.com/assistbox/react-native-assistbox.git", :tag => "v#{s.version}" }
  s.source_files  = "**/*.{h,m,swift}"

  s.dependency 'React-Core'
end
