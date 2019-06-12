# AutomationTools

[![CI Status](https://img.shields.io/travis/justeat/AutomationTools.svg?style=flat)](https://travis-ci.org/justeat/AutomationTools)
[![Version](https://img.shields.io/cocoapods/v/AutomationTools.svg?style=flat)](https://cocoapods.org/pods/AutomationTools)
[![License](https://img.shields.io/cocoapods/l/AutomationTools.svg?style=flat)](https://cocoapods.org/pods/AutomationTools)
[![Platform](https://img.shields.io/cocoapods/p/AutomationTools.svg?style=flat)](https://cocoapods.org/pods/AutomationTools)

## About
AutomationTools is a framework that helps you writing better and more maintainable UI tests.
It allows launching the app injecting flags to load the correct configuration and to automate repetitive actions (e.g. filling a basket, logging in a user etc.).

AutomationTools is sectioned in to Core and HostApp

### Core

- `JustEatTestCase.swift` is the base class to be used for all the UI test suites. It holds a handy reference to `XCUIApplication`.

- `LaunchArgumentsBuilder.swift` used in `ExtensionXCUIApplication.swift` has the following 2 methods exposed:

```swift
static public func launchArgumentForEphemeralConfiguration(_ ephemeralConfiguration: NSMutableDictionary) -> String
static public func launchArgumentForAutomationConfiguration(_ automationConfiguration: NSMutableDictionary) -> String
```

There is a nice trick here: since information from UI Tests process to app process happens via `ProcessInfo.processInfo.arguments`, which is typed `[String]`, we convert a dictionary of flags to a single string representation and marshal/unmarshal it. To allow the unmarshalling in the app (via the later on described `AutomationBridge.swift`).

- `PageObject.swift` is the base class of the page objects defined in the client code. It holds references to `XCUIApplication` and the current `XCTestCase`.


#### Extensions

- `ExtensionXCTestCase.swift` contains basic utility methods to be used in the test suites. We tried to keep this to the minimum, if you are looking for a wider range of utility methos you can take a look at solutions such as [EarlGrey](https://github.com/google/EarlGrey/blob/master/docs/cheatsheet/cheatsheet.png). Exposed methods are:

```swift
func waitForElementToNotExist(element: XCUIElement, timeout: Double = 10)
func waitForElementToExist(element: XCUIElement, timeout: Double = 10)
func waitForElementValueToExist(element: XCUIElement, valueString: String, timeout: Double = 10)
```

- `ExtensionXCUIApplication.swift` extends `XCUIApplication` providing a method to be used to run the app from the tests:

```swift
func launchApp(featureFlags: [Flag] = [], automationFlags: [Flag] = []) {
```

The distinction between feature and automation flags is important:
- Feature flags should ultimately be used by the app to setup the environment (for our products at Just Eat we use the [JustTweak](https://github.com/justeat/JustTweak) with an ephemeral configuration.
- Automation flags should be used to drive decision making paths in code to allow easier testing (e.g. directly deeplink to a specific screen, simulate the user to be logged in at startup, etc.)

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
