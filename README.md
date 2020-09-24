# AutomationTools

### Core

[![CI Status](https://img.shields.io/travis/justeat/AutomationTools-Core.svg?style=flat)](https://travis-ci.org/justeat/AutomationTools-Core)
[![Version](https://img.shields.io/cocoapods/v/AutomationTools-Core.svg?style=flat)](https://cocoapods.org/pods/AutomationTools-Core)
[![License](https://img.shields.io/cocoapods/l/AutomationTools-Core.svg?style=flat)](https://cocoapods.org/pods/AutomationTools-Core)
[![Platform](https://img.shields.io/cocoapods/p/AutomationTools-Core.svg?style=flat)](https://cocoapods.org/pods/AutomationTools-Core)

### Host

[![CI Status](https://img.shields.io/travis/justeat/AutomationTools-Host.svg?style=flat)](https://travis-ci.org/justeat/AutomationTools-Host)
[![Version](https://img.shields.io/cocoapods/v/AutomationTools-Host.svg?style=flat)](https://cocoapods.org/pods/AutomationTools-Host)
[![License](https://img.shields.io/cocoapods/l/AutomationTools-Host.svg?style=flat)](https://cocoapods.org/pods/AutomationTools-Host)
[![Platform](https://img.shields.io/cocoapods/p/AutomationTools-Host.svg?style=flat)](https://cocoapods.org/pods/AutomationTools-Host)


## About

AutomationTools is a framework that helps you writing better and more maintainable UI tests. It allows launching the app, injecting flags to load the correct configuration and to automate repetitive actions (e.g. filling a basket, logging in a user etc.). The mechanism that is used for injecting state from a test case into the app under test is via the use of launch arguments and environment variables. The launch arguments are passed in to XCUIApplication’s launch method as an array of strings and the environment variables are passed as a dictionary. 

Along with the state configuration functionality, AutomationTools also contains the most reused functionality that we have in our test suites. Things like Page Object base classes, sensible waiting methods and an extension for XCUIApplication all mean that our test suite is easy to maintain and has high readability, flexibility and code reuse.

AutomationTools is composed of 2 pods: AutomationTools-Core and AutomationTools-Host. Core consists of app state configuration, base classes and utilities. Host provides a bridge between the test case and the app by unwrapping the testcase injected flags. The reason for using 2 separate podspecs instead of subspecs is to support Apple's new Build System. CocoaPods has a known [limitation](https://github.com/CocoaPods/CocoaPods/issues/8206) with naming the frameworks generated from subspecs.


### Core

- `ATTestCase.swift` is the base class inherited from XCTestCase to be used for all the UI test suites. It holds a reference to `XCUIApplication` and provides a `launchApp` method to be used to run the app from the tests:

```swift
launchApp(featureFlags: [Flag] = [], 
          automationFlags: [Flag] = [], 
          envVariables: [String : String] = [:],
          otherArgs: [String] = [])
```
We pass in arrays of Flags to the `launchApp` method which will then be marshalled using the LaunchArgumentBuilder by adding appropriate "EPHEMERAL" and "AUTOMATION" prefixes and converted into String representation.

- `LaunchArgumentsBuilder.swift` used in `ExtensionXCUIApplication.swift` has the following 2 methods exposed:

```swift
static public func launchArgumentForEphemeralConfiguration(_ ephemeralConfiguration: NSDictionary) -> String
static public func launchArgumentForAutomationConfiguration(_ automationConfiguration: NSDictionary) -> String
```

There is a nice trick here: since information from UI Tests process to app process happens via `ProcessInfo.processInfo.arguments`, which is typed `[String]`, we convert a dictionary of flags to a single string representation and marshal/unmarshal it. We pass in separate arrays for feature flags and automation flags.
Feature flags drive decision making paths while automation flags are used to setup the app environment (e.g. directly deeplink to a specific screen, simulate the user to be logged in at startup, etc.).  `LaunchArgumentBuilder` will add "EPHEMERAL" prefix to feature flags & "AUTOMATION" prefix to automation flags arguments to distinguish them easily to allow the unmarshalling in the app (via the later on described `AutomationBridge.swift`).

Flags are structs defined as:

```swift
public struct Flag {
    public let key: String
    public let value: Any
}
```

- `PageObject.swift` is the base class of the page objects defined in the client code. It holds references to `XCUIApplication` and the current `XCTestCase`.


#### Extensions

- `ExtensionXCTestCase.swift` contains basic utility methods to be used in the test suites. A wider range of utility methods can be found such as [EarlGrey](https://github.com/google/EarlGrey/blob/master/docs/cheatsheet/cheatsheet.png). Exposed methods are:

```swift
func waitForElementToNotExist(element: XCUIElement, timeout: Double = 10)
func waitForElementToExist(element: XCUIElement, timeout: Double = 10)
func waitForElementValueToExist(element: XCUIElement, valueString: String, timeout: Double = 10)
```

### Host

The client should have a component able to inspect the flags in the `ProcessInfo`. This can be done via `AutomationBridge.swift`, which exposes the following methods:

```swift
public var ephemeralConfiguration: NSDictionary?
public var automationConfiguration: NSDictionary?
public func launchArgumentsContain(_ launchArgument: String) -> Bool
```

Running a test via the `ATTestCase`'s `launchApp` method, the arguments that can be extracted in the `ProcessInfo` should now be no more than 2:

- One containing all the feature flags (optional)
- One containing all the automation flags (optional)

Extensions of `AutomationBridge` in the client code should expose methods like `simulateUserAlreadyLoggedIn()` checking for the existence of a value in the automation configuration. The client app uses these methods to drive decisions and simplify the execution of the UI tests.

`AutomationBridge` also publicly exposes the `ephemeralConfiguration` property (`NSDictionary` type) that is ultimately used to setup feature flags in the client code. The name comes from [JustTweaks](https://github.com/justeat/JustTweak) where `NSDictionary` and `NSMutableDictionary` are respectively made conformat to `Configuration` and `MutableConfiguration`, and we suggest to use it to setup a stack to ease to usage of featue flags.


### Example

#### Core

Call the launchApp() method from the test case with relevant configuration to set up and run the test case that inherits from `ATTestCase`. The launchApp() method gets the injected flags/arguments marshalled through LaunchArgumentsBuilder and launches the app with the correct configuration.

```swift
import XCTest
import AutomationTools_Core

class ExampleTestCases: ATTestCase {
    func testExample1() {
        launchApp(featureFlags: [Flag(key: Constants.feature1, value: false)],
                  automationFlags: [Flag(key: Constants.simulateUserAlreadyLoggedIn, value: true)],
                  otherArgs: [Constants.defaultStubBundle])

        // Test steps
       ...
    }
} 
```

#### Host

Extend `AutomationBridge` to include methods required for configuring the environment.

```swift
import Foundation
import AutomationTools_Host

public extension AutomationBridge {

     public var simulateUserAlreadyLoggedIn: Bool {
        return automationConfiguration?[Constants.simulateUserAlreadyLoggedIn] as? Bool ?? false
    }
} 
```

and use the ephemeral configuration to setup app configuration.

```swift
if let ephemeralConfiguration = automationBridge.ephemeralConfiguration {
    // use ephemeralConfiguration to setup app configuration
    // or setup a TweakManager with JustTweak
}
```

Here's an example of a stack setup with JustTweak:

```swift
lazy var tweakManager: TweakManager = {
    let ephemeralConfiguration = automationBridge.ephemeralConfiguration
    
    let userDefaultsConfiguration = UserDefaultsConfiguration(userDefaults: UserDefaults.standard)

    let jsonURL = Bundle.main.url(forResource: "Tweaks", withExtension: "json")!
    let localConfiguration = LocalConfiguration(jsonURL: jsonFileURL)
    
    let configurations: [Configuration] = [ephemeral, userDefaultsConfiguration, localConfiguration].compactMap { $0 }

    return TweakManager(configurations: configurations)
}()
```

## Installation

Include AutomationTools pod reference in the Checkout module's pod file

```
target 'YourProject_MainTarget' do
pod 'AutomationTools-Host', '5.0.0'
end

target 'YourProject_UITestsTarget' do
pod 'AutomationTools-Core', '5.0.0'
end
```

- Just Eat iOS team
