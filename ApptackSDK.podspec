Pod::Spec.new do |s|
  s.name             = 'AppStackSDK'
  s.version          = '0.1.3'
  s.summary          = 'This pod is deprecated'
  s.description      = <<-DESC
                      This pod has been deprecated in favor of 'AppstackSDK'. Please update your dependencies.
                      DESC
  s.homepage         = 'https://www.app-stack.tech/'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'AppStack' => 'lucas@app-stack.tech' }
  s.source           = { :git => 'https://github.com/appstack-tech/ios-appstack-sdk.git', :tag => s.version.to_s }
  s.ios.deployment_target = '13.0'
  s.swift_version = '5.0'
  s.vendored_frameworks = 'AppstackSDK.xcframework'
  s.deprecated = true
  s.deprecated_in_favor_of = 'AppstackSDK'
end