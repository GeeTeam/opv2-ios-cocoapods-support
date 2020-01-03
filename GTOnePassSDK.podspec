#
# Be sure to run `pod lib lint OneLoginSDK.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'GTOnePassSDK'
  s.version          = '2.2.4'
  s.summary          = '极验OnePassSDK'
  s.homepage         = 'https://www.geetest.com'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Geetest' => 'liulian@geetest.com' }
  s.source           = { :git => 'https://github.com/GeeTeam/opv2-ios-cocoapods-support.git', :tag => s.version.to_s }
  s.ios.deployment_target = '8.0'

  s.frameworks = 'CFNetwork', 'CoreTelephony', 'Foundation', 'SystemConfiguration', 'UIKit'
  s.libraries = 'c++.1', 'z.1.2.8'

  s.vendored_frameworks = 'GTSDK/TYRZSDK.framework', 'GTSDK/GTOnePass.framework'
  s.resources = 'README.md'
end
