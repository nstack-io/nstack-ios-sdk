project 'NStackSDK/NStackSDK.xcodeproj'

# Uncomment the next line to define a global platform for your project
platform :ios, '10.3'

def test_pods
  pod 'Quick'
  pod 'Nimble'
end

target 'NStackSDK' do
  # Comment the next line if you're not using Swift and don't want to use dynamic frameworks
  use_frameworks!

  # Pods for NStackSDK

  target 'NStackSDKTests' do
    inherit! :search_paths
    # Pods for testing
    test_pods
  end
end

target 'NStackSDK-macOS' do
  # Comment the next line if you're not using Swift and don't want to use dynamic frameworks
  use_frameworks!

  # Pods for NStackSDK-macOS

  target 'NStackSDK-macOSTests' do
    inherit! :search_paths
    # Pods for testing
    test_pods
  end

end

target 'NStackSDK-tvOS' do
  # Comment the next line if you're not using Swift and don't want to use dynamic frameworks
  use_frameworks!

  # Pods for NStackSDK-tvOS

  target 'NStackSDK-tvOSTests' do
    inherit! :search_paths
    # Pods for testing
    test_pods
  end

end

# No Pods for watchOS, as not needed/supported

