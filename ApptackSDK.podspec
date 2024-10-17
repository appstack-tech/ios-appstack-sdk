Pod::Spec.new do |s|
  s.name             = 'AppstackSDK'
  s.version          = '1.0.0'
  s.summary          = 'SKAN raw postbacks service.'
  s.description      = <<-DESC
                      SKAN raw postbacks for everyone. https://www.app-stack.tech/
                      DESC
  s.homepage         = 'https://www.app-stack.tech/'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'AppStack' => 'lucas@app-stack.tech' }
  s.source           = { :git => 'https://github.com/appstack-tech/ios-appstack-sdk.git', :tag => s.version.to_s }
  s.ios.deployment_target = '13.0'
  s.vendored_frameworks = 'AppstackSDK.xcframework'
end