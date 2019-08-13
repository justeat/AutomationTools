# AutomationTools

[![CI Status](https://img.shields.io/travis/justeat/AutomationTools.svg?style=flat)](https://travis-ci.org/justeat/AutomationTools)
[![Version](https://img.shields.io/cocoapods/v/AutomationTools.svg?style=flat)](https://cocoapods.org/pods/AutomationTools)
[![License](https://img.shields.io/cocoapods/l/AutomationTools.svg?style=flat)](https://cocoapods.org/pods/AutomationTools)
[![Platform](https://img.shields.io/cocoapods/p/AutomationTools.svg?style=flat)](https://cocoapods.org/pods/AutomationTools)

## About
AutomationTools is a framework that helps you writing better and more maintainable UI tests. It allows launching the app, injecting flags to load the correct configuration and to automate repetitive actions (e.g. filling a basket, logging in a user etc.). The mechanism that is used for injecting state from a test case into the app under test is via the use of launch arguments and environment variables. The launch arguments are passed in to XCUIApplication’s launch method as an array of strings and the environment variables are passed as a dictionary. 

Along with the state configuration functionality, AutomationTools also contains the most reused functionality that we have in our test suites. Things like Page Object base classes, sensible waiting methods and an extension for XCUIApplication all mean that our test suite is easy to maintain and has high readability, flexibility and code reuse.

AutomationTools is sectioned in to Core and HostApp. Core consists of app state configuration, base classes and utilities. HostApp provides a bridge between the test case and the app by unwrapping the testcase injected flags.


### Core

- `JustEatTestCase.swift` is the base class inherited from XCTestCase to be used for all the UI test suites. It holds a reference to `XCUIApplication`.

- `LaunchArgumentsBuilder.swift` used in `ExtensionXCUIApplication.swift` has the following 2 methods exposed:

```swift
static public func launchArgumentForEphemeralConfiguration(_ ephemeralConfiguration: NSMutableDictionary) -> String
static public func launchArgumentForAutomationConfiguration(_ automationConfiguration: NSMutableDictionary) -> String
```

There is a nice trick here: since information from UI Tests process to app process happens via `ProcessInfo.processInfo.arguments`, which is typed `[String]`, we convert a dictionary of flags to a single string representation and marshal/unmarshal it. We pass in separate arrays for featureFlags(drive decision making paths. for our products at Just Eat we use the [JustTweak](https://github.com/justeat/JustTweak) and for automationFlags(setup app environment. e.g. directly deeplink to a specific screen, simulate the user to be logged in at startup, etc.) , and LaunchArgumentBuilder will add "EPHEMERAL" prefix to feature flags & "AUTOMATION" prefix to automation flags arguments to distinguish them easily to allow the unmarshalling in the app (via the later on described `AutomationBridge.swift`).

Flags are structs defined as:
public struct Flag {
    public let key: String
    public let value: Any
}

- `PageObject.swift` is the base class of the page objects defined in the client code. It holds references to `XCUIApplication` and the current `XCTestCase`.


#### Extensions

- `ExtensionXCTestCase.swift` contains basic utility methods to be used in the test suites. A wider range of utility methods can be found such as [EarlGrey](https://github.com/google/EarlGrey/blob/master/docs/cheatsheet/cheatsheet.png). Exposed methods are:

```swift
func waitForElementToNotExist(element: XCUIElement, timeout: Double = 10)
func waitForElementToExist(element: XCUIElement, timeout: Double = 10)
func waitForElementValueToExist(element: XCUIElement, valueString: String, timeout: Double = 10)
```

- `ExtensionXCUIApplication.swift` extends `XCUIApplication` providing a launchApp method to be used to run the app from the tests:

```swift
launchApp(featureFlags: [Flag] = [], 
            automationFlags: [Flag] = [], 
            envVariables: [String : String] = [:],
            otherArgs: [String] = [])
```
We pass in arrays of Flags to the launchApp() method which will then be marshalled using the LaunchArgumentBuilder by adding appropriate "EPHEMERAL" and "AUTOMATION" flags and converted into String representation.

### HostApp

The client should have a component able to inspect the flags in the `ProcessInfo`. This can be done via `AutomationBridge.swift`, which exposes the following methods:

```swift
public var isRunningAutomationTests: Bool
public var ephemeralConfiguration: NSMutableDictionary?
public var automationConfiguration: NSMutableDictionary?
```

Running a test via the `XCUIApplication`'s `launchApp` method, the arguments that can be extracted in the `ProcessInfo` should now be no more than 3:

- One that signifies the fact that we are running UI tests at all
- One containing all the feature flags (optional)
- One containing all the automation flags (optional)

Extensions of `AutomationBridge` in the client code should expose methods like `simulateUserAlreadyLoggedIn()` checking for the existence of a value in the automation configuration. The client app uses these methods to drive decisions and simplify the execution of the UI tests.

`AutomationBridge` also publicly exposes the ephemeral configuration that is ultimately used to setup feature flags in the client code. Again, we suggest to use our [JustTweaks](https://github.com/justeat/JustTweak) setting up a coordinator with an ephemeral configuration (it should also have max priority (`TweaksConfigurationPriority.high`) that should be the first one in the list of configurations. E.g.

```swift
lazy var tweaksCoordinator: TweaksConfigurationsCoordinator = {
    let jsonURL = Bundle.main.url(forResource: "Tweaks", withExtension: "json")!
    let jsonConfiguration = JSONTweaksConfiguration(defaultValuesFromJSONAtURL: jsonURL)!
    let userConfiguration = UserDefaultsTweaksConfiguration(userDefaults: UserDefaults.standard, fallbackConfiguration: jsonConfiguration)

    var configurations: [TweaksConfiguration] = [jsonConfiguration, userConfiguration]

    if let ephemeralConfiguration = automationBridge.ephemeralConfiguration {
        configurations = [ephemeralConfiguration] + configurations
    }

    return TweaksConfigurationsCoordinator(configurations: configurations)!
}()
```

### Example
#### Core
Call the launchApp() method from the test case with relevant configuration to set up and run the test case that inherits from JEXCTestCase. The launchApp() method gets the injected flags/arguments marshalled through LaunchArgumentsBuilder and launches the app with the correct configuration.

```swift
import XCTest
import AutomationTools

class ExampleTestCases: JEXCTestCase {
    func testExample1() {
        app.launchApp(featureFlags: [Flag(key: Constants.feature1, value: false)],
                      automationFlags: [Flag(key: Constants.simulateUserAlreadyLoggedIn, value: true)],
                      otherArgs: [Constants.defaultStubBundle])

        // Test steps
       ...
    }
} 
```

#### HostApp
Extend AutomationBridge to include the methods required for state configuration

```swift
import Foundation
import AutomationTools

public extension AutomationBridge {

     public var simulateUserAlreadyLoggedIn: Bool {
        return automationConfiguration?[Constants.simulateUserAlreadyLoggedIn] as? Bool ?? false
    }
} 
```

AutomationBridge.swift exposes the ephemeral configuration which should be used by a coordinator to apply the relevant state.

```swift
    if let ephemeralConfiguration = automationBridge.ephemeralConfiguration {
        // use ephemeralConfiguration to setup your environment
        // or setup a coordinator with JustTweak

    } 
```

## Installation

Include AutomationTools pod reference in the Checkout module's pod file

```
target 'YourProject_MainTarget' do
pod 'AutomationTools/HostApp', '1.0.0'
end

target 'YourProject_UITestsTarget' do
pod 'AutomationTools/Core', '1.0.0'
end
```

- Just Eat iOS team
