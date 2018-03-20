#
# Be sure to run `pod lib lint ByteRtcCore.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'ByteRtcCore'
  s.version          = '1.1.12'
  s.summary          = 'ByteRtcCore is an realtime communication SDK of IOS.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
TODO: Add long description of the pod here.
                       DESC

  s.homepage         = 'https://github.com/zhanglehs/ByteRtcEngineKit'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'zhangle86@qq.com' => 'zhangle86@gmail.com' }
  s.source           = { :git => 'https://github.com/zhanglehs/ByteRtcEngineKit.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '8.0'

  #s.source_files = 'ByteRtcCore/Classes/**/*'
  
  #s.vendored_libraries = 'WebRTC.framework'
  s.vendored_frameworks = 'WebRTC.framework'
  
  # s.resource_bundles = {
  #   'ByteRtcCore' => ['ByteRtcCore/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'
  s.dependency 'Socket.IO-Client-Swift', '~> 12.0.0'
end
