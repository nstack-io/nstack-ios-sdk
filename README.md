<p align="center">
  <img src="NStack_Logo.png?raw=true" alt="NStack"/>
</p>

[![Travis](https://img.shields.io/travis/nodes-ios/NStackSDK.svg)](https://travis-ci.org/nodes-ios/NStack) 
[![Codecov](https://img.shields.io/codecov/c/github/nodes-ios/NStackSDK.svg)](https://codecov.io/github/nodes-ios/NStack)
[![Carthage Compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)
![Plaform](https://img.shields.io/badge/platform-iOS-lightgrey.svg) 
[![GitHub license](https://img.shields.io/badge/license-MIT-blue.svg)](https://github.com/nodes-ios/NStackSDK/blob/master/LICENSE)

NStackSDK is the companion software development kit to the [NStack](https://nstack.io) backend.

## What is NStack?

> TODO: Describe NStack

## 📝 Requirements

* iOS 8.0+ / tvOS 9.0+
* Swift 3.0+

## 📦 Installation

### Carthage
~~~
# Swift 3
github "nodes-ios/NStack" ~> 1.0

# Swift 2.3
github "nodes-ios/NStack" == 3.12.0

# Swift 2.2
github "nodes-ios/NStack" == 3.10.0
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

#### Manually

> TODO: Docs


### Translations

> TODO: Docs

### Updates

> TODO: Docs

### Messages

> TODO: Docs

### Rate Reminder

> TODO: Docs

## 👥 Credits
Made with ❤️ at [Nodes](http://nodesagency.com).

## 📄 License
**NStackSDK** is available under the MIT license. See the [LICENSE](https://github.com/nodes-ios/NStack/blob/master/LICENSE) file for more info.
