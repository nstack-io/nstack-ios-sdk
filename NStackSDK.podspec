Pod::Spec.new do |spec|

  # ―――  Spec Metadata  ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  #
  #  These will help people to find your library, and whilst it
  #  can feel like a chore to fill in it's definitely to your advantage. The
  #  summary should be tweet-length, and the description more in depth.
  #

  spec.name         = "NStackSDK"
  spec.version      = "5.1.2"
  spec.summary      = "NStackSDK is the companion software development kit to the NStack backend."
  spec.homepage     = "https://github.com/nstack-io/nstack-ios-sdk"
  spec.license      = { :type => "MIT", :file => "LICENSE" }
  spec.author       = { "Nodes - iOS" => "ios@nodes.dk" }

  spec.swift_version = '5.0'
  spec.ios.deployment_target = "10.3"
  spec.osx.deployment_target = "10.13"
  spec.watchos.deployment_target = "3.0"
  spec.tvos.deployment_target = "10.2"

  spec.source       = { :git => "https://github.com/nstack-io/nstack-ios-sdk.git", :tag => "#{spec.version}" }
  spec.source_files  = "NStackSDK"
  #spec.framework  = "LocalizationManager"
  spec.dependency "NLocalizationManager", "~> 3.1.1"

end
