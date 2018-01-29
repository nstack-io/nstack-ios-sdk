<p align="center">
  <img src="NStack_Logo.png?raw=true" alt="NStack"/>
</p>

[![Travis](https://img.shields.io/travis/nodes-ios/NStackSDK.svg)](https://travis-ci.org/nodes-ios/NStackSDK) 
[![Codecov](https://img.shields.io/codecov/c/github/nodes-ios/NStackSDK.svg)](https://codecov.io/github/nodes-ios/NStackSDK)
[![Carthage Compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)
![Plaform](https://img.shields.io/badge/platform-iOS%20|%20macOS%20|%20tvOS%20|%20watchOS-lightgrey.svg) 
[![GitHub license](https://img.shields.io/badge/license-MIT-blue.svg)](https://github.com/nodes-ios/NStackSDK/blob/master/LICENSE)

NStackSDK is the companion software development kit to the [NStack](https://nstack.io) backend.

## What is NStack?

> TODO: Describe NStack

## 📝 Requirements

* iOS 8.0+ / tvOS 9.0+ / macOS 10.10+ / watchOS 2.0+
* Swift 3.0+

## 📦 Installation

### Carthage
~~~
# Swift 3
github "nodes-ios/NStackSDK" ~> 2.0

# Swift 2.3
github "nodes-ios/NStackSDK" == 0.3.12

# Swift 2.2
github "nodes-ios/NStackSDK" == 0.3.10
~~~

## 💻 Usage

> **NOTE:** Don't forget to `import NStackSDK` in the top of the file.

### Getting Started

#### Plist

In your AppDelegate's `didFinishLaunching:` function start NStack by running:

~~~swift
let configuration = Configuration(plistName: "NStack", translationsClass: Translations.self)
NStack.start(configuration: configuration, launchOptions: launchOptions)
~~~

You should have a file called NStack.plist in your application bundle. It needs to contain a key called **`REST_API_KEY`** and a key called **`APPLICATION_ID`**.


#### Manually

> TODO: Docs

## Features

### Translations
To use nstack for translations, you need to install the [nstack translations generator](https://github.com/nodes-ios/nstack-translations-generator). After that, all translations will be available through the tr-variable. Example: `tr.login.forgotPassword` where `login` is the section and `forgotPassword` is the key from nstack. For example: 
~~~~swift
@IBOutlet weak var forgotPasswordButton: UIButton! {
    didSet {
 	forgotPasswordButton.setTitle(tr.login.forgotPassword, for: .normal)
    }
}
~~~~


### Updates

> TODO: Docs

Shows alerts if there is a new app update available.

> **NOTE:** This feature is not yet supported on macOS and watchOS.

### Messages

> TODO: Docs

Ability to show custom messages to users, for example warning them about server outage.

> **NOTE:** This feature is not yet supported on macOS and watchOS.

### Rate Reminder

> TODO: Docs

Alerts to remind the user to rate the application.

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

### Content responses

If you want to make a quick read API you can use NStacks Content Response feature. If you created a content response in the NStack web console fetch the data in the app as:
~~~~swift
NStack.sharedInstance.getContentResponse(60) { (response, error) in
    if let _ = response {
        //You have the content response
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
