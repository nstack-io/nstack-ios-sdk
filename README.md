<p align="center">
    <img src="NStack_Logo.png?raw=true" alt="NStack"/>
</p>

[![bitrise](https://app.bitrise.io/app/07acd68091c14c12/status.svg?token=xfdewD-n8sL8VIVOOTX7JA&branch=master)](https://app.bitrise.io/app/07acd68091c14c12)
[![Carthage Compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)
![Plaform](https://img.shields.io/badge/platform-iOS%20|%20macOS%20|%20tvOS%20|%20watchOS-lightgrey.svg)
[![GitHub license](https://img.shields.io/badge/license-MIT-blue.svg)](https://github.com/nodes-ios/NStackSDK/blob/master/LICENSE)

NStackSDK is the companion software development kit to the [NStack](https://nstack.io) backend.

## What is NStack?

See the [NStack documentation](https://nstack-io.github.io/docs/docs/guides/iOS/ios.html) for more information about NStack.

To use the whole power of the localizations feature of the NStack backend, you need

* NStackSDK (the SDK in this repo)
* [LocalizationManager](https://github.com/nodes-ios/TranslationManager) (sub-dependency of this SDK, no need to get it separately, comes with NStackSDK when installed via CocoaPods or Carthage)
* [NStack Localizations Generator](https://github.com/nodes-ios/nstack-localizations-generator)

For more details see [Installation](#-installation) and [Usage](#-usage) below.
If you're updating to NStack 5, check [the migration guide](https://github.com/nstack-io/nstack-ios-sdk/tree/feature/demo-project/Documentation).

## 📦 Installation

### CocoaPods
~~~
pod 'NStackSDK', '~> 5.1.4'
~~~

### Carthage
~~~
# Swift 5
github "nstack-io/nstack-ios-sdk" ~> 5.0
~~~

- run `carthage update --platform ios --cache-builds` to install the newly added sdk
- this will build `NStackSDK` and `LocalizationManager`
- add the 2 frameworks to your project (follow [the official carthage instructions](https://github.com/Carthage/Carthage#if-youre-building-for-ios-tvos-or-watchos) if unsure how)
 
### Swift Package Manager

Swift Package Manager support is in development, you can give it a try using the `feature/spm-support` branch

## 💻 Usage

### Getting Started

We assume that you have installed the NStackSDK via CocoaPods or Carthage already (see [Installation](#-installation)).

- go to the [latest release of nstack-localizations-generator](https://github.com/nodes-ios/nstack-localizations-generator/releases) and download the latest nstack-`localizations-generator.bundle.zip`, unzip it and copy it to `${SRCROOT}/${TL_PROJ_ROOT_FOLDER}/Resources/NStack/`. This will be referenced from a build script, so the location has to match the one in the script. Don’t include it in your Xcode project.
- add a new Run Script Phase to your project before the Compile Sources phase and copy
[this script](https://github.com/nodes-ios/nstack-localizations-generator/blob/master/translations_script.sh) in it
- create an `NStack.plist` file in your Xcode project. Make sure it matches the location specified in the script (if not manually changed, that's`${SRCROOT}/${TL_PROJ_ROOT_FOLDER}/Resources/NStack/NStack.plist`). Add `APPLICATION_ID` and `REST_API_KEY` with the values of your NStack app

   ```xml
   <key>APPLICATION_ID</key>
	<string>...</string>
	<key>REST_API_KEY</key>
	<string>...</string>
	```
	
- make sure your folder structure and the paths specified by the script match. Otherwise, the translations step will fail. Refer to the [demo project](https://github.com/nstack-io/nstack-ios-sdk/tree/master/NStackSDKDemo) for an example. Folders must be created before you run the script. 
- make an uber-clean build (cmd+option+shift+k, then cmd+b) to fetch the language jsons and generate the localizations class; this will download a `Localizations_<locale>.json` file for each language in your app, and create or regenerate the `Localizations.swift` and `SKLocalizations.swift` files
- add the Translations folder (containing `Localizations.swift`, `SKLocalizations.swift` and the `Localizations_<locale>.json` files) to your project. Make sure they’re included in your app target.
- setup NStackSDK in your app by adding this method in your `AppDelegate.swift`:

  ```swift
  private func setupNStack(with launchOptions: [UIApplication.LaunchOptionsKey: Any]? ) {
        var nstackConfig = Configuration(plistName: "NStack",
                                         environment: .production,     // You can switch here based on your app's current environment
                                         localizationClass: Localizations.self)
        nstackConfig.updateOptions = [.onDidBecomeActive]
        NStack.start(configuration: nstackConfig, launchOptions: launchOptions)
        NStack.sharedInstance.localizationManager?.updateLocalizations()
    }
    ```
    
    and call it from `application_:didFinishLaunchingWithOptions:` method
- access your texts with `lo.<section>.<key>`; i.e. `lo.defaultSection.close`


## Features

For an overview of what features are available and what they do check out the [feature overview](https://nstack-io.github.io/documentation/features.html) in the documentation.

### Localization

After completing the installation and basic usage steps above, all translations will be available through the `lo`-variable. Example: `lo.login.forgotPassword` where `login` is the section and `forgotPassword` is the key from nstack. For example:
~~~~swift
@IBOutlet weak var forgotPasswordButton: UIButton! {
    didSet {
        forgotPasswordButton.setTitle(lo.login.forgotPassword, for: .normal)
    }
}
~~~~

From NStack 4.0 release, there are other ways of assigning translations within your project.

~~~~swift
label1.text = lo.defaultSection.successKey
----
label2.localize(for: "default.successKey")
----
label3.localize(for: skl.defaultSection.successKey)
----
label4 <=> "default.successKey"
----
label5 <=> skl.defaultSection.successKey
~~~~
And with Swift 5.1 and up, you can also use the `NSLocalizable` property wrapper.
~~~~swift
@IBOutlet @NSLocalizable("default.successKey") var label6: UILabel!
----
@IBOutlet @NSLocalizable(skl.defaultSection.successKey) var label7: UILabel!
~~~~


### Responses
Responses allow you to define and update JSON files on the NStack web console and retrieve them using the NStack sdk or using a normal get request.
~~~~swift
NStack.sharedInstance.getContentResponse(id) { (data, error) in
  guard error == nil else {
    print("Error fetching response with id: \(id)")
    return
  }
            
  // Use data
}
~~~~


### Collections
Collections is a more structured version of Responses and can be used as an alternative to an simple read API.
See the [feature overview](https://nstack-io.github.io/documentation/features.html) for a more detailed explaination.

~~~~swift
let completion: (NStack.Result<Product>) -> Void = { result in
  switch result {
  case .success(let data):
    print("Fetching collection successful")
    print(data)
  case .failure(let error):
    print("Error fetching collection: \(error)")
  }
}
        
NStack.sharedInstance.fetchCollectionResponse(for: id, completion: completion)
~~~~

### Files
With files you can retrieve files defined on the NStack web console using a normal get request.
The files functionality has not been implemented in the sdk.

~~~~swift
if let url = URL(string: url) {
  URLSession.shared.downloadTask(with: url) { (localURL, urlResponse, error) in
    guard error == nil else {
        print("Error fetching file with url: \(url)")
        print(error)
        return
    }

    if let localURL = localURL {
        print("Local URL: \(localURL)")
        // Use the localURL to modify, use your newly downloaded file
    }
  }.resume()
}
~~~~

### Version control

Version control informs the user when a new version is available and what new changes are available.
You don't have to do anything to use the version control feature, just include the NStack sdk in your project.
To enable it create a new version on the NStack web console.
Checkout the [feature overview](https://nstack-io.github.io/documentation/features.html) on how to setup version control.


> **NOTE:** This feature is not yet supported on macOS and watchOS.

### Messages

Messages shows the user a custom message when the app is launched, for example warning them about a server outage.
You don't have to do anything to use the messages feature, just include the NStack sdk in your project.
To show the users a message create one on the NStack web console.
Checkout the [feature overview](https://nstack-io.github.io/documentation/features.html) on how to setup messages.

> **NOTE:** This feature is not yet supported on macOS and watchOS.

### Rate Reminder

Rate reminder shows the user Apple's build in rate reminder after the user has launched the app a certain amount of times.
You don't have to do anything to use the rate reminder feature, just include the NStack sdk in your project.
To enable the rate reminder configure it on the NStack web console.
Checkout the [feature overview](https://nstack-io.github.io/documentation/features.html) on how to setup rate reminders.

> **NOTE:** This feature is not yet supported on macOS and watchOS.

### Geography

NStack supports a list of geographical features. You can get and store list of countries, continents, langunages and timezones of the world, getting timezone for (lat, lng) coordinate and getting geographical information based on the requestee's ip address. For example:
~~~~swift
NStack.sharedInstance.timezone(lat: 12.0, lng: 55.0) { (timezone, error) in
    if let timezone = timezone {
        print("(12.0,55.0) is in timezone \(timezone.name)")
    }
}
~~~~

### Validation

NStack makes it possible to validate the syntax and domain of an email, just use:
~~~~swift
NStack.sharedInstance.validateEmail("tech@nodes.dk") { (valid, error) in
    if valid {
        //Email syntax and domain is valid
    }
}
~~~~

## 👥 Credits
Made with ❤️ at [Nodes](http://nodesagency.com).

## 📄 License
**NStackSDK** is available under the MIT license. See the [LICENSE](https://github.com/nodes-ios/NStackSDK/blob/master/LICENSE) file for more info.
