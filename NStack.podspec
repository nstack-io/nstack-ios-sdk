#
# Be sure to run `pod lib lint TuvaUI.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'NStack'
  s.version          = '4.0.0'
  s.summary          = 'A short description of NStack.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
TODO: Add long description of the pod here.
                       DESC

  s.homepage         = 'https://github.com/nicktrienensfuzz/nstack-ios-sdk'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Nick Trienens' => 'nick@fuzz.pro' }
  s.source           = { :git => 'https://github.com/com:nicktrienensfuzz/nstack-ios-sdk.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '11.0'
  s.swift_version = '5.2'

  s.default_subspecs = "Core"
  s.dependency 'NLocalizationManager'

  s.subspec 'Core' do |core|
      core.source_files = [ 'NStackSDK/**.swift']
  end


end
