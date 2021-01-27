#
# Be sure to run `pod lib lint TuvaUI.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'NStackSDK'
  s.version          = '5.1.5'
  s.summary          = 'NStackSDK is the companion software development kit to the NStack backend.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!
  s.description      = <<-DESC
     NStack is Nodes\' "Backend as a Service" product that enables clients to manage many aspects of their products by themselves.
  DESC

  s.homepage     = 'https://github.com/nstack-io/nstack-ios-sdk'
  s.license      = { :type => "MIT", :file => "LICENSE" }
  s.author       = { "Nodes Agency - iOS" => "ios@nodes.dk" }
  s.source       = { :git => 'https://github.com/nstack-io/nstack-ios-sdk', :tag => s.version.to_s }

  s.ios.deployment_target = "9.0"
  s.swift_version = '5.2'

  s.default_subspecs = "Core"
  s.dependency 'NLocalizationManager', '~> 3.0'

  s.subspec 'Core' do |core|
      core.source_files = [ 'NStackSDK/**/*.swift']
  end
end
