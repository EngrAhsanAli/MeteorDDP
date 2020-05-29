#
# Be sure to run `pod lib lint MeteorDDP.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'MeteorDDP'
  s.version          = '2.0'
  s.summary          = 'A client for Meteor servers, written in Swift 5!'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
MeteorDDP is really helpful to integrate servers written in meteor (a framework written in javascript) using native Swift in iOS.
                       DESC

  s.homepage         = 'https://github.com/engrahsanali/MeteorDDP'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'engrahsanali' => 'hafiz.m.ahsan.ali@gmail.com' }
  s.source           = { :git => 'https://github.com/engrahsanali/MeteorDDP.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'
  s.libraries              = 'z'

  s.ios.deployment_target = '8.0'

  s.source_files = 'MeteorDDP/Classes/**/*'
  
  # s.resource_bundles = {
  #   'MeteorDDP' => ['MeteorDDP/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'
  
  s.dependency 'CryptoSwift'
  s.dependency 'Starscream'
  


end
